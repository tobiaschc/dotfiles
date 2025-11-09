require 'core.keymaps'
require 'core.options'
require 'core.snippets'

-- Install package manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  }
end

vim.opt.rtp:prepend(lazypath)
---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)

require('lazy').setup {
  require 'plugins.bufferline',
  require 'plugins.neotree',
  require 'plugins.colortheme',
  -- require 'plugins.matteblacktheme',
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
  require 'plugins.debug',
  require 'plugins.lsp_signature',
}
