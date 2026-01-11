return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  lazy = false, -- Load immediately to prevent highlight race condition
  priority = 900, -- Load after colorscheme (1000) but before other plugins
  config = function()
    local configs = require("nvim-treesitter.configs")
    local parsers = require("nvim-treesitter.parsers")

    configs.setup({
      ensure_installed = {
        "c", "lua", "vim", "vimdoc", "elixir", "javascript", "html", "python", "typescript"
      },
      sync_install = false,
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
    })

    local function enable_ts_highlight(buf)
      if vim.bo[buf].buftype ~= "" or vim.bo[buf].filetype == "" then
        return
      end

      local lang = parsers.get_buf_lang(buf)
      if not lang or not parsers.has_parser(lang) then
        return
      end

      vim.api.nvim_buf_call(buf, function()
        pcall(vim.cmd, "TSBufEnable highlight")
      end)
    end

    local group = vim.api.nvim_create_augroup("TreesitterHighlightFix", { clear = true })

    vim.api.nvim_create_autocmd({ "BufEnter", "FileType" }, {
      group = group,
      callback = function(args)
        enable_ts_highlight(args.buf)
      end,
    })

    -- Ensure the initial buffer is highlighted even if treesitter loads late.
    enable_ts_highlight(0)
  end
}
