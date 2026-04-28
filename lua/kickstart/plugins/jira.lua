return {
  "emrearmagan/atlas.nvim",
  dependencies = {
    "MeanderingProgrammer/render-markdown.nvim", -- optional but recommended (Jira)
    "sindrets/diffview.nvim",                    -- optional (Bitbucket PR diff)
    "esmuellert/codediff.nvim",                  -- optional (Bitbucket PR diff alternative)
  },
  config = function()
    require("atlas").setup({
      bitbucket = {}, -- See configuration below
      jira = {
        token = os.getenv("JIRA_API_TOKEN"),
        email = os.getenv("JIRA_USER"),
        base_url = "https://oneline.atlassian.net",

        ---@type JiraViewConfig[]
        views = {
          {
            name = "My Board",
            key = "M",
            jql = "project = CNPRD AND assignee = currentUser() AND sprint IN openSprints() ORDER BY updated DESC",
          },
          {
            name = "Team Board",
            key = "T",
            jql = "project = CNPRD ORDER BY updated DESC",
          },
        },

      }, -- See configuration below
    })
  end,
}
