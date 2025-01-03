---@alias library "interaction" | "display"

-- Makes a command 'command_name' which executes 'method_name' from 'library'
---@param command_name string
---@param library library
---@param method_name string
---@return nil
local make_command = function(command_name, library, method_name)
  local callback = function()
    require(library)[method_name]()
  end
  vim.api.nvim_create_user_command(command_name, callback, {})
end

local prefix = '<leader>r'

-- Shortcut "prefix .. key" in "mode" mode for "command_name"
---@param command_name string
---@param key string
---@param mode string?
---@return nil
local set_key = function(command_name, key, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, prefix .. key, '<cmd>' .. command_name .. '<CR>')
end

-- A wrapper for make_command and set_key_normal in succession
---@param command_name string
---@param library library
---@param method_name string
---@param key string
---@param mode string?
---@return nil
local make_command_and_keymap = function(command_name, library, method_name, key, mode)
  make_command(command_name, library, method_name)
  set_key(command_name, key, mode)
end

make_command_and_keymap('ReplToggle', 'display', 'toggle_repl', 't')
make_command_and_keymap('ReplOpen', 'display', 'open_repl', 'o')
make_command_and_keymap('ReplClose', 'display', 'close_repl', 'c')
make_command_and_keymap('ReplHide', 'display', 'hide_repl', 'h')

make_command_and_keymap('ReplSendLine', 'interaction', 'send_current_line', 'l')
make_command_and_keymap('ReplSendLineExecute', 'interaction', 'send_current_line_and_execute', 'r')
make_command_and_keymap('ReplSendBuffer', 'interaction', 'send_current_buffer', 'f')
make_command_and_keymap('ReplSendSelection', 'interaction', 'send_current_selection', 's', 'v')