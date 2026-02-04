return {
  "navarasu/onedark.nvim",
  priority = 1000, -- make sure to load this before all the other start plugins
  config = function()
    local style = 'dark'
    -- Detect macOS system appearance
    local handle = io.popen('defaults read -g AppleInterfaceStyle 2>/dev/null')
    if handle then
      local result = handle:read('*a')
      handle:close()
      if not result:match('Dark') then
        style = 'light'
      end
    end

    require('onedark').setup {
      style = style,
      transparent = true,
    }
    require('onedark').load()
  end
}
