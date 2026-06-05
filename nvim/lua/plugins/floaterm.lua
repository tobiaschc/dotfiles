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
    -- Fix exit keybindings
    on_open = function(term)
      local opts = { buffer = term.bufnr, noremap = true, silent = true }
      vim.keymap.set('n', 'q', ':q<CR>', opts)
      vim.keymap.set('n', '<esc>', ':q<CR>', opts)
      -- Only bind <esc> to exit terminal mode for plain shells — claude/copilot use <esc> internally
      local passthrough = { 'claude', 'copilot' }
      local skip = false
      for _, cmd in ipairs(passthrough) do
        if term.cmd and term.cmd:match('^' .. cmd) then
          skip = true
          break
        end
      end
      if not skip then
        vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
      else
        vim.keymap.set('t', '<C-v>', [[<C-\><C-n>]], opts)
        vim.keymap.set('t', '<C-q>', [[<C-\><C-n>]], opts)
      end
    end,
  },
  config = function(_, opts)
    require('toggleterm').setup(opts)

    local Terminal = require('toggleterm.terminal').Terminal
    local shell_term = Terminal:new { hidden = true, direction = 'float' }
    local copilot_term = Terminal:new { cmd = 'copilot --continue', hidden = true, direction = 'float' }
    local claude_term = Terminal:new { cmd = 'claude --continue', hidden = true, direction = 'float', env = { TERM = 'xterm-256color' } }

    local all_terms = { shell_term, copilot_term, claude_term }

    local function switch_to(target)
      for _, t in ipairs(all_terms) do
        if t ~= target and t:is_open() then
          t:close()
        end
      end
      target:toggle()
    end

    vim.keymap.set({ 'n', 't' }, '<leader>.', function() switch_to(shell_term) end, { noremap = true, silent = true, desc = '[T]oggle Shell Terminal' })
    vim.keymap.set({ 'n', 't' }, '<leader>,', function() switch_to(copilot_term) end, { noremap = true, silent = true, desc = '[T]oggle Copilot Terminal' })
    vim.keymap.set({ 'n', 't' }, '<leader>;', function() switch_to(claude_term) end, { noremap = true, silent = true, desc = '[T]oggle Claude Terminal' })
  end,
}
