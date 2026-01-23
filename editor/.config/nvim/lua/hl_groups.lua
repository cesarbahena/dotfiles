local M = {}

hl = vim.api.nvim_set_hl

function M.apply_all()
  hl(0, 'BashGray', { ctermfg = 240, fg = '#585858' })
  hl(0, 'BashBold', { bold = true })
  hl(0, 'BashGreen', { ctermfg = 46, fg = '#00ff5f' })
  hl(0, 'BashYellow', { ctermfg = 226, fg = '#ffff00' })
  hl(0, 'BashYellowBold', { ctermfg = 226, fg = '#ffff00', bold = true })
  hl(0, 'BashRed', { ctermfg = 196, fg = '#ff0000' })
  hl(0, 'BashBlue', { ctermfg = 39, fg = '#00afff' })
  hl(0, 'BashMagenta', { ctermfg = 201, fg = '#ff00ff' })
  hl(0, 'TabLine', { bg = 'NONE' })
  hl(0, 'TabLineFill', { bg = 'NONE' })
  hl(0, 'CursorLineNr', { fg = 'NONE' })
  hl(0, 'StatusLine', { bg = 'NONE', fg = 'NONE' })
  hl(0, 'StatusLineNC', { bg = 'NONE', fg = 'NONE' })
end

function M.get_lnr_color(buf, lnum, is_current)
  local placed = vim.fn.sign_getplaced(buf, { group = '*', lnum = lnum })[1]
  for _, s in ipairs(placed and placed.signs or {}) do
    if s.name == 'DapStopped' then
      return 'BashMagenta'
    elseif s.name:match '^Dap' then
      return 'BashBlue'
    end
  end

  local diags = vim.diagnostic.get(buf, { lnum = lnum - 1 })
  for _, d in ipairs(diags) do
    if d.severity == vim.diagnostic.severity.ERROR then
      return 'BashRed'
    elseif d.severity == vim.diagnostic.severity.WARN then
      return 'BashYellow'
    end
  end

  return is_current and 'BashGreen' or 'BashGray'
end

return M
