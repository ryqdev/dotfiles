return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'Mofiqul/dracula.nvim',
  },
  config = function()
    vim.cmd.colorscheme("dracula")
    vim.opt.termguicolors = true
    require('bufferline').setup {}
  end
}
