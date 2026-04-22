return {
  'RRethy/vim-illuminate',
  init = function()
    vim.g.Illuminate_useDeprecated = 1
  end,
  config = function()
    require('illuminate').configure({
      providers = { 'lsp', 'regex' },
    })
    require('illuminate.engine').start()
    require('illuminate').set_highlight_defaults()

    local group = vim.api.nvim_create_augroup('vim_illuminate_autocmds', { clear = true })
    vim.api.nvim_create_autocmd('ColorScheme', {
      group = group,
      callback = function()
        require('illuminate').set_highlight_defaults()
      end,
    })

    local commands = {
      IlluminatePause      = 'pause',
      IlluminateResume     = 'resume',
      IlluminateToggle     = 'toggle',
      IlluminatePauseBuf   = 'pause_buf',
      IlluminateResumeBuf  = 'resume_buf',
      IlluminateToggleBuf  = 'toggle_buf',
      IlluminateDebug      = 'debug',
    }
    for cmd_name, fn_name in pairs(commands) do
      vim.api.nvim_create_user_command(cmd_name, function()
        require('illuminate')[fn_name]()
      end, { bang = true })
    end

    local util = require('illuminate.util')
    if not util.has_keymap('n', '<a-n>') then
      vim.keymap.set('n', '<a-n>', function() require('illuminate').goto_next_reference() end,
        { desc = 'Move to next reference' })
    end
    if not util.has_keymap('n', '<a-p>') then
      vim.keymap.set('n', '<a-p>', function() require('illuminate').goto_prev_reference() end,
        { desc = 'Move to previous reference' })
    end
    if not util.has_keymap('o', '<a-i>') then
      vim.keymap.set('o', '<a-i>', function() require('illuminate').textobj_select() end)
    end
    if not util.has_keymap('x', '<a-i>') then
      vim.keymap.set('x', '<a-i>', function() require('illuminate').textobj_select() end)
    end
  end,
}
