---@alias sending_method fun(): nil

---@type { state: state, methods: { [string]: display_method } }
local display = require 'display'

---@type { [string]: ft_specs }
local ft_info = require 'ft-info'

---@type { [string]: sending_method }
local M = {}

--- Sends array of lines of code to REPL and opens it.
--- Most REPLs are temperamental so do not pass more than a line with a <CR> with this method.
---@param code string[] Note that an empty string is interpreted as <CR>
---@return nil
local send_lines_to_repl = function(code)
  display.methods.open_repl() --updates the state

  local repl_buffer = display.state.buf
  local repl_channel = vim.bo[repl_buffer].channel

  vim.fn.chansend(repl_channel, code)
end

--- Takes the path to a file and makes the REPL source it
---@param path string the absolute path to the file
---@return nil
local send_file_to_repl = function(path)
  display.methods.open_repl() --updates the state

  local filetype = display.state.detected_ft
  local command_prefix = ft_info[filetype].sourcing_command.path_prefix
  local command_postfix = ft_info[filetype].sourcing_command.path_postfix

  local source_command = command_prefix .. path .. command_postfix

  send_lines_to_repl { source_command }
end

--- Takes an array of lines of code and writes them to a temporary file. Returns the path to this file.
---@param code string[] An array of lines of code
---@return string? path_to_tmp_file returns nil when writing was unsuccessful
---@nodiscard
local write_to_tmp_file = function(code)
  local tmpfile = vim.fn.tempname()
  local write = vim.fn.writefile(code, tmpfile)

  if write == -1 then
    print 'ERROR: Could not write code to a temporary file.'
    return
  end

  return tmpfile
end

--- Send the current line to the REPL
---@type sending_method
M.send_current_line = function()
  local line = vim.api.nvim_get_current_line()
  send_lines_to_repl { line }
end

--- Send the current line to the REPL and execute it
---@type sending_method
M.send_current_line_and_execute = function()
  M.send_current_line()
  send_lines_to_repl { '' }
end

--- Sends the current buffer to REPL. We do not require the buffer to be saved for this to work, hence why we cannot use send_file_to_repl immediately
---@type sending_method
M.send_current_buffer = function()
  local buffer_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local path_to_tmp_file = write_to_tmp_file(buffer_lines)

  if not path_to_tmp_file then
    print 'ERROR: Could not get path to temporary file'
    return
  end

  send_file_to_repl(path_to_tmp_file)
end

--- Sends the current selection to REPL.
--- WARN: Unfortunately to get the content of the current selection we have to write it to the 0 register. This has to be hacked one way or another since Neovim does not yet have a reliable function to get the current selection.
---
---@type sending_method
M.send_current_selection = function()
  vim.cmd.norm '"0ygv'
  local selection_string = vim.fn.getreg '0'
  local selection_table = vim.split(selection_string, '\n')

  local path_to_tmp_file = write_to_tmp_file(selection_table)

  if not path_to_tmp_file then
    print 'ERROR: Could not get path to temporary file'
    return
  end

  send_file_to_repl(path_to_tmp_file)
end

return M