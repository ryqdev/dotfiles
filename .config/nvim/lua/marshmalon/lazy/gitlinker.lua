return {
  "ruifm/gitlinker.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    require("gitlinker").setup({
      opts = {
        action_callback = require("gitlinker.actions").open_in_browser,
        print_url = false,
      },
    })
  end
}
