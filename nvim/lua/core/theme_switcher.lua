local M = {}

local THEMES = {
  nord = { plugin = 'nord.nvim', colorscheme = 'nord', lualine = 'nord' },
  ethereal = { plugin = 'ethereal.nvim', colorscheme = 'ethereal', lualine = 'ethereal' },
  matteblack = { plugin = 'matteblack.nvim', colorscheme = 'matteblack', lualine = 'matteblack' },
}

local function set_lualine_theme(theme)
  local ok, lualine = pcall(require, 'lualine')
  if not ok then
    return
  end
  -- Prefer auto, but if provided map exists use it
  local use = 'auto'
  if theme and theme ~= '' then
    use = theme
  end
  lualine.setup { options = { theme = use } }
end

function M.apply(name)
  local spec = THEMES[name]
  if not spec then
    vim.notify(('Unknown theme: %s'):format(tostring(name)), vim.log.levels.WARN, { title = 'Theme' })
    return
  end
  -- Ensure plugin is loaded
  pcall(require('lazy').load, { plugins = { spec.plugin } })
  -- Apply colorscheme
  local ok = pcall(vim.cmd.colorscheme, spec.colorscheme)
  if not ok then
    vim.notify(('Failed to set colorscheme: %s'):format(spec.colorscheme), vim.log.levels.ERROR, { title = 'Theme' })
    return
  end
  -- Update lualine theme
  set_lualine_theme(spec.lualine)
  vim.g.current_theme = name
  vim.notify(('Switched theme to %s'):format(name), vim.log.levels.INFO, { title = 'Theme' })
end

function M.select()
  local items = { 'nord', 'ethereal', 'matteblack' }
  vim.ui.select(items, { prompt = 'Switch Theme' }, function(choice)
    if choice then
      M.apply(choice)
    end
  end)
end

-- User command: :SwitchTheme [name]
vim.api.nvim_create_user_command('SwitchTheme', function(opts)
  if opts.args and opts.args ~= '' then
    M.apply(opts.args)
  else
    M.select()
  end
end, { nargs = '?' })

-- Keymap: <leader>sc -> SwitchTheme picker
vim.keymap.set('n', '<leader>sc', function()
  M.select()
end, { desc = '[S]elect [C]olorscheme' })

return M

