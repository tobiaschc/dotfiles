return {
  'ray-x/lsp_signature.nvim',

  event = 'LspAttach',

  opts = {
    handler_opts = { border = 'double' },

    doc_lines = 10,

    max_height = 12,

    max_width = function()
      return math.max(math.floor(vim.api.nvim_win_get_width(0) * 0.5), 40)
    end,

    wrap = true,

    close_timeout = 4000, --ms

    fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters

    always_trigger = false, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58

    zindex = 2000,

    padding = '', -- character to pad on left and right of signature can be ' ', or '|'  etc

    transparency = nil,

    floating_window = true,

    hint_enable = false,

    floating_window_off_x = -2,

    floating_window_off_y = function()
      local pumheight = vim.o.pumheight
      local winline = vim.fn.winline() -- cursor row within window
      local winheight = vim.fn.winheight(0) -- current window height

      if winline - 1 < pumheight then
        return pumheight + 2
      end

      if winheight - winline < pumheight then
        return -pumheight - 2
      end

      return 0
    end,
  },

  config = function(_, opts)
    require('lsp_signature').setup(opts)
  end,
}
