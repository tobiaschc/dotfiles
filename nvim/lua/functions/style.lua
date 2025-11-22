local M = {}

local function set_background(color)
  vim.api.nvim_set_hl(0, 'Normal', { bg = color })
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = color })
  vim.api.nvim_set_hl(0, 'FloatBorder', { bg = color })
  vim.api.nvim_set_hl(0, 'Pmenu', { bg = color })
end

function M.toggle_transparency(opts)
  opts = opts or {}
  local color_scheme = opts.color_scheme or 'default'
  local transparent = opts.transparent or false
  local bg_color = opts.bg_color

  vim.cmd('colorscheme ' .. color_scheme)

  if not transparent then
    if bg_color then
      set_background(bg_color)
    end
  else
    set_background 'none'
  end
end

return M
