local M = {}

local function window(value)
  if type(value) ~= "table" then return nil end
  return {
    used_percent = type(value.usedPercent) == "number" and value.usedPercent or nil,
    duration_mins = type(value.windowDurationMins) == "number" and value.windowDurationMins or nil,
    resets_at = type(value.resetsAt) == "number" and value.resetsAt or nil,
  }
end

function M.normalize(result)
  result = type(result) == "table" and result or {}
  local buckets = result.rateLimitsByLimitId
  if type(buckets) ~= "table" or not next(buckets) then
    buckets = result.rateLimits and { codex = result.rateLimits } or {}
  end

  local rows = {}
  for id, bucket in pairs(buckets) do
    if type(bucket) == "table" then
      rows[#rows + 1] = {
        id = bucket.limitId or id,
        name = type(bucket.limitName) == "string" and bucket.limitName ~= "" and bucket.limitName or bucket.limitId or id,
        primary = window(bucket.primary),
        secondary = window(bucket.secondary),
        reached = type(bucket.rateLimitReachedType) == "string" and bucket.rateLimitReachedType or nil,
      }
    end
  end
  table.sort(rows, function(a, b) return tostring(a.id) < tostring(b.id) end)
  return rows
end

function M.read(client, callback)
  client:request("account/rateLimits/read", {}, function(result, err)
    if err then return callback(nil, err) end
    callback(M.normalize(result))
  end)
end

local function duration(minutes)
  if not minutes then return "Window" end
  if minutes % 10080 == 0 then return (minutes / 10080) .. "w" end
  if minutes % 1440 == 0 then return (minutes / 1440) .. "d" end
  if minutes % 60 == 0 then return (minutes / 60) .. "h" end
  return minutes .. "m"
end

local function format_window(value)
  if not value then return nil end
  local parts = {}
  if value.used_percent then
    parts[#parts + 1] = string.format("%g%% left", math.max(0, math.min(100, 100 - value.used_percent)))
  end
  if value.resets_at then parts[#parts + 1] = "resets " .. os.date("%a %d %b %H:%M", value.resets_at) end
  if #parts == 0 then return nil end
  return duration(value.duration_mins) .. ": " .. table.concat(parts, ", ")
end

function M.format(rows)
  if #rows == 0 then return nil end
  local lines = { "Reset times are local", "" }
  for _, row in ipairs(rows) do
    lines[#lines + 1] = row.name
    local primary = format_window(row.primary)
    local secondary = format_window(row.secondary)
    if primary then lines[#lines + 1] = "  " .. primary end
    if secondary then lines[#lines + 1] = "  " .. secondary end
    if row.reached then lines[#lines + 1] = "  Limit reached: " .. row.reached end
  end
  return table.concat(lines, "\n")
end

return M
