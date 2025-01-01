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
  if lines[#lines] ~= '' then
    lines[#lines + 1] = ''
  end
  send_to_repl(lines)
end

-- Send the selected text to the REPL
M.send_selection = function()
  -- HACK: getpos was returning previous selection rather than current selection. I wanted to do a command to exit visual mode but <Esc> was not working as an argument to normal (and the hack suggested in the help files of using :exec "normal <Esc>" didn't work either). The below deletes (without yanking) and undoes the change, which effectively exits visual mode.
  vim.cmd 'normal! "_du'
  -- Get the start and end positions of the visual selection
  local start_pos = vim.fn.getpos "'<" -- Start position of the visual selection
  local end_pos = vim.fn.getpos "'>" -- End position of the visual selection

  -- Convert the positions to zero-based row and column indices
  local start_row = start_pos[2] - 1
  local start_col = start_pos[3] - 1
  local end_row = end_pos[2] - 1
  local end_col = end_pos[3]

  -- Use nvim_buf_get_text to get the text within the selection range
  local selected_text = vim.api.nvim_buf_get_text(0, start_row, start_col, end_row, end_col, {})
  if selected_text[#selected_text] ~= '' then
    selected_text[#selected_text + 1] = ''
  end

  send_to_repl(selected_text)
end

M.send_paragraph = function()
  vim.cmd 'normal vip'
  M.send_selection()
end

return M