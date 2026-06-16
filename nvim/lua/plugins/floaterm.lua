return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    start_in_insert = true,
    persist_mode = false,
    direction = 'float',
    float_opts = {
      border = 'rounded',
      width = math.floor(vim.o.columns * 0.8),
      height = math.floor(vim.o.lines * 0.8),
    },
    on_open = function(term)
      local o = { buffer = term.bufnr, noremap = true, silent = true }
      vim.keymap.set('n', 'q', '<cmd>close<CR>', o)
      vim.keymap.set('n', '<esc>', '<cmd>close<CR>', o)
    end,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local Terminal = require('toggleterm.terminal').Terminal

    local function ai_on_open(term)
      local o = { buffer = term.bufnr, noremap = true, silent = true }
      -- claude/copilot use <esc> internally, so use <C-v>/<C-q> to exit terminal mode
      vim.keymap.set('t', '<C-v>', [[<C-\><C-n>]], o)
      vim.keymap.set('t', '<C-q>', [[<C-\><C-n>]], o)
      -- Intercept OSC 52 clipboard writes so they don't leak as raw text into the input
      vim.api.nvim_create_autocmd('TermRequest', {
        buffer = term.bufnr,
        callback = function(ev)
          if not (ev.data and ev.data.sequence) then return end
          if not ev.data.sequence:find('52;', 1, true) then return end
          local b64 = ev.data.sequence:match(';([A-Za-z0-9+/=]+)$')
          if b64 and b64 ~= '?' and b64 ~= '' then
            local ok, decoded = pcall(vim.base64.decode, b64)
            if ok and decoded then
              vim.fn.setreg('+', decoded)
              vim.fn.setreg('*', decoded)
            end
          end
          return true
        end,
      })
    end

    local shell_term = Terminal:new {
      hidden = true,
      direction = 'float',
      on_open = function(term)
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], { buffer = term.bufnr, noremap = true, silent = true })
      end,
    }
    local copilot_term = Terminal:new { cmd = 'sh -c "copilot --continue || copilot"', hidden = true, direction = 'float', on_open = ai_on_open }
    local claude_term = Terminal:new { cmd = 'sh -c "claude --continue || claude"', hidden = true, direction = 'float', env = { TERM = 'xterm-256color', TMUX = '', TMUX_PANE = '' }, on_open = ai_on_open }

    local all_terms = { shell_term, copilot_term, claude_term }

    local function switch_to(target)
      for _, t in ipairs(all_terms) do
        if t ~= target and t:is_open() then t:close() end
      end
      target:toggle()
    end

    vim.keymap.set({ 'n', 't' }, '<leader>.', function() switch_to(shell_term) end, { noremap = true, silent = true, desc = 'Toggle Shell Terminal' })
    vim.keymap.set({ 'n', 't' }, '<leader>,', function() switch_to(copilot_term) end, { noremap = true, silent = true, desc = 'Toggle Copilot Terminal' })
    vim.keymap.set({ 'n', 't' }, '<leader>;', function() switch_to(claude_term) end, { noremap = true, silent = true, desc = 'Toggle Claude Terminal' })
  end,
}
