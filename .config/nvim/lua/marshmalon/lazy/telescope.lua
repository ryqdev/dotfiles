return {
  'nvim-telescope/telescope.nvim',
  tag = '0.1.6', -- or, branch = '0.1.x',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    local actions = require('telescope.actions')

    require('telescope').setup({
      defaults = {
        history = {
          path = vim.fn.stdpath('data') .. '/telescope_history.json',
          limit = 100,
          -- One history bucket per picker instead of one shared flat list
          handler = require('marshmalon.picker_history').handler,
        },
        mappings = {
          i = {
            -- Arrows cycle prompt history; <C-n>/<C-p> still move the selection
            ['<Up>'] = actions.cycle_history_prev,
            ['<Down>'] = actions.cycle_history_next,
          },
        },
      },
      pickers = {
        find_files = {
          hidden = true,
        },
      },
    })
  end
}
