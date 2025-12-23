local which_key = require "which-key"
local builtin = require('telescope.builtin')

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }

    local mappings = {
      { "gd",         vim.lsp.buf.definition,       desc = "Go to definition",       buffer = event.buf },
      { "gl",         vim.diagnostic.open_float,    desc = "Open diagnostic float",  buffer = event.buf },
      { "gr",         vim.lsp.buf.references,       desc = "Go to references",       buffer = event.buf },
      { "gi",         vim.lsp.buf.implementation,   desc = "Go to implementation",   buffer = event.buf },
      { "K",          vim.lsp.buf.hover,            desc = "Show hover information", buffer = event.buf },
      { "<leader>ln", vim.lsp.buf.rename,           desc = "Rename",                 buffer = event.buf },
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
  { "<leader> ",  ":Telescope live_grep<CR>",                             desc = "Find" },
  { "<leader>f",  builtin.find_files,                                     desc = "Find files" },
  { "<leader>go", function() require("gitlinker").get_buf_range_url("n") end, desc = "Open git link" },
  { "<leader>go", function() require("gitlinker").get_buf_range_url("v") end, desc = "Open git link", mode = "v" },
  { "<leader>gb", function() require("gitsigns").blame() end,             desc = "Git blame file" },
  { "<leader>/",  "<Plug>(comment_toggle_linewise_current)",              desc = "Toggle comment" },
  { "<leader>/",  "<Plug>(comment_toggle_linewise_visual)",               desc = "Toggle comment", mode = "v" },
  { "<C-d>",      "<C-d>zz",                                              desc = "Half page down and center" },
  { "<C-u>",      "<C-u>zz",                                              desc = "Half page up and center" },
  { "n",          "nzzzv",                                                desc = "Next search result and center" },
  { "N",          "Nzzzv",                                                desc = "Previous search result and center" },
  { "Q",          "<nop>",                                                desc = "Disable Ex mode" },
  { ";",          builtin.buffers,                                        desc = "Find buffers" },
}

which_key.add(non_lsp_mappings)

vim.keymap.set('i', '<Right>', '<Right>', { noremap = true }) -- Make the right arrow behave normally in insert mode
