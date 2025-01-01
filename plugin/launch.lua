local usr_command = vim.api.nvim_create_user_command

usr_command('ReplToggle', function()
  require('display').toggle_repl()
end, {})
usr_command('ReplOpen', function()
  require('display').open_repl()
end, {})
usr_command('ReplClose', function()
  require('display').close_repl()
end, {})
usr_command('ReplHide', function()
  require('display').hide_repl()
end, {})

usr_command('ReplSendLine', function()
  require('interaction').send_line()
end, {})
usr_command('ReplSendLineExecute', function()
  require('interaction').send_line_and_execute()
end, {})

vim.keymap.set('n', '<leader>rt', '<cmd>ReplToggle<CR>')
vim.keymap.set('n', '<leader>ro', '<cmd>ReplOpen<CR>')
vim.keymap.set('n', '<leader>rc', '<cmd>ReplClose<CR>')
vim.keymap.set('n', '<leader>rh', '<cmd>ReplHide<CR>')

vim.keymap.set('n', '<leader>rl', '<cmd>ReplSendLine<CR>')
vim.keymap.set('n', '<leader>rr', '<cmd>ReplSendLineExecute<CR>')
