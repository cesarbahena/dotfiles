local M = {}

local Popup = require("nui.popup")
local Object = require("nui.object")
local components = require("components")
local hl = require("hl_groups")

local ns = vim.api.nvim_create_namespace("custom-prompt")

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
      local text = lines[1] or ""
      local prefix = self.opts.prompt_prefix or ""
      if prefix ~= "" and text:sub(1, #prefix) == prefix then
        text = text:sub(#prefix + 1)
      end
      if self.opts.on_submit then
        self.opts.on_submit(text)
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
  local parts = components.prompt_cwd_parts()
  local cwd_text = ""
  for _, p in ipairs(parts) do
    cwd_text = cwd_text .. p.text
  end

  local prompt_text = cwd_text .. " $ "
  local prompt_prefix = prompt_text
  local cwd_len = #cwd_text

  return M.prompt({
    prompt_prefix = prompt_prefix,
    on_submit = function(text)
      print("Submitted: " .. text)
    end,
    render = function(bufnr)
      vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { prompt_text })
      local col = 0
      for _, p in ipairs(parts) do
        local end_col = col + #p.text
        vim.api.nvim_buf_add_highlight(bufnr, ns, p.hl, 0, col, end_col)
        col = end_col
      end
      vim.api.nvim_buf_add_highlight(bufnr, ns, hl.green, 0, cwd_len, cwd_len + 3)
    end,
  })
end

vim.api.nvim_create_user_command("TestPrompt", function()
  M.test_prompt()
end, {})

return M
