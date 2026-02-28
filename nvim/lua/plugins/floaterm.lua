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

    -- Use tmux popup with a persistent session — the copilot binary's TUI
    -- cursor-redraw is incompatible with neovim's libvterm, so we use tmux's
    -- real terminal emulator instead. The copilot session survives popup close.
    local function copilot_toggle()
      local git_dir = vim.fn.system('git rev-parse --show-toplevel 2>/dev/null'):gsub('\n', '')
      local dir = git_dir ~= '' and git_dir or vim.fn.getcwd()
      -- Create a detached copilot session if one doesn't exist
      vim.fn.system(string.format('tmux has-session -t copilot 2>/dev/null || tmux new-session -d -s copilot -c %s copilot', vim.fn.shellescape(dir)))
      -- Bind Escape to detach while the popup is open
      vim.fn.system 'tmux bind-key -T root Escape detach-client'
      -- Popup attaches to the session; Escape closes popup, copilot keeps running
      vim.fn.system 'tmux display-popup -E -w 80% -h 80% "tmux attach-session -t copilot"'
      -- Unbind Escape after popup closes so it doesn't interfere with normal tmux
      vim.fn.system 'tmux unbind-key -T root Escape'
    end

    vim.keymap.set('n', '<leader>,', copilot_toggle, { noremap = true, silent = true, desc = 'Toggle GitHub Copilot Terminal' })
  end,
}
