local M = {}

local Popup = require("nui.popup")
local Object = require("nui.object")

local Prompt = Object("Prompt")

function Prompt:init(opts)
  self.opts = opts or {}
  self._nui = nil
  self._visible = false
end

function Prompt:create()
  local opts = self.opts
  self._nui = Popup({
    relative = "editor",
    position = {
      row = "100%",
      col = 0,
    },
    size = {
      width = vim.o.columns,
      height = 1,
    },
    border = {
      style = "none",
    },
    win_options = {
      winhighlight = "Normal:Normal,IncSearch:,CurSearch:,Search:",
    },
    buf_options = {
      buftype = "nofile",
      filetype = "custom-prompt",
      modifiable = true,
    },
  })
end

function Prompt:show(render_fn)
  if not self._nui then
    self:create()
  end

  self._nui:mount()

  if render_fn then
    render_fn(self._nui.bufnr)
  else
    vim.api.nvim_buf_set_lines(self._nui.bufnr, 0, -1, false, { "" })
  end

  self._nui:show()
  self._visible = true

  vim.api.nvim_set_current_win(self._nui.winid)
  vim.cmd("startinsert")

  local line = vim.api.nvim_buf_get_lines(self._nui.bufnr, 0, 1, false)[1]
  vim.api.nvim_win_set_cursor(self._nui.winid, { 1, #line })

  vim.api.nvim_buf_set_keymap(self._nui.bufnr, "i", "<Esc>", "", {
    callback = function()
      self:hide()
    end,
    noremap = true,
    silent = true,
  })

  vim.api.nvim_buf_set_keymap(self._nui.bufnr, "i", "<CR>", "", {
    callback = function()
      local lines = vim.api.nvim_buf_get_lines(self._nui.bufnr, 0, -1, false)
      self:hide()
      if self.opts.on_submit then
        self.opts.on_submit(lines[1] or "")
      end
    end,
    noremap = true,
    silent = true,
  })
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
  prompt:show(opts.render)
  return prompt
end

function M.test_prompt()
  return M.prompt({
    on_submit = function(text)
      print("Submitted: " .. text)
    end,
    render = function(bufnr)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "> test " })
    end,
  })
end

vim.api.nvim_create_user_command("TestPrompt", function()
  M.test_prompt()
end, {})

return M
