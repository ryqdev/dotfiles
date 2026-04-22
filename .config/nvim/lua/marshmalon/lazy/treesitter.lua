return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate",
  config = function()
    local ensure_installed = {
      "c", "lua", "vim", "vimdoc", "elixir",
      "javascript", "html", "python", "typescript", "rust",
    }

    require("nvim-treesitter").install(ensure_installed)

    local group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true })

    vim.api.nvim_create_autocmd("FileType", {
      group = group,
      callback = function(args)
        local buf = args.buf
        if vim.bo[buf].buftype ~= "" then
          return
        end

        local ft = vim.bo[buf].filetype
        local lang = vim.treesitter.language.get_lang(ft) or ft
        if not lang or lang == "" then
          return
        end

        local ok = pcall(vim.treesitter.start, buf, lang)
        if ok then
          vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
