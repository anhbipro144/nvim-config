local M = {}

function M.notify(message, level)
  vim.notify("Codex Sessions: " .. message, level or vim.log.levels.INFO)
end

function M.error_message(err)
  if type(err) == "string" then
    return err
  end
  if type(err) ~= "table" then
    return tostring(err)
  end
  if type(err.message) == "string" then
    return err.message
  end
  if type(err.error) == "table" and type(err.error.message) == "string" then
    return err.error.message
  end
  return "unknown Codex error"
end

function M.short_id(id)
  return type(id) == "string" and id:sub(1, 8) or "?"
end

function M.display_path(path)
  if type(path) ~= "string" then
    return ""
  end
  local home = vim.fn.expand("~")
  return path:sub(1, #home) == home and "~" .. path:sub(#home + 1) or path
end

function M.truncate(value, width)
  value = tostring(value or ""):gsub("%s+", " ")
  if vim.fn.strdisplaywidth(value) <= width then
    return value
  end
  return vim.fn.strcharpart(value, 0, math.max(1, width - 1)) .. "…"
end

function M.relative_time(timestamp)
  if type(timestamp) ~= "number" then
    return ""
  end
  local seconds = math.max(0, os.time() - timestamp)
  if seconds < 60 then return seconds .. "s" end
  if seconds < 3600 then return math.floor(seconds / 60) .. "m" end
  if seconds < 86400 then return math.floor(seconds / 3600) .. "h" end
  return math.floor(seconds / 86400) .. "d"
end

function M.status(status)
  if type(status) == "string" then return status end
  if type(status) == "table" then
    return status.type or status.state or status.status or ""
  end
  return ""
end

function M.source(source)
  if type(source) == "string" then return source end
  if type(source) == "table" then
    return source.type or source.kind or source.source or ""
  end
  return ""
end

function M.format_session(session, width)
  width = width or math.max(60, vim.o.columns - 8)
  local title = session.name or session.preview or session.id or ""
  local cwd = M.display_path(session.cwd)
  local source = M.source(session.source)
  local status = M.status(session.status)
  local id = M.short_id(session.id)
  local fixed = 5 + 1 + 10 + 1 + 12 + 1 + 9
  local title_width = math.max(16, math.floor(width * 0.30))
  local cwd_width = math.max(14, width - title_width - fixed)
  return string.format(
    "%-" .. title_width .. "s %-5s %-" .. cwd_width .. "s %-10s %-12s %s",
    M.truncate(title, title_width),
    M.relative_time(session.updated_at),
    M.truncate(cwd, cwd_width),
    M.truncate(source, 10),
    M.truncate(status, 12),
    id
  )
end

function M.session_details(session)
  local lines = {
    "Name: " .. (session.name or "(unnamed)"),
    "ID: " .. (session.id or ""),
  }
  if session.cwd then table.insert(lines, "CWD: " .. session.cwd) end
  if session.source then table.insert(lines, "Source: " .. M.source(session.source)) end
  if session.status then table.insert(lines, "Status: " .. M.status(session.status)) end
  if session.preview and session.preview ~= "" then
    table.insert(lines, "Preview: " .. M.truncate(session.preview, 100))
  end
  return table.concat(lines, "\n")
end

return M
