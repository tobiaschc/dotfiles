return {
  'shaunsingh/nord.nvim',
  lazy = true,
  priority = 1000,
  config = function()
    -- Example config in lua
    vim.g.nord_contrast = true
    vim.g.nord_borders = false
    vim.g.nord_disable_background = true
    vim.g.nord_italic = false
    vim.g.nord_uniform_diff_background = true
    vim.g.nord_bold = false

    -- Colorscheme is applied by the theme switcher

    -- Toggle background transparency
    local style = require 'functions.style'
    local transparency_default = true

    vim.keymap.set('n', '<leader>tb', function()
      transparency_default = not transparency_default
      style.toggle_transparency { color_scheme = 'nord', transparent = transparency_default, bg_color = '#282c34' }
    end, {
      noremap = true,
      silent = true,
      desc = '[T]oggle [B]ackground transparency',
    })
  end,
}
