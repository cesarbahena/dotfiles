local M = {}

local function is_diag_for_cur_pos()
  local diagnostics = vim.diagnostic.get(0)
  local pos = vim.api.nvim_win_get_cursor(0)
  if #diagnostics == 0 then return false end
  local message = vim.tbl_filter(function(d) return d.col == pos[2] and d.lnum == pos[1] - 1 end, diagnostics)
  return #message > 0
end

local function is_diag_neotest()
  local diagnostics = vim.diagnostic.get(0)
  local found = false
  for _, d in ipairs(diagnostics) do
    if d.source and d.source:match 'neotest' then
      found = true
      break
    end
  end
  return found
end

function M.hover_handler()
  local dap, ok = try(require, 'dap')
  if ok and dap.session() ~= nil then
    local dapui_ok, dapui = pcall(require, 'dap.ui.widgets')
    if dapui_ok and vim.bo.filetype ~= 'dap-float' then dapui.hover(nil, { border = 'rounded' }) end
  end
  local ft = vim.bo.filetype
  if vim.tbl_contains({ 'vim', 'help' }, ft) then
    vim.cmd('silent! h ' .. vim.fn.expand '<cword>')
  elseif vim.tbl_contains({ 'man' }, ft) then
    vim.cmd('silent! Man ' .. vim.fn.expand '<cword>')
  elseif is_diag_for_cur_pos() then
    if is_diag_neotest() then
      local nt_ok, nt = pcall(require, 'neotest')
      if nt_ok then nt.output.open {
        enter = true,
        auto_close = true,
      } end
    else
      vim.diagnostic.open_float()
    end
  else
    vim.lsp.buf.hover {
      border = 'rounded',
      silent = true,
      winopts = {
        conceallevel = 3,
      },
    }
  end
end

return M
