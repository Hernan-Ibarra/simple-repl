---@alias sending_method fun(): nil

---@type { state: state, methods: { [string]: display_method } }
local display = require 'display'

---@type { [string]: sending_method }
local M = {}

-- Sends array of lines of code to REPL and opens it
---@param code string[] Note that an empty string is interpreted as <CR>
---@return nil
local send_to_repl = function(code)
  display.methods.open_repl()
  local repl_buffer = display.state.buf
  local repl_channel = vim.bo[repl_buffer].channel
  vim.fn.chansend(repl_channel, code)
end

-- Send the current line to the REPL
---@type sending_method
M.send_line = function()
  local line = vim.api.nvim_get_current_line()
  send_to_repl { line }
end

-- Send the current line to the REPL and execute it
---@type sending_method
M.send_line_and_execute = function()
  M.send_line()
  send_to_repl { '' }
end

return M