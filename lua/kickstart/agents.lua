local M = {}

local agents_by_git_common_dir = {
  ["/home/neo/personal/work/NPRD/fe-bare"] = "/home/neo/.codex/agents/nprd-frontend.md",
  ["/home/neo/personal/work/NPRD/be-bare"] = "/home/neo/.codex/agents/nprd-backend.md",
}

local frontend_git_common_dir = "/home/neo/personal/work/NPRD/fe-bare"

---@param worktree_path string
---@return string|nil
local function get_git_common_dir(worktree_path)
  local result = vim.system({
    "git",
    "-C",
    worktree_path,
    "rev-parse",
    "--path-format=absolute",
    "--git-common-dir",
  }, { text = true }):wait()

  if result.code ~= 0 then
    return nil
  end

  return vim.trim(result.stdout)
end

---@param worktree_path string
function M.copy_for_worktree(worktree_path)
  local destination = vim.fs.joinpath(vim.fs.normalize(worktree_path), "AGENTS.md")

  if vim.uv.fs_stat(destination) then
    return
  end

  local git_common_dir = get_git_common_dir(worktree_path)
  local source = git_common_dir and agents_by_git_common_dir[git_common_dir]

  if not source then
    return
  end

  if not vim.uv.fs_stat(source) then
    vim.notify(
      string.format("No AGENTS.md template found for %s: %s", git_common_dir, source),
      vim.log.levels.WARN
    )
    return
  end

  local copied, err = vim.uv.fs_copyfile(source, destination)

  if not copied then
    vim.notify(string.format("Failed to copy AGENTS.md: %s", err), vim.log.levels.ERROR)
  end
end

---@param worktree_path string
function M.copy_frontend_env_for_worktree(worktree_path)
  local git_common_dir = get_git_common_dir(worktree_path)

  if git_common_dir ~= frontend_git_common_dir then
    return
  end

  local normalized_worktree_path = vim.fs.normalize(worktree_path)
  local source = vim.fs.joinpath(normalized_worktree_path, "env", ".env.development")
  local destination = vim.fs.joinpath(normalized_worktree_path, "env", ".env.local")

  if vim.uv.fs_stat(destination) then
    return
  end

  if not vim.uv.fs_stat(source) then
    vim.notify(
      string.format("No env/.env.development file found in frontend worktree: %s", source),
      vim.log.levels.WARN
    )
    return
  end

  local copied, err = vim.uv.fs_copyfile(source, destination)

  if not copied then
    vim.notify(string.format("Failed to copy env/.env.local: %s", err), vim.log.levels.ERROR)
  end
end

return M
