return {
  'akinsho/bufferline.nvim',
  version = "*",
  dependencies = {
    'nvim-tree/nvim-web-devicons',
    'folke/tokyonight.nvim',
  },
  config = function()
    vim.cmd.colorscheme("tokyonight-night")
    vim.opt.termguicolors = true
    require('bufferline').setup {}
  end
}
