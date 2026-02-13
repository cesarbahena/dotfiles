local M = {}

local Popup = require 'nui.popup'
local Object = require 'nui.object'
local components = require 'components'

local function calc_base_col()
  local line_count = components.total_lines_cache[0] or vim.api.nvim_buf_line_count(0)
  local path = vim.fn.getcwd()
  local home = vim.env.HOME
  if path:sub(1, #home) == home then
    path = '~' .. path:sub(#home + 1)
  end
  local prompt = '(' .. line_count .. ') ' .. path .. ' $ '
  return vim.fn.strdisplaywidth(prompt)
end

vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter', 'BufNew', 'BufDelete', 'BufModifiedSet' }, {
  callback = function(ev) components.update_total_lines(ev.buf) end
})

local Prompt = Object 'Prompt'

function Prompt:init(opts)
  self.opts = opts or {}
  self._left = nil
  self._right = nil
  self._visible = false
end

function Prompt:create()
  local base_col = calc_base_col()
  local prefix = self.opts.prefix

  -- Left popup: shows command (rg / rg -r) or nothing
  if prefix == '/' or prefix == '?' then
    local cmd_text = prefix == '/' and (vim.fn.executable('rg') == 1 and 'rg ' or 'grep ')
                                    or (vim.fn.executable('rg') == 1 and 'rg -r ' or 'grep -r ')
    self._left = Popup {
      relative = 'editor',
      position = {
        row = '100%',
        col = base_col,
      },
      size = {
        width = vim.fn.strdisplaywidth(cmd_text),
        height = 1,
      },
      border = {
        style = 'none',
      },
      win_options = {
        winhighlight = 'Normal:MyGray',
      },
      buf_options = {
        buftype = 'nofile',
        filetype = 'custom-prompt',
        modifiable = true,
        readonly = false,
      },
    }
    -- Set the text
    vim.schedule(function()
      if self._left and self._left.bufnr then
        vim.api.nvim_buf_set_lines(self._left.bufnr, 0, -1, false, { cmd_text })
        vim.bo[self._left.bufnr].modifiable = false
      end
    end)
  end

  -- Right popup: editable input area
  local right_col = base_col
  if self._left then
    right_col = base_col + vim.fn.strdisplaywidth(prefix == '/' and (vim.fn.executable('rg') == 1 and 'rg ' or 'grep ')
                                                            or (vim.fn.executable('rg') == 1 and 'rg -r ' or 'grep -r '))
  end

  self._right = Popup {
    relative = 'editor',
    position = {
      row = '100%',
      col = right_col,
    },
    size = {
      width = vim.o.columns - right_col,
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

  if not self._right then
    self:create()
  end

  if self._left then
    self._left:mount()
  end
  self._right:mount()

  if self._left then
    self._left:show()
  end
  self._right:show()
  self._visible = true

  -- Focus the right window for typing
  vim.api.nvim_set_current_win(self._right.winid)
  vim.cmd 'startinsert'

  -- Keymaps for right window
  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'i', '<Esc>', '', {
    callback = function()
      self:hide()
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'i', '<C-s>', '', {
    callback = function()
      self:execute()
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'i', ';', '', {
    callback = function()
      self:execute()
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'i', '<CR>', '', {
    callback = function()
      self:execute()
    end,
    noremap = true,
    silent = true,
  })
end

function Prompt:execute()
  local left_text = ''
  if self._left then
    local lines = vim.api.nvim_buf_get_lines(self._left.bufnr, 0, -1, false)
    left_text = lines[1] or ''
  end

  local right_lines = vim.api.nvim_buf_get_lines(self._right.bufnr, 0, -1, false)
  local right_text = right_lines[1] or ''

  self:hide()

  local full_text = left_text .. (left_text ~= '' and ' ' or '') .. right_text

  if self.opts.on_submit then
    self.opts.on_submit(full_text)
  end
end

function Prompt:hide()
  if self._left then
    self._left:unmount()
    self._left = nil
  end
  if self._right then
    self._right:unmount()
    self._right = nil
  end
  self._visible = false
end

function Prompt:is_visible()
  return self._visible
end

function M.prompt(opts)
  opts = opts or {}
  local prompt = Prompt()
  prompt:init(opts)
  prompt:show()
  return prompt
end

function M.open_prompt(prefix)
  local function execute(query)
    local ok, err = pcall(function()
      if prefix == ';' then
        vim.cmd('keepjumps noautocmd ' .. query)
        vim.cmd 'redraw'
        vim.cmd 'stopinsert'
      elseif prefix == '/' then
        local cmd = vim.fn.executable('rg') == 1 and 'rg ' or 'grep '
        local search_query = query:gsub('^' .. cmd, '')
        vim.cmd('keepjumps noautocmd /' .. search_query)
        vim.cmd 'stopinsert'
      elseif prefix == '?' then
        local cmd = vim.fn.executable('rg') == 1 and 'rg -r ' or 'grep -r '
        local search_query = query:gsub('^' .. cmd, '')
        vim.cmd('keepjumps noautocmd ?' .. search_query)
        vim.cmd 'stopinsert'
      end
    end)
    if not ok and err then
      vim.cmd 'stopinsert'
      vim.notify(err, vim.log.levels.ERROR)
    end
  end

  return M.prompt {
    prefix = prefix,
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
