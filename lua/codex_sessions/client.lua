local M = {}
local Client = {}
Client.__index = Client

local function invoke(callback, ...)
  if callback then callback(...) end
end

function Client.new(opts)
  opts = opts or {}
  return setmetatable({
    command = opts.command or "codex",
    version = opts.version or "0.1.0",
    debug = opts.debug == true,
    jobstart = opts.jobstart or vim.fn.jobstart,
    chansend = opts.chansend or vim.fn.chansend,
    jobstop = opts.jobstop or vim.fn.jobstop,
    on_notification = opts.on_notification,
    on_protocol_error = opts.on_protocol_error,
    state = "stopped",
    next_id = 0,
    pending = {},
    queued = {},
    start_waiters = {},
    buffer = "",
  }, Client)
end

function Client:_log(message)
  if self.debug then
    vim.notify("Codex Sessions [debug]: " .. message, vim.log.levels.DEBUG)
  end
end

function Client:_fail_all(err)
  local pending = self.pending
  self.pending = {}
  for _, callback in pairs(pending) do invoke(callback, nil, err) end

  local queued = self.queued
  self.queued = {}
  for _, request in ipairs(queued) do invoke(request.callback, nil, err) end
end

function Client:_failed(err)
  local job_id = self.job_id
  self.state = "stopped"
  self.initialized = nil
  self.job_id = nil
  local waiters = self.start_waiters
  self.start_waiters = {}
  for _, callback in ipairs(waiters) do invoke(callback, false, err) end
  self:_fail_all(err)
  if job_id then pcall(self.jobstop, job_id) end
end

function Client:_on_exit(job_id, code, signal)
  self:_log(string.format("app-server exited (code=%s signal=%s)", code or "?", signal or "?"))
  if self.stopping_job_id == job_id then
    self.stopping_job_id = nil
    local stopped = self.stop_waiters or {}
    self.stop_waiters = nil
    for _, callback in ipairs(stopped) do invoke(callback) end
  elseif self.job_id == job_id and self.state ~= "stopped" then
    self:_failed({ message = "app-server exited unexpectedly" })
  end
end

function Client:_on_stderr(data)
  if self.debug and type(data) == "table" then
    for _, line in ipairs(data) do
      if line ~= "" then self:_log("stderr: " .. line:sub(1, 200)) end
    end
  end
end

function Client:_send(message)
  local ok, encoded = pcall(vim.json.encode, message)
  if not ok then return false, { message = "failed to encode JSON-RPC request" } end
  local sent = self.chansend(self.job_id, encoded .. "\n")
  if sent == 0 or sent == false then
    return false, { message = "failed to write to app-server" }
  end
  return true
end

function Client:_send_notification(method, params)
  local ok, err = self:_send({ jsonrpc = "2.0", method = method, params = params })
  if not ok then self:_failed(err) end
  return ok
end

function Client:_request_now(method, params, callback)
  self.next_id = self.next_id + 1
  local id = self.next_id
  self.pending[id] = callback
  self:_log("request " .. id .. " " .. method)
  local ok, err = self:_send({ jsonrpc = "2.0", id = id, method = method, params = params or {} })
  if not ok then
    self.pending[id] = nil
    invoke(callback, nil, err)
  end
end

function Client:_flush_queue()
  local queued = self.queued
  self.queued = {}
  for _, request in ipairs(queued) do
    self:_request_now(request.method, request.params, request.callback)
  end
end

function Client:_start_process()
  local command = type(self.command) == "table" and vim.deepcopy(self.command) or { self.command }
  vim.list_extend(command, { "app-server", "--stdio" })
  local job_id = self.jobstart(command, {
    stdin = "pipe",
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data) self:_on_stdout(data) end,
    on_stderr = function(_, data) self:_on_stderr(data) end,
    on_exit = function(job_id, code, signal) self:_on_exit(job_id, code, signal) end,
  })
  if type(job_id) ~= "number" or job_id <= 0 then
    self:_failed({ message = "codex executable not found or app-server could not start" })
    return false
  end
  self.job_id = job_id
  self:_log("started app-server")
  self:_request_now("initialize", {
    clientInfo = {
      name = "codecompanion_codex_sessions",
      title = "CodeCompanion Codex Sessions",
      version = self.version,
    },
  }, function(result, err)
    if err then
      if self.state ~= "stopped" then self:_failed(err) end
      return
    end
    self.initialized = result
    self.state = "ready"
    if not self:_send_notification("initialized", {}) then return end
    local waiters = self.start_waiters
    self.start_waiters = {}
    for _, callback in ipairs(waiters) do invoke(callback, true) end
    self:_flush_queue()
  end)
  return true
end

function Client:start(callback)
  if self.state == "ready" then return invoke(callback, true) end
  if callback then table.insert(self.start_waiters, callback) end
  if self.state == "starting" then return end
  self.state = "starting"
  self:_start_process()
end

function Client:request(method, params, callback)
  callback = callback or function() end
  if self.state == "ready" then
    return self:_request_now(method, params, callback)
  end
  table.insert(self.queued, { method = method, params = params, callback = callback })
  self:start()
end

function Client:_handle_message(message)
  if message.id ~= nil and self.pending[message.id] then
    local callback = self.pending[message.id]
    self.pending[message.id] = nil
    invoke(callback, message.result, message.error)
    return
  end
  if message.method then
    if self.on_notification then self.on_notification(message.method, message.params) end
  end
end

function Client:_on_stdout(data)
  if type(data) ~= "table" then return end
  self.buffer = self.buffer .. table.concat(data, "\n")
  while true do
    local newline = self.buffer:find("\n", 1, true)
    if not newline then break end
    local line = self.buffer:sub(1, newline - 1)
    self.buffer = self.buffer:sub(newline + 1)
    if line ~= "" then
      local ok, message = pcall(vim.json.decode, line)
      if ok and type(message) == "table" then
        self:_handle_message(message)
      elseif self.on_protocol_error then
        self.on_protocol_error("malformed JSON from app-server")
      end
    end
  end
  if self.buffer ~= "" then
    local ok, message = pcall(vim.json.decode, self.buffer)
    if ok and type(message) == "table" then
      self.buffer = ""
      self:_handle_message(message)
    end
  end
end

function Client:stop(callback)
  local job_id = self.job_id
  if callback and (job_id or self.stopping_job_id) then
    self.stop_waiters = self.stop_waiters or {}
    table.insert(self.stop_waiters, callback)
  end
  self.state = "stopped"
  self.initialized = nil
  self.job_id = nil
  self:_fail_all({ message = "app-server stopped" })
  self.start_waiters = {}
  if job_id then
    self.stopping_job_id = job_id
    self.jobstop(job_id)
  elseif callback and not self.stopping_job_id then
    callback()
  end
end

M.new = Client.new
M.Client = Client
return M
