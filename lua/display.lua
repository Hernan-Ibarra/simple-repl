---@class state
---@field buf number A buffer handle
---@field win number A window ID
---@field detected_ft string? The filetype of the buffer

---@alias display_method fun(): nil

---@type { state: state, methods: { [string]: display_method } }
local M = {
  state = { buf = -1, win = -1, detected_ft = nil },
  methods = {},
}

local ft_info = require 'ft-info'

---@type { [string]: string }
local repl_commands = {}

for ft_name, ft_spec in pairs(ft_info) do
  repl_commands[ft_name] = ft_spec.repl_command
end

--- Function to create a floating window. If no buffer is given, it creates a new one.
---@param opts { dimensions: { [string]: number }?,  filetype: string?, buf: number? }
---@return state
---@nodiscard
local create_floating_window = function(opts)
  -- Set default options
  opts = opts or {}
  local dimensions = opts.dimensions or {}

  local width = dimensions.width or math.floor(vim.o.columns * 0.8)     -- 80% of the screen width
  local height = dimensions.height or math.floor(vim.o.lines * 0.8)     -- 80% of the screen height
  local row = dimensions.row or math.floor((vim.o.lines - height) / 2)  -- Center vertically
  local col = dimensions.col or math.floor((vim.o.columns - width) / 2) -- Center horizontally
  local filetype = opts.filetype

  -- Create the floating window
  local win_opts = {
    relative = 'editor', -- Window will be relative to the entire editor
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',  -- Optional: makes the window look "minimal"
    border = 'rounded', -- Optional: default to 'rounded' border
    title = 'REPL',
    footer = 'Language: ' .. (filetype or 'unknown'),
    footer_pos = 'right',
  }

  ---@type number
  local buf

  if opts.buf == nil or not vim.api.nvim_buf_is_valid(opts.buf) then
    buf = vim.api.nvim_create_buf(false, true) -- Create a new empty buffer
  else
    buf = opts.buf
  end

  -- Open the window
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  return { buf = buf, win = win, detected_ft = filetype }
end

--- Function to start the REPL for the given filetype in the current buffer
---@param filetype string? The filetype used for the REPL
---@return nil
local function start_repl_in_current_buffer(filetype)
  local command = repl_commands[filetype]
  if command then
    vim.cmd('terminal ' .. command)
  else
    if filetype then
      print('No REPL available for ' .. filetype)
    else
      print 'Filetype not recognized. See :help filetype'
    end
    vim.cmd.terminal()
  end
end

--- Hides the REPL (closes window, hides buffer)
---@type display_method
M.methods.hide_repl = function()
  if vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_win_hide(M.state.win) -- Closes window and hides buffer
  end
end

--- Open REPL in floating window, creating buffer if necessary, updates state
---@type display_method
M.methods.open_repl = function()
  ---@type string?
  local filetype = vim.bo.filetype -- Returns '' when unknown

  if filetype == '' then
    filetype = nil
  end

  M.state = create_floating_window { buf = M.state.buf, filetype = filetype }
  if vim.bo[M.state.buf].buftype ~= 'terminal' then
    start_repl_in_current_buffer(filetype)
  end
end

--- Close the REPL (closes window, destroys buffer)
---@type display_method
M.methods.close_repl = function()
  if vim.api.nvim_buf_is_valid(M.state.buf) then
    vim.api.nvim_buf_delete(M.state.buf, { force = true })
  end
end

--- Alternates between opening and hiding the REPL
---@type display_method
M.methods.toggle_repl = function()
  if vim.api.nvim_win_is_valid(M.state.win) then
    vim.api.nvim_win_hide(M.state.win) -- Closes window and hides buffer
  else
    M.methods.open_repl()
  end
end

return M
