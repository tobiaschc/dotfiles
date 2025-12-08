require 'core.keymaps'
require 'core.options'
require 'core.snippets'

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

-- Determine the theme to use based on the NVIM_THEME environment variable
local default_theme = 'nord'
local env_var_nvim_theme = os.getenv 'NVIM_THEME' or default_theme

-- Define a table of theme modules
local themes = {
  nord = 'themes.nord',
  ethereal = 'themes.ethereal',
  matteblack = 'themes.matteblack',
}

vim.opt.rtp:prepend(lazypath)
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup {
  require 'plugins.bufferline',
  require 'plugins.neotree',
  require(themes[env_var_nvim_theme]),
  require 'plugins.lualine',
  require 'plugins.treesitter',
  require 'plugins.telescope',
  require 'plugins.lsp',
  require 'plugins.autocompletion',
  require 'plugins.none-ls',
  require 'plugins.alpha',
  require 'plugins.indent-blanklines',
  require 'plugins.git-conf',
  require 'plugins.misc',
  require 'plugins.comments',
  require 'plugins.floaterm',
  require 'plugins.lazygit',
  -- require 'plugins.debug',
  require 'plugins.lsp_signature',
  require 'plugins.markdown',
  require 'plugins.octo',
  require 'plugins.obsidian',
}
