-- Keymaps for better default experience

-- Set leader key
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- For conciseness
local opts = { noremap = true, silent = true }

-- Disable the spacebar key's default behavior in Normal and Visual modes
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Allow moving the cursor through wrapped lines with j, k
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- clear highlights
vim.keymap.set('n', '<Esc>', ':noh<CR>', opts)

-- save file
vim.keymap.set('n', '<C-s>', '<cmd> w <CR>', opts)

-- save file without auto-formatting
vim.keymap.set('n', '<leader>sn', '<cmd>noautocmd w <CR>', opts)

-- quit file
vim.keymap.set('n', '<C-q>', '<cmd> q <CR>', opts)

-- delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts)
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts)

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Resize with arrows
vim.keymap.set('n', '<Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', ':vertical resize +2<CR>', opts)

-- Buffers
vim.keymap.set('n', '<Tab>', ':bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', ':bprevious<CR>', opts)
vim.keymap.set('n', '<C-i>', '<C-i>', opts) -- to restore jump forward
vim.keymap.set('n', '<leader>x', ':Bdelete!<CR>', opts) -- close buffer
-- vim.keymap.set('n', '<leader>b', '<cmd> enew <CR>', opts) -- new buffer

-- Window management
vim.keymap.set('n', '<leader>/', '<C-w>v', opts) -- split window vertically
vim.keymap.set('n', '<leader>-', '<C-w>s', opts) -- split window horizontally
vim.keymap.set('n', '<leader>se', '<C-w>=', opts) -- make split windows equal width & height
vim.keymap.set('n', '<leader>xs', ':close<CR>', opts) -- close current split window

-- Navigate between splits
vim.keymap.set('n', '<C-k>', ':wincmd k<CR>', opts)
vim.keymap.set('n', '<C-j>', ':wincmd j<CR>', opts)
vim.keymap.set('n', '<C-h>', ':wincmd h<CR>', opts)
vim.keymap.set('n', '<C-l>', ':wincmd l<CR>', opts)

-- Tabs
-- vim.keymap.set('n', '<leader>to', ':tabnew<CR>', opts) -- open new tab
-- vim.keymap.set('n', '<leader>tx', ':tabclose<CR>', opts) -- close current tab
-- vim.keymap.set('n', '<leader>tn', ':tabn<CR>', opts) --  go to next tab
-- vim.keymap.set('n', '<leader>tp', ':tabp<CR>', opts) --  go to previous tab

-- Toggle line wrapping
vim.keymap.set('n', '<leader>tw', '<cmd>set wrap!<CR>', { noremap = true, silent = true, desc = '[T]oggle [W]rap' })

-- Press jk fast to exit insert mode
vim.keymap.set('i', 'jk', '<ESC>', opts)
vim.keymap.set('i', 'kj', '<ESC>', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Move text up and down
vim.keymap.set('v', '<A-j>', ':m .+1<CR>==', opts)
vim.keymap.set('v', '<A-k>', ':m .-2<CR>==', opts)

-- Keep last yanked when pasting
vim.keymap.set('v', 'p', '"_dP', opts)

local function wrap_word_in_backticks()
  local keys = vim.api.nvim_replace_termcodes('viwc`<C-r>"`<Esc>', true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end

vim.keymap.set('n', '<leader>c', wrap_word_in_backticks, {
  noremap = true,
  silent = true,
  desc = '[C]ode `word`',
})

vim.keymap.set('x', '<leader>c', 'c`<C-r>"`<Esc>', {
  noremap = true,
  silent = true,
  desc = '[C]ode `selection',
})

vim.keymap.set('n', '<leader>rw', '*``cgn', { noremap = true, silent = true, desc = '[R]eplace [W]ord under cursor' })

-- Explicitly yank to system clipboard (highlighted and entire row)
vim.keymap.set({ 'n', 'v' }, '<leader>y', [["+y]])
vim.keymap.set('n', '<leader>Y', [["+Y]])

-- Toggle diagnostics
local diagnostics_active = true

vim.keymap.set('n', '<leader>td', function()
  diagnostics_active = not diagnostics_active

  if diagnostics_active then
    vim.diagnostic.enable(true)
  else
    vim.diagnostic.enable(false)
  end
end, { desc = '[T]oggle [D]iagnostics' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic message' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic message' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
-- Telescope-powered diagnostics navigation
vim.keymap.set('n', '<leader>q', function()
  require('telescope.builtin').diagnostics { bufnr = 0 }
end, { desc = '[Q]uick [D]iagnostics (buffer)' })

-- Extra Telescope diagnostics pickers
vim.keymap.set('n', '<leader>dd', function()
  require('telescope.builtin').diagnostics { bufnr = 0 }
end, { desc = 'Diagnostics (buffer)' })

vim.keymap.set('n', '<leader>dD', function()
  require('telescope.builtin').diagnostics()
end, { desc = 'Diagnostics (workspace)' })

vim.keymap.set('n', '<leader>de', function()
  require('telescope.builtin').diagnostics { severity = vim.diagnostic.severity.ERROR }
end, { desc = 'Diagnostics: errors' })

vim.keymap.set('n', '<leader>dw', function()
  require('telescope.builtin').diagnostics { severity = { min = vim.diagnostic.severity.WARN } }
end, { desc = 'Diagnostics: warn+' })

-- Save and load session
vim.keymap.set('n', '<leader>ss', ':mksession! .session.vim<CR>', { noremap = true, silent = false })
vim.keymap.set('n', '<leader>sl', ':source .session.vim<CR>', { noremap = true, silent = false })

-- Close fugitive windows with only ESC
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'fugitive',
  callback = function()
    vim.keymap.set('n', '<Esc>', function()
      if vim.v.hlsearch == 1 then
        vim.cmd 'nohlsearch'
      else
        vim.cmd 'q'
      end
    end, { buffer = true, silent = true })
  end,
})
