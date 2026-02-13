local M = {}

local Popup = require 'nui.popup'
local Object = require 'nui.object'
local components = require 'components'

local active_prompt = nil
local AUGROUP = 'CustomPrompt'

---@param prefix string
---@return string
local function get_grep_cmd_text(prefix)
  local has_rg = vim.fn.executable 'rg' == 1
  if prefix == '/' then
    return has_rg and 'rg ' or 'grep '
  elseif prefix == '?' then
    return has_rg and 'rg -r ' or 'grep -r '
  end
  return ''
end

local function calc_base_col()
  -- 0 represents the current buffer in the cache
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
  group = vim.api.nvim_create_augroup(AUGROUP, { clear = false }),
  callback = function(ev)
    components.update_total_lines(ev.buf)
  end,
})

local Prompt = Object 'Prompt'

function Prompt:init(opts)
  self.opts = opts or {}
  self._left = nil
  self._right = nil
  self._visible = false
  self._cleanup_autocmd = nil
end

function Prompt:create()
  local base_col = calc_base_col()
  local prefix = self.opts.prefix

  -- Left popup: visual decoration only (rg / rg -r)
  if prefix == '/' or prefix == '?' then
    local cmd_text = get_grep_cmd_text(prefix)
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
    right_col = base_col + vim.fn.strdisplaywidth(get_grep_cmd_text(prefix))
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

function Prompt:_setup_cleanup()
  local group = vim.api.nvim_create_augroup(AUGROUP .. 'Cleanup', { clear = true })

  vim.api.nvim_create_autocmd('ModeChanged', {
    group = group,
    pattern = 'i:*',
    callback = function()
      if not self._visible then
        return
      end
      local win = vim.api.nvim_get_current_win()
      local in_prompt = (self._right and self._right.winid == win) or (self._left and self._left.winid == win)
      if not in_prompt then
        self:hide()
      end
    end,
  })

  vim.api.nvim_create_autocmd({ 'BufDelete', 'BufUnload' }, {
    group = group,
    callback = function()
      if self._visible then
        vim.schedule(function()
          self:hide()
        end)
      end
    end,
  })

  self._cleanup_autocmd = group
end

function Prompt:show()
  if active_prompt and active_prompt ~= self then
    active_prompt:hide()
  end
  active_prompt = self

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

  self:_setup_cleanup()

  vim.api.nvim_set_current_win(self._right.winid)
  vim.cmd 'startinsert'

  local function close_prompt()
    self:hide()
  end

  -- Insert mode keymaps
  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'i', '<Esc>', '', {
    callback = close_prompt,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'i', '<C-c>', '', {
    callback = close_prompt,
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

  -- Normal mode keymaps
  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'n', '<Esc>', '', {
    callback = close_prompt,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'n', '<C-c>', '', {
    callback = close_prompt,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._right.bufnr, 'n', 'q', '', {
    callback = close_prompt,
    noremap = true,
    silent = true,
  })
end

function Prompt:execute()
  -- Validate buffer exists before reading
  if not self._right or not self._right.bufnr or not vim.api.nvim_buf_is_valid(self._right.bufnr) then
    self:hide()
    return
  end

  -- Only use right buffer text - left is just visual
  local right_lines = vim.api.nvim_buf_get_lines(self._right.bufnr, 0, -1, false)
  local right_text = right_lines[1] or ''

  self:hide()

  if self.opts.on_submit then
    self.opts.on_submit(right_text)
  end
end

function Prompt:hide()
  if not self._visible then
    return
  end

  vim.cmd 'stopinsert'

  if self._cleanup_autocmd then
    vim.api.nvim_del_augroup_by_id(self._cleanup_autocmd)
    self._cleanup_autocmd = nil
  end

  if self._left then
    pcall(function()
      self._left:unmount()
    end)
    self._left = nil
  end
  if self._right then
    pcall(function()
      self._right:unmount()
    end)
    self._right = nil
  end
  self._visible = false

  if active_prompt == self then
    active_prompt = nil
  end
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
    -- Strip trailing trigger characters that may have been typed
    query = query:gsub('[;\n\r]+$', '')

    -- Validate non-empty query
    if query:match '^%s*$' then
      return
    end

    local ok, err = pcall(function()
      if prefix == ';' then
        vim.cmd(query)
        vim.cmd 'redraw'
      elseif prefix == '/' or prefix == '?' then
        vim.cmd(prefix .. query)
        vim.cmd 'redraw'
      end
    end)
    if not ok and err then
      vim.notify(err, vim.log.levels.ERROR)
    end
  end

  return M.prompt {
    prefix = prefix,
    on_submit = execute,
  }
end

vim.api.nvim_create_user_command('CloseCustomPrompt', function()
  if active_prompt then
    active_prompt:hide()
  end
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
