local which_key = require "which-key"
local builtin = require('telescope.builtin')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }

    local mappings = {
      { "gd", vim.lsp.buf.definition, desc = "Go to definition", buffer = event.buf },
      { "gl", vim.diagnostic.open_float, desc = "Open diagnostic float", buffer = event.buf },
      { "gr", vim.lsp.buf.references, desc = "Go to references", buffer = event.buf },
      { "gi", vim.lsp.buf.implementation, desc = "Go to implementation", buffer = event.buf },
      { "K", vim.lsp.buf.hover, desc = "Show hover information", buffer = event.buf },
      { "<leader>l", group = "LSP", buffer = event.buf },
      { "<leader>la", vim.lsp.buf.code_action, desc = "Code action", buffer = event.buf },
      { "<leader>lr", vim.lsp.buf.references, desc = "References", buffer = event.buf },
      { "<leader>ln", vim.lsp.buf.rename, desc = "Rename", buffer = event.buf },
      { "<leader>lw", vim.lsp.buf.workspace_symbol, desc = "Workspace symbol", buffer = event.buf },
      { "<leader>ld", vim.diagnostic.open_float, desc = "Open diagnostic float", buffer = event.buf },
      { "[d", vim.diagnostic.goto_next, desc = "Go to next diagnostic", buffer = event.buf },
      { "]d", vim.diagnostic.goto_prev, desc = "Go to previous diagnostic", buffer = event.buf },
    }

    which_key.add(mappings)

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = event.buf,
      callback = function()
        vim.lsp.buf.format { async = false, id = event.data.client_id }
      end

    })
  end,
})

local non_lsp_mappings = {
  { "<leader> ", ":Telescope live_grep<CR>", desc = "Find" },
  { "<leader>e", vim.cmd.Ex, desc = "Open file explorer" },
  { "<leader>p", "\"_dP", desc = "Paste without overwrite" },
  { "<leader>/", "<Plug>(comment_toggle_linewise_current)", desc = "Toggle comment" },
  { "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], desc = "Search and replace word under cursor" },
  { "<leader>t", ":Today<CR>", desc = "Open today's note" },
  { "<leader>f", group = "Find" },
  { "<leader>ff", builtin.find_files, desc = "Find files" },
  { "<leader>fg", builtin.git_files, desc = "Find git files" },
  { "<leader>fl", builtin.live_grep, desc = "Live grep" },
  { "<leader>y", group = "Copy" },
  { "<leader>yp", ':let @+ = expand("%:p")<CR>', desc = "Copy full path" },
  { "<C-d>", "<C-d>zz", desc = "Half page down and center" },
  { "<C-u>", "<C-u>zz", desc = "Half page up and center" },
  { "n", "nzzzv", desc = "Next search result and center" },
  { "N", "Nzzzv", desc = "Previous search result and center" },
  { "Q", "<nop>", desc = "Disable Ex mode" },
  { ";", builtin.buffers, desc = "Find buffers" },
}

which_key.add(non_lsp_mappings)

vim.keymap.set('i', '<Right>', '<Right>', { noremap = true }) -- Make the right arrow behave normally in insert mode
