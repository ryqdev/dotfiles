local builtin = require('telescope.builtin')

local terminal = {
  buf = nil,
}

local function map(modes, lhs, rhs, desc, opts)
  opts = opts or {}
  opts.desc = desc
  if opts.silent == nil then
    opts.silent = true
  end
  vim.keymap.set(modes, lhs, rhs, opts)
end

local function terminal_win()
  if not terminal.buf or not vim.api.nvim_buf_is_valid(terminal.buf) then
    terminal.buf = nil
    return nil
  end

  local win = vim.fn.bufwinid(terminal.buf)
  if win == -1 then
    return nil
  end

  return win
end

local function open_terminal()
  if not terminal.buf or not vim.api.nvim_buf_is_valid(terminal.buf) then
    terminal.buf = vim.api.nvim_create_buf(false, true)
    vim.bo[terminal.buf].bufhidden = "hide"
    vim.bo[terminal.buf].buflisted = false
    vim.bo[terminal.buf].swapfile = false
  end

  vim.cmd("botright split")
  vim.cmd("resize 15")
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, terminal.buf)

  if vim.bo[terminal.buf].buftype ~= "terminal" then
    vim.fn.termopen(vim.o.shell)
  end

  vim.wo[win].number = false
  vim.wo[win].relativenumber = false
  vim.cmd("startinsert")
end

local function toggle_terminal()
  local win = terminal_win()
  if win then
    vim.api.nvim_win_close(win, true)
    return
  end

  open_terminal()
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

vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('user_lsp_attach', { clear = true }),
  callback = function(event)
    local opts = { buffer = event.buf }
    map("n", "gd", vim.lsp.buf.definition, "Go to definition", opts)
    map("n", "gl", vim.diagnostic.open_float, "Open diagnostic float", opts)
    map("n", "gr", vim.lsp.buf.references, "Go to references", opts)
    map("n", "gi", vim.lsp.buf.implementation, "Go to implementation", opts)
    map("n", "K", vim.lsp.buf.hover, "Show hover information", opts)
    map("n", "<leader>ln", vim.lsp.buf.rename, "Rename", opts)

    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = event.buf,
      callback = function()
        vim.lsp.buf.format { async = false, id = event.data.client_id }
      end

    })
  end,
})

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
map({ "n", "t" }, "<leader>tt", toggle_terminal, "Toggle terminal")
