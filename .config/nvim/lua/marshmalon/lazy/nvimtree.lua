return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local function my_on_attach(bufnr)
      local api = require "nvim-tree.api"

      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- default mappings
      api.config.mappings.default_on_attach(bufnr)

      -- custom mappings
      vim.keymap.set('n', '<C-t>', api.tree.change_root_to_parent, opts('Up'))
      vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
      vim.keymap.set('n', 'l', api.node.open.edit, { buffer = bufnr, desc = "Open" })
      vim.keymap.set('n', 'h', api.node.navigate.parent_close, { buffer = bufnr, desc = "Close Directory" })
    end

    require("nvim-tree").setup(
      {
        on_attach = my_on_attach,

        filters = {
          dotfiles = false,
          git_ignored = false
        }
      }
    )
  end
}
