local builtin = require('telescope.builtin')


local function map(modes, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  if opts.silent == nil then
    opts.silent = true
  end
  vim.keymap.set(modes, lhs, rhs, opts)
end

local function copy_relative_path()
  local bufname = vim.api.nvim_buf_get_name(0)
  if bufname == "" then
    vim.notify("No file name for current buffer", vim.log.levels.WARN)
    return
  end

  local relative_path = vim.fn.fnamemodify(bufname, ":.")
  vim.v.errmsg = ""
  vim.fn.setreg("+", relative_path)
  if vim.v.errmsg == "" then
    vim.notify("Copied relative path: " .. relative_path, vim.log.levels.INFO)
    return
  end

  vim.fn.setreg('"', relative_path)
  vim.notify("Copied relative path (clipboard unavailable): " .. relative_path, vim.log.levels.WARN)
end

map("n", "<leader> ", ":Telescope live_grep<CR>", "Find")
map("n", "<leader>f", builtin.find_files, "Find files")
map("n", "<leader>go", function() require("gitlinker").get_buf_range_url("n") end, "Open git link")
map("v", "<leader>go", function() require("gitlinker").get_buf_range_url("v") end, "Open git link")
map("n", "<leader>gb", function() require("gitsigns").blame() end, "Git blame file")
map("n", "<leader>/", "<Plug>(comment_toggle_linewise_current)", "Toggle comment", { remap = true })
map("v", "<leader>/", "<Plug>(comment_toggle_linewise_visual)", "Toggle comment", { remap = true })
map("n", "<leader>yp", copy_relative_path, "Yank relative path")
map("n", "<C-d>", "<C-d>zz", "Half page down and center")
map("n", "<C-u>", "<C-u>zz", "Half page up and center")
map("n", "n", "nzzzv", "Next search result and center")
map("n", "N", "Nzzzv", "Previous search result and center")
map("n", "Q", "<nop>", "Disable Ex mode")
map("n", ";", builtin.buffers, "Find buffers")
map("n", "<C-h>", "<C-w>h", "Move to left window")
map("n", "<C-l>", "<C-w>l", "Move to right window")
