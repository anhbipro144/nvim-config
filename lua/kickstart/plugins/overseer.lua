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

    overseer.register_template {
      name = 'BFF',
      desc = 'Run the NPRD BFF from the active Git worktree',
      builder = function()
        local worktree_root = vim.fn.getcwd()

        return {
          name = string.format('BFF [%s]', vim.fn.fnamemodify(worktree_root, ':t')),
          cmd = { '/home/neo/.nix-profile/bin/mise', 'exec', '--', 'yarn', 'start:local' },
          cwd = vim.fs.joinpath(worktree_root, 'bff'),
          components = { 'default' },
        }
      end,
    }

    overseer.register_template {
      name = 'Backend',
      desc = 'Run the NPRD gRPC backend from the active Git worktree',
      builder = function()
        local worktree_root = vim.fn.getcwd()
        local backend_dir = vim.fs.joinpath(worktree_root, 'backend')

        return {
          name = string.format('Backend [%s]', vim.fn.fnamemodify(worktree_root, ':t')),
          cmd = { vim.fs.joinpath(backend_dir, '.venv', 'bin', 'python'), 'main.py', '3011' },
          cwd = backend_dir,
          env = {
            PWD = backend_dir,
            RUN_ENVIRONMENT = 'local',
          },
          components = { 'default' },
        }
      end,
    }

    overseer.register_template {
      name = 'Cloud SQL Proxy (dev)',
      desc = 'Run the development Cloud SQL Proxy on port 5435',
      builder = function()
        return {
          cmd = {
            '/home/neo/personal/work/cloud-sql-proxy',
            'one-global-mtfaber-test:asia-southeast1:sea1-dev-nprd-db',
            '--port',
            '5435',
          },
          components = { 'default' },
        }
      end,
    }

    overseer.register_template {
      name = 'AlloyDB Auth Proxy (UAT)',
      desc = 'Run the UAT AlloyDB Auth Proxy on port 5000',
      builder = function()
        return {
          cmd = {
            '/home/neo/.nix-profile/bin/alloydb-auth-proxy',
            'projects/one-global-ods-uat/locations/asia-southeast1/clusters/sea1-uat-ods-db-cluster/instances/sea1-uat-ods-db-primary?port=5000',
            '--public-ip',
            '--auto-iam-authn',
          },
          components = { 'default' },
        }
      end,
    }
  end,
}
