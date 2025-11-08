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

    -- Custom terminal for GitHub Copilot
    local Terminal = require('toggleterm.terminal').Terminal

    local copilot = Terminal:new {
      cmd = 'copilot',
      dir = 'git_dir',
      start_in_insert = true,
      direction = 'float',
      float_opts = {
        border = 'rounded',
        width = math.floor(vim.o.columns * 0.8),
        height = math.floor(vim.o.lines * 0.8),
      },
      on_open = function(term)
        local optscp = { buffer = term.bufnr, noremap = true, silent = true }
        -- Exit terminal mode and close window
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], optscp)
        vim.keymap.set('n', 'q', ':q<CR>', optscp)
        vim.keymap.set('n', '<esc>', ':q<CR>', optscp)
      end,
    }

    function _copilot_toggle()
      copilot:toggle()
    end

    vim.api.nvim_set_keymap('n', '<leader>,', '<cmd>lua _copilot_toggle()<CR>', { noremap = true, silent = true, desc = 'Toggle GitHub Copilot Terminal' })
  end,
}
