return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    open_mapping = [[<leader>.]],
    start_in_insert = true,
    persist_mode = false,
    direction = 'float',
    float_opts = {
      border = 'rounded',
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
    },
    -- Fix exit keybindings
    on_open = function(term)
      local opts = { buffer = term.bufnr, noremap = true, silent = true }
      -- Exit terminal mode and close window
      vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      vim.keymap.set('n', 'q', ':q<CR>', opts)
      vim.keymap.set('n', '<esc>', ':q<CR>', opts)
    end,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    -- Copilot floating terminal
    local copilot_term = require('toggleterm.terminal').Terminal:new { cmd = 'copilot', hidden = true, direction = 'float' }
    local function copilot_toggle()
      copilot_term:toggle()
    end

    vim.keymap.set('n', '<leader>,', copilot_toggle, { noremap = true, silent = true, desc = '[T]oggle GitHub Copilot Terminal' })

    -- claude floating terminal
    local claude_term = require('toggleterm.terminal').Terminal:new { cmd = 'claude', hidden = true, direction = 'float' }
    local function codex_toggle()
      claude_term:toggle()
    end

    vim.keymap.set('n', '<leader>;', codex_toggle, { noremap = true, silent = true, desc = '[T]oggle Codex Terminal' })
  end,
}
