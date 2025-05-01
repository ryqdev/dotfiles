local which_key = require "which-key"
local builtin = require('telescope.builtin')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }

    local mappings = {
      g = {
        d = { vim.lsp.buf.definition, "Go to definition" },
        l = { vim.diagnostic.open_float, "Open diagnostic float" },
        r = { vim.lsp.buf.references, "Go to references" },
        i = { vim.lsp.buf.implementation, "Go to implementation" },
      },
      K = { vim.lsp.buf.hover, "Show hover information" },
      ["<leader>"] = {
        l = {
          name = "LSP",
          a = { vim.lsp.buf.code_action, "Code action" },
          r = { vim.lsp.buf.references, "References" },
          n = { vim.lsp.buf.rename, "Rename" },
          w = { vim.lsp.buf.workspace_symbol, "Workspace symbol" },
          d = { vim.diagnostic.open_float, "Open diagnostic float" },
        },
      },
      ["[d"] = { vim.diagnostic.goto_next, "Go to next diagnostic" },
      ["]d"] = { vim.diagnostic.goto_prev, "Go to previous diagnostic" },
    }

    which_key.register(mappings, opts)

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = event.buf,
      callback = function()
        vim.lsp.buf.format { async = false, id = event.data.client_id }
      end

    })
  end,
})

local non_lsp_mappings = {
  ["<leader>"] = {
    [" "] = { ":Telescope live_grep<CR>", "Find" },
    e = { vim.cmd.Ex, "Open file explorer" },
    p = { "\"_dP", "Paste without overwrite" },
    ["/"] = { "<Plug>(comment_toggle_linewise_current)", "Toggle comment" },
    s = { [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], "Search and replace word under cursor" },
    t = { ":Today<CR>", "Open today's note" },
    f = {
      name = "Find",
      f = { builtin.find_files, "Find files" },
      g = { builtin.git_files, "Find git files" },
      l = { builtin.live_grep, "Live grep" },
    },
    y = {
      name = "Copy",
      p = { ':let @+ = expand("%:p")<CR>', "Copy full path" },
    },
  },
  ["<C-d>"] = { "<C-d>zz", "Half page down and center" },
  ["<C-u>"] = { "<C-u>zz", "Half page up and center" },
  n = { "nzzzv", "Next search result and center" },
  N = { "Nzzzv", "Previous search result and center" },
  Q = { "<nop>", "Disable Ex mode" },
  [";"] = { builtin.buffers, "Find buffers" },
}

which_key.register(non_lsp_mappings)

vim.keymap.set('i', '<Right>', '<Right>', { noremap = true }) -- Make the right arrow behave normally in insert mode
