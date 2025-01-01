local state = require 'lua.state'

local send_to_repl = function(code)
  local repl_channel = vim.bo[state.buf].channel
  vim.fn.chansend(repl_channel, code .. '\n')
end

-- Send the current line to the REPL
local function send_current_line()
  local line = vim.api.nvim_get_current_line()
  send_to_repl(line)
end

-- Send the selected text to the REPL
local function send_selection()
  -- Get the selected text in visual mode
  local start_row, start_col = unpack(vim.api.nvim_buf_get_mark(0, '<'))
  local end_row, end_col = unpack(vim.api.nvim_buf_get_mark(0, '>'))
  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)
  -- If the selection starts and ends in the same line, we need to trim the selected range
  if start_row == end_row then
    lines[1] = lines[1]:sub(start_col + 1, end_col)
  else
    lines[1] = lines[1]:sub(start_col + 1)
    lines[#lines] = lines[#lines]:sub(1, end_col)
  end
  send_to_repl(table.concat(lines, '\n'))
end

-- Send the whole file to the REPL
local function send_whole_file()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  send_to_repl(table.concat(lines, '\n'))
end

vim.keymap.set('n', '<leader>rl', send_current_line)
vim.keymap.set('v', '<leader>rs', send_selection)