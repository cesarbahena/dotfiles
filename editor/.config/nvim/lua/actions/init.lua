local M = {}

-- Insert mode with blank line indentation
function M.insert_mode_indent_blankline()
  if #vim.fn.getline '.' == 0 then
    return [["_cc]]
  else
    return 'i'
  end
end

-- Delete line without yanking blank lines
function M.delete_line_no_yank_blankline()
  if vim.api.nvim_get_current_line():match '^%s*$' then return '"_dd' end
  return 'dd'
end

-- Change visual mode
function M.change_visual_mode()
  if vim.fn.mode():find 'V' then return 'v' end
  return 'V'
end

function M.toggle_macro_recording()
  if not vim.g.recording then
    vim.g.recording = true
    vim.cmd 'normal! qq'
    print 'Recording...'
  else
    vim.g.recording = false
    vim.cmd 'normal! q'
    print 'Stopped recording'
  end
end

function M.to()
  local flash_char = require 'flash.plugins.char'

  local function handle_state(action, hide)
    flash_char.jumping = true
    local autohide = hide and require('flash.config').get('char').autohide

    action()

    vim.schedule(function()
      flash_char.jumping = false
      if hide and flash_char.state and autohide then flash_char.state:hide() end
    end)
  end

  if flash_char.visible() then
    if flash_char.motion == 'f' or flash_char.motion == 'F' then
      handle_state(flash_char.next, false)
    else -- 't' or 'T' motions should repeat action
      handle_state(function() vim.cmd 'normal! .' end, true)
    end
  else
    handle_state(function() flash_char.jump 'f' end, true)
  end
end

function M.back_to()
  local flash_char = require 'flash.plugins.char'

  local function handle_state(action, hide)
    flash_char.jumping = true
    local autohide = hide and require('flash.config').get('char').autohide

    action()

    vim.schedule(function()
      flash_char.jumping = false
      if hide and flash_char.state and autohide then flash_char.state:hide() end
    end)
  end

  if flash_char.visible() then
    if flash_char.motion == 'F' or flash_char.motion == 'f' then
      handle_state(flash_char.prev, false)
    else -- 'T' or 't' motions should repeat action
      handle_state(function() vim.cmd 'normal! .' end, true)
    end
  else
    handle_state(function() flash_char.jump 'F' end, true)
  end
end

-- Clean function that closes trouble if open and clears highlights
function M.clean()
  if require('trouble').is_open() then require('trouble').close() end
  vim.cmd 'nohl'
end

-- Exit visual mode using guaranteed method
function M.exit_visual() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false) end

return M
