---@diagnostic disable: undefined-field
return {
  'anhbipro144/git-pipelines',
  -- dir = "/home/neo/personal/hustles/git-pipelines.nvim",
  name = "git-pipelines",
  event = 'VeryLazy',
  opts = {
    nprd_internal = {
      reviewers = {
        {
          name = 'Binh Nguyen Thanh',
          mention = 'users/103484726831388426055',
          github_login = 'binh-nguyenthanh-tpv-clv',
        },
        {
          name = 'Nguyen Thai Hoc',
          mention = 'users/108107644108402837030',
          github_login = 'hoc-nguyenthai-tpv-clv',
        },
        {
          name = 'Hoang Hieu',
          mention = 'users/114446303147312629677',
          github_login = 'hieu-nguyenhoang-tpv-clv',
        },
        {
          name = 'Huynh Nguyen Phuc',
          mention = 'users/108935238339247601921',
          github_login = 'phuc-huynh-tpv-clv',
        },
      },
    },
  },
  keys = {
    {
      '<leader>gp',
      function()
        if _G.GitPipelines then
          _G.GitPipelines.open()
        end
      end,
      desc = 'Open Git pipelines',
    },
    {
      '<leader>gP',
      function()
        if _G.GitPipelines then
          _G.GitPipelines.refresh(true)
        end
      end,
      desc = 'Refresh Git pipelines',
    },
  },
  config = function(_, opts)
    require('git-pipelines').setup(opts)
  end,
}
