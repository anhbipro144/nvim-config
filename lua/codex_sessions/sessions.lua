local M = {}
local Store = {}
Store.__index = Store

local function value(value)
  if value == vim.NIL then return nil end
  return value
end

function M.normalize(thread, archived)
  return {
    id = value(thread.id) or value(thread.sessionId),
    name = value(thread.name),
    preview = value(thread.preview),
    cwd = value(thread.cwd),
    source = value(thread.source),
    status = value(thread.status),
    updated_at = value(thread.updatedAt) or value(thread.recencyAt) or value(thread.createdAt),
    created_at = value(thread.createdAt),
    archived = archived == true,
    forked_from_id = value(thread.forkedFromId),
    raw = thread,
  }
end

function Store.new(client)
  return setmetatable({ client = client }, Store)
end

function Store:_request(method, id, params, callback)
  if type(id) ~= "string" or id == "" then
    return callback(nil, { message = "missing thread ID; refresh the picker" })
  end
  self.client:request(method, vim.tbl_extend("force", { threadId = id }, params or {}), callback)
end

function Store:list(opts, callback)
  opts = opts or {}
  local params = {
    archived = opts.archived == true,
    limit = opts.limit or 500,
    sortKey = "updated_at",
    sortDirection = "desc",
  }
  if opts.current_cwd_only then params.cwd = opts.cwd or vim.fn.getcwd() end

  local rows, index_by_id = {}, {}
  local function page(db_only)
    params.useStateDbOnly = db_only or nil
    self.client:request("thread/list", params, function(result, err)
      if err then return callback(nil, err) end
      result = result or {}
      for _, thread in ipairs(result.data or {}) do
        local session = M.normalize(thread, params.archived)
        if session.id then
          local index = index_by_id[session.id]
          if index then
            rows[index] = session
          else
            rows[#rows + 1] = session
            index_by_id[session.id] = #rows
          end
        end
      end
      if value(result.nextCursor) then
        params.cursor = result.nextCursor
        return page(db_only)
      end
      if not db_only then
        params.cursor = nil
        return page(true)
      end
      table.sort(rows, function(a, b)
        if a.updated_at == b.updated_at then return a.id > b.id end
        return (a.updated_at or 0) > (b.updated_at or 0)
      end)
      callback(rows)
    end)
  end
  page(false)
end

function Store:get(id, callback)
  self:_request("thread/read", id, { includeTurns = false }, function(result, err)
    if err then return callback(nil, err) end
    callback(result and value(result.thread) and M.normalize(result.thread, false), nil)
  end)
end

function Store:rename(id, name, callback)
  self:_request("thread/name/set", id, { name = name }, callback)
end

function Store:fork(id, opts, callback)
  opts = opts or {}
  self:_request("thread/fork", id, {
    excludeTurns = opts.exclude_turns ~= false,
  }, function(result, err)
    if err then return callback(nil, err) end
    callback(result and value(result.thread) and M.normalize(result.thread, false), nil)
  end)
end

function Store:archive(id, callback)
  self:_request("thread/archive", id, nil, callback)
end

function Store:unarchive(id, callback)
  self:_request("thread/unarchive", id, nil, function(result, err)
    if callback then callback(result and value(result.thread) and M.normalize(result.thread, false), err) end
  end)
end

function Store:delete(id, callback)
  self:_request("thread/delete", id, nil, callback)
end

M.new = Store.new
M.Store = Store
return M
