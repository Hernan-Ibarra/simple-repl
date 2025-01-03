---@class ft_specs
---@field repl_command string the command to start the REPL in terminal
---@field sourcing_command sourcing_command the REPL command to source a file
---
---@class sourcing_command
---@field path_prefix string what to put before the file path
---@field path_postfix string what to put after the file path
---
---@type { [string]: ft_specs }
M = {}

M.lua = {
  repl_command = 'lua',
  sourcing_command = {
    path_prefix = "require('",
    path_postfix = "')",
  },
}

M.python = {
  repl_command = 'python3',
  sourcing_command = {
    path_prefix = 'exec(open("',
    path_postfix = '").read())',
  },
}

M.scheme = {
  repl_command = 'scheme',
  sourcing_command = {
    path_prefix = '(load "',
    path_postfix = '")',
  },
}

return M