local M = {}

--- Find DBUI tab in all tabs
---@return number|nil tabnr The tab number containing DBUI, or nil if not found
local function find_dbui_tab()
  for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabnr)) do
      local bufnr = vim.api.nvim_win_get_buf(winid)
      local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
      if ft == 'dbui' then
        return tabnr
      end
    end
  end
  return nil
end

--- Get DBUI buffers that are not in visible tabs
---@return number[] hidden_dbui List of hidden DBUI buffer numbers
local function get_dbui_buffers_not_in_visible_tabs()
  local visible_buffers = {}
  -- Get all buffers in visible tabs (not the last tab)
  local tabs = vim.api.nvim_list_tabpages()
  for i = 1, #tabs - 1 do -- Skip last tab (hidden area)
    for _, winid in ipairs(vim.api.nvim_tabpage_list_wins(tabs[i])) do
      visible_buffers[vim.api.nvim_win_get_buf(winid)] = true
    end
  end

  -- Find DBUI buffers not in visible tabs
  local hidden_dbui = {}
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and not visible_buffers[bufnr] then
      local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
      if ft == 'dbui' then
        table.insert(hidden_dbui, bufnr)
      end
    end
  end
  return hidden_dbui
end

--- Hide DBUI tab by moving it to the end and switching away
---@return boolean success Whether the tab was successfully hidden
local function hide_dbui_tab()
  local dbui_tab = find_dbui_tab()
  if dbui_tab then
    -- Move tab to end to "hide" it (preserves layout)
    vim.api.nvim_set_current_tabpage(dbui_tab)
    vim.cmd 'tabmove $'
    -- Switch to previous tab to exit the hidden DBUI tab
    vim.cmd 'tabprevious'
    return true
  end
  return false
end

--- Restore DBUI tab with hidden buffers or create fresh DBUI
---@param hidden_buffers number[] List of hidden DBUI buffer numbers
local function restore_dbui_tab(hidden_buffers)
  vim.cmd 'tabnew'
  if #hidden_buffers > 0 then
    -- Restore first valid DBUI buffer
    for _, bufnr in ipairs(hidden_buffers) do
      if vim.api.nvim_buf_is_valid(bufnr) then
        vim.cmd('buffer ' .. bufnr)
        break
      end
    end
  else
    -- Open fresh DBUI
    vim.cmd 'DBUI'
  end
end

--- Intelligent DBUI tab cycling
--- Cycles through: open → hide → restore → switch
--- - If not in DBUI tab but it exists: switch to it
--- - If currently in DBUI tab: hide it
--- - If DBUI buffers exist but hidden: restore them
--- - If no DBUI anywhere: create fresh
function M.cycle_dbui_tab()
  local dbui_tab = find_dbui_tab()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local hidden_dbui = get_dbui_buffers_not_in_visible_tabs()

  if dbui_tab and dbui_tab ~= current_tab then
    -- DBUI tab exists but we're not in it, switch to it
    vim.api.nvim_set_current_tabpage(dbui_tab)
  elseif dbui_tab and dbui_tab == current_tab then
    -- We're in DBUI tab, hide it
    hide_dbui_tab()
  elseif #hidden_dbui > 0 then
    -- DBUI buffers exist but hidden, restore them
    restore_dbui_tab(hidden_dbui)
  else
    -- No DBUI anywhere, create fresh
    restore_dbui_tab {}
  end
end

return M
