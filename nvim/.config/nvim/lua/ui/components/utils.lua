local M = {}

function M.window()
  local windows = vim.api.nvim_tabpage_list_wins(0)
  local normal_windows = {}
  for _, win in ipairs(windows) do
    if vim.api.nvim_win_get_config(win).relative == '' then table.insert(normal_windows, win) end
  end

  if #normal_windows == 0 then return vim.api.nvim_get_current_win() end

  local top_row_y = vim.api.nvim_win_get_position(normal_windows[1])[1]
  local rightmost_win = normal_windows[1]
  local rightmost_x = vim.api.nvim_win_get_position(normal_windows[1])[2]

  for _, win in ipairs(normal_windows) do
    local pos = vim.api.nvim_win_get_position(win)
    if pos[1] == top_row_y and pos[2] > rightmost_x then
      rightmost_win = win
      rightmost_x = pos[2]
    end
  end

  return rightmost_win
end

return M