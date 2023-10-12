-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
--
--
lvim.plugins = {
    {'christoomey/vim-tmux-navigator'},
    {'APZelos/blamer.nvim'},
}


lvim.builtin.which_key.mappings["j"] = {
    name = "+Terminal",
    f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
    v = { "<cmd>2ToggleTerm size=30 direction=vertical<cr>", "Split vertical" },
    h = { "<cmd>2ToggleTerm size=30 direction=horizontal<cr>", "Split horizontal" },
}


-- disable esc + j to swap lines
lvim.keys.insert_mode["<A-j>"] = false
lvim.keys.insert_mode["<A-k>"] = false
lvim.keys.normal_mode["<A-j>"] = false
lvim.keys.normal_mode["<A-k>"] = false
lvim.keys.visual_block_mode["<A-j>"] = false
lvim.keys.visual_block_mode["<A-k>"] = false
lvim.keys.visual_block_mode["J"] = false
lvim.keys.visual_block_mode["K"] = false


-- Set the number of spaces for indent
vim.opt.tabstop = 4      -- Number of spaces for a tab
vim.opt.shiftwidth = 4  -- Number of spaces for autoindent
vim.opt.expandtab = true -- Use spaces instead of tabs


-- let g:blamer_enabled = 1
vim.g.blamer_enabled = 1

vim.g.blamer_delay = 100

