local M = {}

local Popup = require 'nui.popup'
local Object = require 'nui.object'
local components = require 'components'
local hl = require 'hl_groups'

local ns = vim.api.nvim_create_namespace 'custom-prompt'

local Prompt = Object 'Prompt'

function Prompt:init(opts)
  self.opts = opts or {}
  self._nui = nil
  self._visible = false
end

function Prompt:create()
  self._nui = Popup {
    relative = 'editor',
    position = {
      row = '100%',
      col = self.opts.col or 0,
    },
    size = {
      width = (self.opts.width or vim.o.columns) - (self.opts.col or 0),
      height = 1,
    },
    border = {
      style = 'none',
    },
    win_options = {
      winhighlight = 'Normal:Normal,IncSearch:,CurSearch:,Search:',
    },
    buf_options = {
      buftype = 'nofile',
      filetype = 'custom-prompt',
      modifiable = true,
    },
  }
end

function Prompt:show()
  if not self._nui then
    self:create()
  end

  self._nui:mount()

  self._nui:show()
  self._visible = true

  vim.api.nvim_set_current_win(self._nui.winid)
  vim.cmd 'startinsert'

  vim.api.nvim_buf_set_keymap(self._nui.bufnr, 'i', '<Esc>', '', {
    callback = function()
      self:hide()
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._nui.bufnr, 'i', '<C-s>', '', {
    callback = function()
      self:execute()
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._nui.bufnr, 'i', ';', '', {
    callback = function()
      self:execute()
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._nui.bufnr, 'i', '<CR>', '', {
    callback = function()
      self:execute()
    end,
    noremap = true,
    silent = true,
  })
end

function Prompt:execute()
  local lines = vim.api.nvim_buf_get_lines(self._nui.bufnr, 0, -1, false)
  self:hide()
  local text = lines[1] or ''
  local prefix = self.opts.prompt_prefix or ''
  if prefix ~= '' and text:sub(1, #prefix) == prefix then
    text = text:sub(#prefix + 1)
  end
  if self.opts.on_submit then
    self.opts.on_submit(text)
  end
end

function Prompt:hide()
  if self._nui then
    self._nui:unmount()
    self._visible = false
  end
end

function Prompt:is_visible()
  return self._visible and self._nui and self._nui.winid and vim.api.nvim_win_is_valid(self._nui.winid)
end

function M.prompt(opts)
  opts = opts or {}
  local prompt = Prompt()
  prompt:init(opts)
  prompt:show()
  return prompt
end

local function calc_width()
  local line_count = '(' .. vim.fn.line '$' .. ') '
  local path = components.cwd():gsub(' $', '')
  local prompt = line_count .. path .. ' $ '
  return vim.fn.strdisplaywidth(prompt)
end

function M.open_prompt(prefix)
  local col = calc_width()

  local function execute(query)
    local ok, err = pcall(function()
      if prefix == ';' then
        vim.cmd('keepjumps noautocmd ' .. query)
        vim.cmd 'redraw'
        vim.cmd 'stopinsert'
      elseif prefix == '/' then
        vim.cmd('keepjumps noautocmd /' .. query)
        vim.cmd 'stopinsert'
      elseif prefix == '?' then
        vim.cmd('keepjumps noautocmd ?' .. query)
        vim.cmd 'stopinsert'
      end
    end)
    if not ok and err then
      vim.cmd 'stopinsert'
      vim.notify(err, vim.log.levels.ERROR)
    end
  end

  return M.prompt {
    col = col,
    on_submit = execute,
  }
end

vim.api.nvim_create_user_command('CmdLine', function()
  M.open_prompt ';'
end, {})

vim.api.nvim_create_user_command('SearchLine', function()
  M.open_prompt '/'
end, {})

vim.api.nvim_create_user_command('ReverseSearchLine', function()
  M.open_prompt '?'
end, {})

vim.keymap.set('n', ';', function()
  M.open_prompt ';'
end, { silent = true })

vim.keymap.set('n', '/', function()
  M.open_prompt '/'
end, { silent = true })

vim.keymap.set('n', '?', function()
  M.open_prompt '?'
end, { silent = true })

return M
