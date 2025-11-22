return {
  {
    -- Powerful Git integration for Vim
    'tpope/vim-fugitive',
    config = function()
      require 'functions.gitfugitive-float'
    end,
    keys = {
      { '<leader>gg', ':Gfloat<CR>', desc = '[G]it Float Tree' },
      { '<leader>gd', ':Gvdiffsplit<CR>', desc = '[G]it Vertical Diff' },
    },
  },
  {
    -- GitHub integration for vim-fugitive
    'tpope/vim-rhubarb',
  },
  {
    -- Adds git related signs to the gutter, as well as utilities for managing changes
    'lewis6991/gitsigns.nvim',
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
        untracked = { text = '┆' },
      },
      signs_staged = {
        add = { text = '✔' },
        change = { text = '✔' },
        delete = { text = '✔' },
        topdelete = { text = '✔' },
        changedelete = { text = '✔' },
        untracked = { text = '✔' },
      },
      on_attach = function(bufnr)
        local gs = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', '<leader>ghn', function()
          gs.nav_hunk 'next'
        end, { desc = '[G]it [H]unk [N]ext' })

        map('n', '<leader>ghp', function()
          gs.nav_hunk 'prev'
        end, { desc = '[G]it [H]unk [P]rev' })

        -- Actions
        map('n', '<leader>ghs', gs.stage_hunk, { desc = '[G]it [H]unk [S]tage' })
        map('n', '<leader>ghr', gs.reset_hunk, { desc = '[G]it [H]unk [R]eset' })
        map('v', '<leader>ghs', function()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[G]it [H]unk [S]tage' })
        map('v', '<leader>ghr', function()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end, { desc = '[G]it [H]unk [R]eset' })
        map('n', '<leader>ghS', gs.stage_buffer, { desc = '[G]it [H]unk [S]tage Buffer' })
        map('n', '<leader>ghR', gs.reset_buffer, { desc = '[G]it [H]unk [R]eset Buffer' })
        map('n', '<leader>ghP', gs.preview_hunk, { desc = '[G]it [H]unk [P]review' })
        map('n', '<leader>ghi', gs.preview_hunk_inline, { desc = '[G]it [H]unk [I]nline Preview' })
        map('n', '<leader>gb', function()
          gs.blame_line { full = true }
        end, { desc = '[G]it [B]lame' })
        map('n', '<leader>ghd', gs.diffthis, { desc = '[G]it [D]iff' })
        map('n', '<leader>ghD', function()
          gs.diffthis '~'
        end, { desc = '[G]it [D]iff Previous' })

        -- Text object
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end,
    },
  },
}
