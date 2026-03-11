return {
  {
    'bjarneo/ethereal.nvim',
    priority = 1000,
    config = function()
      local colors = require 'ethereal.colorscheme'

      local ethereal_bg = colors.bg

      -- Toggle background transparency
      local style = require 'functions.style'
      local transparency_default = false

      vim.keymap.set('n', '<leader>tb', function()
        transparency_default = not transparency_default
        style.toggle_transparency { color_scheme = 'ethereal', transparent = transparency_default, bg_color = ethereal_bg }
      end, {
        noremap = true,
        silent = true,
        desc = '[T]oggle [B]ackground transparency',
      })
    end,
  },
}
