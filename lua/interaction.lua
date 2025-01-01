local display = require 'display'

local M = {}

local send_to_repl = function(code)
  display.open_repl()
  local repl_channel = vim.bo[display.state.buf].channel
  vim.fn.chansend(repl_channel, code)
end

-- Send the current line to the REPL
M.send_line = function()
  local line = vim.api.nvim_get_current_line()
  send_to_repl { line, '' }
end

-- Send the whole file to the REPL
M.send_file = function()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  send_to_repl(table.insert(lines, ''))
  print(lines)
end

-- Send the selected text to the REPL
M.send_selection = function()
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

M.send_paragraph = function()
  ---
end

return M