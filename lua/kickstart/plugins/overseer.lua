return {
  'stevearc/overseer.nvim',
  cmd = { 'OverseerRun', 'OverseerToggle' },
  keys = {
    { '<leader>or', '<cmd>OverseerRun<cr>', desc = 'Run task' },
    { '<leader>oo', '<cmd>OverseerToggle<cr>', desc = 'Toggle task list' },
  },
  opts = {},
  config = function(_, opts)
    local overseer = require 'overseer'
    overseer.setup(opts)

    overseer.register_template {
      name = 'BFF (local)',
      desc = 'Run the NPRD BFF with its local environment',
      builder = function()
        return {
          cmd = { '/home/neo/.nix-profile/bin/mise', 'exec', '--', 'yarn', 'start:local' },
          cwd = '/home/neo/personal/work/NPRD/mixed-bee-bff/bff',
          components = { 'default' },
        }
      end,
    }

    overseer.register_template {
      name = 'Backend (local)',
      desc = 'Run the NPRD gRPC backend with its local environment',
      builder = function()
        return {
          cmd = { '/home/neo/personal/work/NPRD/mixed-bee-bff/backend/.venv/bin/python', 'main.py', '3011' },
          cwd = '/home/neo/personal/work/NPRD/mixed-bee-bff/backend',
          env = {
            PWD = '/home/neo/personal/work/NPRD/mixed-bee-bff/backend',
            RUN_ENVIRONMENT = 'local',
          },
          components = { 'default' },
        }
      end,
    }
  end,
}
