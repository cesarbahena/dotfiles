local M = {}

local Popup = require 'nui.popup'
local Object = require 'nui.object'
local components = require 'components'

local function calc_cursor_col(prefix)
  local line_count = components.total_lines_cache[0] or vim.api.nvim_buf_line_count(0)
  local path = vim.fn.getcwd()
  local home = vim.env.HOME
  if path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end
  local prompt = '(' .. line_count .. ') ' .. path .. ' $'
  local col = vim.fn.strdisplaywidth(prompt)

  if prefix == '/' then
    col = col + 1 + vim.fn.strdisplaywidth(vim.fn.executable('rg') == 1 and 'rg' or 'grep')
  elseif prefix == '?' then
    col = col + 1 + vim.fn.strdisplaywidth(vim.fn.executable('rg') == 1 and 'rg -r' or 'grep -r')
  end

  return col
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'BufNew', 'BufDelete', 'BufModifiedSet' }, {
  callback = function(ev) components.update_total_lines(ev.buf) end
})

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
      col = 0,
    },
    size = {
      width = vim.o.columns,
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
  local bufnr = vim.api.nvim_get_current_buf()
  components.update_total_lines(bufnr)

  if not self._nui then
    self:create()
  end

  self._nui:mount()

  local col = calc_cursor_col(self.opts.prefix)
  self._nui:update_layout {
    position = {
      row = '100%',
      col = col,
    },
    size = {
      width = vim.o.columns - col,
      height = 1,
    },
  }

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

function M.open_prompt(prefix)
  local cmd = vim.fn.executable('rg') == 1 and 'rg' or 'grep'

  local function execute(query)
    local ok, err = pcall(function()
      if prefix == ';' then
        vim.cmd('keepjumps noautocmd ' .. query)
        vim.cmd 'redraw'
        vim.cmd 'stopinsert'
      elseif prefix == '/' then
        local search_query = query:gsub('^' .. cmd .. ' ', '')
        vim.cmd('keepjumps noautocmd /' .. search_query)
        vim.cmd 'stopinsert'
      elseif prefix == '?' then
        local search_query = query:gsub('^' .. cmd .. '%-r ', '')
        vim.cmd('keepjumps noautocmd ?' .. search_query)
        vim.cmd 'stopinsert'
      end
    end)
    if not ok and err then
      vim.cmd 'stopinsert'
      vim.notify(err, vim.log.levels.ERROR)
    end
  end

  local function render(bufnr)
    if prefix == '/' then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { cmd })
    elseif prefix == '?' then
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { cmd .. ' -r' })
    end
  end

  return M.prompt {
    prefix = prefix,
    on_submit = execute,
    render = render,
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
