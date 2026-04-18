return {
  "navarasu/onedark.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    local function detect_style()
      local handle = io.popen('defaults read -g AppleInterfaceStyle 2>/dev/null')
      if not handle then return 'dark' end
      local result = handle:read('*a')
      handle:close()
      return result:match('Dark') and 'dark' or 'light'
    end

    local current
    local function apply(style)
      if style == current then return end
      current = style
      vim.opt.background = style
      require('onedark').setup {
        style = style,
        transparent = true,
      }
      require('onedark').load()
    end

    apply(detect_style())

    vim.api.nvim_create_autocmd({ 'FocusGained', 'VimResume' }, {
      callback = function() apply(detect_style()) end,
    })
  end
}
