return {
  'tahayvr/matteblack.nvim',
  lazy = true,
  priority = 1000,
  config = function()
    -- Toggle background transparency
    local style = require 'functions.style'
    local transparency_default = true

    vim.keymap.set('n', '<leader>tb', function()
      transparency_default = not transparency_default
      style.toggle_transparency { color_scheme = 'matteblack', transparent = transparency_default }
    end, {
      noremap = true,
      silent = true,
      desc = '[T]oggle [B]ackground transparency',
    })
  end,
}
