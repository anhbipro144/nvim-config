return {
  "emrearmagan/atlas.nvim",
  dependencies = {
    "MeanderingProgrammer/render-markdown.nvim", -- optional but recommended (Jira)
  },
  config = function()
    local function copy_jira_issue_link()
      vim.ui.input({ prompt = "Jira issue id: " }, function(issue_id)
        if not issue_id or issue_id == "" then
          return
        end

        issue_id = vim.trim(issue_id):upper():gsub("^CNPRD%-", "")
        if not issue_id:match("^%d+$") then
          vim.notify("Invalid Jira issue id", vim.log.levels.ERROR)
          return
        end

        local issue_key = string.format("CNPRD-%s", issue_id)
        local link = string.format("https://oneline.atlassian.net/browse/%s", issue_key)
        local formats = {
          {
            label = "Markdown: [title](link)",
            format = function(done)
              vim.ui.input({ prompt = "Title: ", default = issue_key }, function(input_title)
                if not input_title or input_title == "" then
                  return
                end

                done(string.format("[%s](%s)", input_title, link))
              end)
            end,
          },
          {
            label = "Google Chat: [title](link)",
            format = function(done)
              done(string.format("[%s](%s)", issue_key, link))
            end,
          },
          {
            label = "Plain link",
            format = function(done)
              done(link)
            end,
          },
          {
            label = "Title and link",
            format = function(done)
              done(string.format("%s %s", issue_key, link))
            end,
          },
          {
            label = "Jira issue key: CNPRD-number",
            format = function(done)
              done(issue_key)
            end,
          },
        }

        vim.ui.select(formats, {
          prompt = "Jira link format:",
          format_item = function(item)
            return item.label
          end,
        }, function(choice)
          if not choice then
            return
          end

          choice.format(function(text)
            vim.fn.setreg('"', text)
            vim.fn.setreg("+", text)
            vim.notify("Jira link copied. Press p to paste.")
          end)
        end)
      end)
    end

    vim.keymap.set("n", "<leader>jy", copy_jira_issue_link, { desc = "Generate Jira issue link" })
    vim.keymap.set("n", "<leader>jo", "<cmd>AtlasJira<CR>", { desc = "Open Atlas Jira" })

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
            name = "My all ticket",
            key = "A",
            jql = "project = CNPRD AND assignee = currentUser()  ORDER BY updated DESC",
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
