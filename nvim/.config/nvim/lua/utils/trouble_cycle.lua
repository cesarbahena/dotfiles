---@class TroubleCycle
local M = {}

---Get current diagnostic position index using trouble API
---@return number|nil current_index, number|nil total_count
local function get_current_diagnostic_index()
  if not fn 'trouble.is_open'() then return nil, nil end

  -- Get all items from trouble
  local items = fn 'trouble.get_items'()
  if not items or #items == 0 then return nil, 0 end

  -- Get current cursor position
  local current_buf = vim.api.nvim_get_current_buf()
  local current_pos = vim.api.nvim_win_get_cursor(0)
  local current_line = current_pos[1]
  local current_col = current_pos[2]

  -- Find matching item based on buffer, line, column
  for i, item in ipairs(items) do
    if item.buf == current_buf and item.pos and item.pos[1] == current_line and item.pos[2] == current_col then
      return i, #items
    end
  end

  return nil, #items
end

---Navigate to next item with cycling
function M.next()
  if not fn 'trouble.is_open'() then
    fn { 'trouble.open', 'diagnostics' }()
    return
  end

  local current_idx, total = get_current_diagnostic_index()

  if not current_idx or not total or total == 0 then
    -- No current position found, just do normal next
    fn { 'trouble.next', { skip_groups = true, jump = true } }()
    return
  end

  if current_idx >= total then
    -- At the last item, cycle to first
    fn { 'trouble.first', { skip_groups = true, jump = true } }()
  else
    -- Normal next
    fn { 'trouble.next', { skip_groups = true, jump = true } }()
  end
end

---Navigate to previous item with cycling
function M.prev()
  if not fn 'trouble.is_open'() then
    fn { 'trouble.open', 'diagnostics' }()
    return
  end

  local current_idx, total = get_current_diagnostic_index()

  if not current_idx or not total or total == 0 then
    -- No current position found, just do normal prev
    fn { 'trouble.prev', { skip_groups = true, jump = true } }()
    return
  end

  if current_idx <= 1 then
    -- At the first item, cycle to last
    fn { 'trouble.last', { skip_groups = true, jump = true } }()
  else
    -- Normal prev
    fn { 'trouble.prev', { skip_groups = true, jump = true } }()
  end
end

return M

