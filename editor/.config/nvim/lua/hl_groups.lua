local M = {}

local hl = vim.api.nvim_set_hl

M.gray = 'MyGray'
M.bold = 'MyBold'
M.green = 'MyGreen'
M.green_bold = 'MyGreenBold'
M.yellow = 'MyYellow'
M.yellow_bold = 'MyYellowBold'
M.red = 'MyRed'
M.red_bold = 'MyRedBold'
M.blue = 'MyBlue'
M.blue_bold = 'MyBlueBold'
M.magenta = 'MyMagenta'
M.magenta_bold = 'MyMagentaBold'
M.white = 'MyWhite'
M.white_bold = 'MyWhiteBold'

function M.apply_all()
  local term = vim.env.TERM or ''
  local colors = term:match '256color' and 256 or term:match '16color' and 16 or 256

  local gray, green, white, yellow, red, blue, magenta
  if colors >= 256 then
    gray = { ctermfg = 240, fg = '#585858' }
    green = { ctermfg = 46, fg = '#00ff00' }
    white = { ctermfg = 15, fg = '#ffffff' }
    yellow = { ctermfg = 226, fg = '#ffff00' }
    red = { ctermfg = 196, fg = '#ff0000' }
    blue = { ctermfg = 39, fg = '#00afd7' }
    magenta = { ctermfg = 201, fg = '#ff00ff' }
  elseif colors >= 16 then
    gray = { ctermfg = 8 }
    green = { ctermfg = 10 }
    white = { ctermfg = 15 }
    yellow = { ctermfg = 11 }
    red = { ctermfg = 9 }
    blue = { ctermfg = 12 }
    magenta = { ctermfg = 13 }
  else
    gray = { ctermfg = 7 }
    green = { ctermfg = 2 }
    white = { ctermfg = 15 }
    yellow = { ctermfg = 3 }
    red = { ctermfg = 1 }
    blue = { ctermfg = 4 }
    magenta = { ctermfg = 5 }
  end

  hl(0, M.gray, gray)
  hl(0, M.bold, { bold = true })
  hl(0, M.green, green)
  hl(0, M.green_bold, vim.tbl_extend('force', green, { bold = true }))
  hl(0, M.yellow, yellow)
  hl(0, M.yellow_bold, vim.tbl_extend('force', yellow, { bold = true }))
  hl(0, M.red, red)
  hl(0, M.red_bold, vim.tbl_extend('force', red, { bold = true }))
  hl(0, M.blue, blue)
  hl(0, M.blue_bold, vim.tbl_extend('force', blue, { bold = true }))
  hl(0, M.magenta, magenta)
  hl(0, M.magenta_bold, vim.tbl_extend('force', magenta, { bold = true }))
  hl(0, M.white, white)
  hl(0, M.white_bold, vim.tbl_extend('force', white, { bold = true }))
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
      return M.magenta
    elseif s.name:match '^Dap' then
      return M.blue
    end
  end

  local diags = vim.diagnostic.get(buf, { lnum = lnum - 1 })
  for _, d in ipairs(diags) do
    if d.severity == vim.diagnostic.severity.ERROR then
      return M.red
    elseif d.severity == vim.diagnostic.severity.WARN then
      return M.yellow
    end
  end

  return is_current and M.white or M.gray
end

return M
