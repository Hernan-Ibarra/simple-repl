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
  send_to_repl { line }
end

M.send_line_and_execute = function()
  local line = vim.api.nvim_get_current_line()
  send_to_repl { line, '' }
end

return M
