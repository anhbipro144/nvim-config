return {
  "nvim-treesitter/nvim-treesitter-textobjects",
  config = function()
    require 'nvim-treesitter.configs'.setup {
      textobjects = {
        select = {
          enable = true,

          -- Automatically jump forward to textobj, similar to targets.vim
          lookahead = true,

          keymaps = {
            -- You can use the capture groups defined in textobjects.scm
            ["af"] = "@function.outer",
            ["if"] = "@function.inner",

            ["aC"] = "@class.outer",
            ["iC"] = { query = "@class.inner", desc = "Select inner part of a class region" },


            ["am"] = "@call.outer", -- m = method/call
            ["im"] = "@call.inner",


            ["ac"] = "@conditional.outer",
            ["ic"] = "@conditional.inner",


            ["al"] = "@loop.outer",
            ["il"] = "@loop.inner",

            ["ad"] = "@comment.outer",
            ["id"] = "@comment.inner",

            ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },


            ["a="] = "@assignment.outer",
            ["i="] = "@assignment.inner",
          },
          -- You can choose the select mode (default is charwise 'v')
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * method: eg 'v' or 'o'
          -- and should return the mode ('v', 'V', or '<c-v>') or a table
          -- mapping query_strings to modes.
          selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V',  -- linewise
            ['@class.outer'] = '<c-v>', -- blockwise
          },
          -- If you set this to `true` (default is `false`) then any textobject is
          -- extended to include preceding or succeeding whitespace. Succeeding
          -- whitespace has priority in order to act similarly to eg the built-in
          -- `ap`.
          --
          -- Can also be a function which gets passed a table with the keys
          -- * query_string: eg '@function.inner'
          -- * selection_mode: eg 'v'
          -- and should return true or false
          include_surrounding_whitespace = true,
        },
      },
    }
  end
}
