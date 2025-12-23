return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false, -- Load immediately to prevent highlight race condition
  priority = 900, -- Load after colorscheme (1000) but before other plugins
  config = function()
    local configs = require("nvim-treesitter.configs")

    configs.setup({
      ensure_installed = {
        "c", "lua", "vim", "vimdoc", "elixir", "javascript", "html", "python", "typescript"
      },
      sync_install = true,
      auto_install = true,
      highlight = { enable = true },
      indent = { enable = true },
    })

    -- Force re-enable treesitter highlighting on buffer enter
    -- This fixes the issue when opening files from nvim-tree after `nvim .`
    vim.api.nvim_create_autocmd("BufEnter", {
      callback = function()
        if vim.bo.buftype == "" then
          vim.cmd("TSBufEnable highlight")
        end
      end,
    })
  end
}
