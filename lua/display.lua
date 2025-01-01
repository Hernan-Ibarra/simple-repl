local state = require 'state'

local repl_commands = {
  lua = 'lua',
  python = 'python3',
  scheme = 'scheme',
}

-- Function to create a floating window
local create_floating_window = function(opts)
  -- Set default options
  opts = opts or {}
  local width = opts.width or math.floor(vim.o.columns * 0.8) -- 80% of the screen width
  local height = opts.height or math.floor(vim.o.lines * 0.8) -- 80% of the screen height
  local row = opts.row or math.floor((vim.o.lines - height) / 2) -- Center vertically
  local col = opts.col or math.floor((vim.o.columns - width) / 2) -- Center horizontally
  local filetype = opts.filetype

  -- Create the floating window
  local win_opts = {
    relative = 'editor', -- Window will be relative to the entire editor
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal', -- Optional: makes the window look "minimal"
    border = opts.border or 'rounded', -- Optional: default to 'rounded' border
    title = 'REPL',
    footer = 'Language: ' .. (filetype or 'unknown'),
    footer_pos = 'right',
  }

  local buf = nil
  if vim.api.nvim_buf_is_valid(opts.buf) then
    buf = opts.buf
  else
    buf = vim.api.nvim_create_buf(false, true) -- Create a new empty buffer
  end

  -- Open the window
  local win = vim.api.nvim_open_win(buf, true, win_opts)

  return { buf = buf, win = win }
end

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

-- Opens REPL for the current buffer. Creates the REPL session if none found
local open_repl = function()
  local filetype = vim.bo.filetype -- Returns '' when unknown
  if filetype == '' then
    filetype = nil
  end

  state = create_floating_window { buf = state.buf, filetype = filetype }

  if vim.bo[state.buf].buftype ~= 'terminal' then
    start_repl_in_current_buffer(filetype)
  end
end

local close_repl = function()
  if vim.bo[state.buf].nvim_buf_is_valid then
    vim.api.nvim_buf_delete(state.buf, { force = true })
  end
end

local restart_repl = function()
  close_repl()
  open_repl()
end

local toggle_repl = function()
  if vim.api.nvim_win_is_valid(state.win) then
    vim.api.nvim_win_hide(state.win) -- Closes window and hides buffer
  else
    open_repl()
  end
end

vim.api.nvim_create_user_command('ReplToggle', toggle_repl, {})
vim.api.nvim_create_user_command('ReplOpen', open_repl, {})
vim.api.nvim_create_user_command('ReplClose', close_repl, {})
vim.api.nvim_create_user_command('ReplRestart', restart_repl, {})

vim.keymap.set({ 'n', 't' }, '<leader>rt', '<cmd>ReplToggle<CR>')