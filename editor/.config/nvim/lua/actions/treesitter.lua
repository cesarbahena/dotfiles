-- lua/actions/treesitter.lua
local M = {}

local ts_utils = require 'nvim-treesitter.ts_utils'
local parsers = require 'nvim-treesitter.parsers'

local function is_function_call(node)
  if not node then return false end
  local t = node:type()
  return t == 'call_expression' or t == 'function_call'
end

local function get_arguments_node(call_node)
  for child in call_node:iter_children() do
    local t = child:type()
    if t:match 'arguments' or t:match 'argument_list' then return child end
  end
  return nil
end

local function find_enclosing_function_call()
  local node = ts_utils.get_node_at_cursor()
  while node do
    if is_function_call(node) then return node end
    node = node:parent()
  end
  return nil
end

local function find_next_function_call()
  local bufnr = vim.api.nvim_get_current_buf()
  local lang = parsers.get_buf_lang(bufnr)
  local parser = parsers.get_parser(bufnr, lang)
  local tree = parser:parse()[1]
  local root = tree:root()

  local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))
  local best = nil
  local best_row, best_col = math.huge, math.huge

  local function walk(node)
    if is_function_call(node) then
      local start_row, start_col = node:start()
      if (start_row > cursor_row) or (start_row == cursor_row and start_col >= cursor_col) then
        if (start_row < best_row) or (start_row == best_row and start_col < best_col) then
          best = node
          best_row, best_col = start_row, start_col
        end
      end
    end
    for child in node:iter_children() do
      walk(child)
    end
  end

  walk(root)
  return best
end

local function go_to_last_argument_and_add_comma(call_node)
  ts_utils.goto_node(call_node)

  local args_node = get_arguments_node(call_node)
  if not args_node then return end

  local last_arg = nil
  for child in args_node:iter_children() do
    if child:named() then last_arg = child end
  end

  if last_arg then
    local end_row, end_col = last_arg:end_()
    local start_row = args_node:start()
    local is_multiline = end_row > start_row

    vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col })

    local line = vim.api.nvim_get_current_line()
    local after_arg = line:sub(end_col + 1, end_col + 1)
    if after_arg ~= ',' then
      if is_multiline then
        -- Add comma and open new indented line for multiline
        vim.api.nvim_feedkeys(',', 'n', false)
        vim.cmd 'normal! o'
        vim.cmd 'normal! =='
        vim.defer_fn(function()
          local indent_level = vim.fn.indent(vim.fn.line '.' - 1)
          vim.api.nvim_set_current_line(string.rep(' ', indent_level))
          vim.cmd 'startinsert!'
        end, 10)
      else
        -- Enter insert mode and insert comma and space
        vim.cmd 'startinsert'
        vim.api.nvim_feedkeys(', ', 'n', false)
      end
    else
      -- There's already a comma
      if is_multiline then
        -- Move to end of line and open new indented line
        vim.cmd 'normal! o'
        vim.cmd 'normal! =='
        vim.defer_fn(function()
          local indent_level = vim.fn.indent(vim.fn.line '.' - 1)
          vim.api.nvim_set_current_line(string.rep(' ', indent_level))
          vim.cmd 'startinsert!'
        end, 10)
      else
        -- Position cursor after comma and use append mode
        vim.api.nvim_win_set_cursor(0, { end_row + 1, end_col + 1 })
        vim.cmd 'startinsert'
      end
    end
  else
    local start_row, start_col = args_node:start()
    -- place cursor inside the parentheses and enter insert mode
    vim.api.nvim_win_set_cursor(0, { start_row + 1, start_col + 1 })
    vim.cmd 'startinsert'
  end
end

function M.add_argument()
  local call = find_enclosing_function_call()
  if not call then
    call = find_next_function_call()
    if not call then
      vim.notify 'No function call found'
      return
    end
  end
  go_to_last_argument_and_add_comma(call)
end

function M.clean_exit()
  vim.cmd 'stopinsert'
  vim.defer_fn(function()
    if vim.fn.getreg '.' == ', ' then vim.cmd 'undo' end
  end, 10)
end

function M.find()
  if vim.v.hlsearch == 1 and vim.fn.getreg('/') ~= '' and vim.fn.searchcount().total > 0 then
    -- Search highlights are visible, go to next match
    vim.cmd 'normal! n'
  else
    -- No search highlights visible, start new search
    vim.api.nvim_feedkeys('/', 'n', false)
  end
end

return M
