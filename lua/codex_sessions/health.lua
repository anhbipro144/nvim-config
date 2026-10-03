local M = {}

function M.check()
  vim.health.start("Codex Sessions")
  if vim.fn.has("nvim-0.10") == 1 then
    vim.health.ok("Neovim " .. vim.version().major .. "." .. vim.version().minor .. "." .. vim.version().patch)
  else
    vim.health.error("Neovim 0.10 or newer is required")
  end

  local command = require("codex_sessions.config").values.codex.command
  local executable = type(command) == "table" and command[1] or command
  if vim.fn.executable(executable) == 1 then
    vim.health.ok(executable .. " executable found")
    local version = vim.fn.system({ executable, "--version" }):gsub("%s+$", "")
    if vim.v.shell_error == 0 then vim.health.ok(version) else vim.health.warn("could not run " .. executable .. " --version") end
    local job = vim.fn.jobstart({ executable, "app-server", "--stdio" }, { stdin = "pipe", stdout_buffered = true, stderr_buffered = true })
    if job > 0 then
      vim.fn.jobstop(job)
      vim.health.ok("codex app-server can be started")
    else
      vim.health.error("codex app-server could not be started")
    end
  else
    vim.health.error(executable .. " executable not found")
  end

  if #vim.api.nvim_get_runtime_file("lua/telescope/init.lua", true) > 0 then
    vim.health.ok("Telescope available (optional)")
  else
    vim.health.info("Telescope unavailable; using vim.ui.select")
  end
  if #vim.api.nvim_get_runtime_file("lua/codecompanion/init.lua", true) > 0 then
    vim.health.ok("CodeCompanion available (optional)")
  else
    vim.health.info("CodeCompanion unavailable; standalone mode only")
  end
end

return M
