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

    local function enable_ts_highlight(buf)
      if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "" then
        return
      end

      vim.api.nvim_buf_call(buf, function()
        pcall(vim.cmd, "TSBufEnable highlight")
      end)
    end

    local group = vim.api.nvim_create_augroup("TreesitterHighlightFix", { clear = true })

    vim.api.nvim_create_autocmd("BufEnter", {
      group = group,
      callback = function(args)
        enable_ts_highlight(args.buf)
      end,
    })

    -- Ensure the initial buffer is highlighted even if treesitter loads late.
    if vim.bo.filetype ~= "" then
      enable_ts_highlight(0)
    else
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        buffer = 0,
        once = true,
        callback = function(args)
          enable_ts_highlight(args.buf)
        end,
      })
    end
  end
}
