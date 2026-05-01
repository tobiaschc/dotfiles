return {
  'epwalsh/obsidian.nvim',
  version = '*', -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/*.md"
  --   -- refer to `:h file-pattern` for more examples
  --   "BufReadPre path/to/my-vault/*.md",
  --   "BufNewFile path/to/my-vault/*.md",
  -- },
  opts = {
    workspaces = {
      {
        name = 'punk-records',
        path = '~/Documents/obsidian_vaults/punk-records',
      },
      {
        name = 'amadeus',
        path = '~/Documents/obsidian_vaults/amadeus',
      },
    },
    mappings = {
      -- toggle check-boxes.
      ['<leader>cb'] = {
        action = function()
          return require('obsidian').util.toggle_checkbox()
        end,
        opts = { buffer = true, desc = '[T]oggle [C]heck [B]ox' },
      },
      -- smart action
      ['<leader>cs'] = {
        action = function()
          return require('obsidian').util.smart_action()
        end,
        opts = { buffer = true, expr = true, desc = 'Smart Action' },
      },
    },
  },
}
