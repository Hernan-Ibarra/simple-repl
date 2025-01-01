local M = { buf = -1, win = -1 }

M.update = function(new_buf, new_win)
  M.buf = new_buf
  M.win = new_win
end

return M
