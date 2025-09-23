local M = {}

Modified = false
Multiproject = false

M.cwd = {
  function()
    local cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ':t')
    if Multiproject then return '  ' .. cwd end
    return '  ' .. cwd
  end,

  color = function()
    local dx = vim.diagnostic
    if #dx.get(nil, { severity = dx.severity.ERROR }) > 0 then return { fg = '#f38ba8', gui = 'bold' } end
    if #dx.get(nil, { severity = dx.severity.WARN }) > 0 then return { fg = 'Orange', gui = 'bold' } end
    return { fg = 'white', gui = 'bold' }
  end,
}

local symbols = {
  stashed = ' ',
  ahead = '󰭾 ',
  behind = '󰭽 ',
  diverged = '󰧠 ',
  untracked = '󰘓 ',
  staged = '󰸩 ',
  modified = '󱇨 ',
  renamed = '󱀱 ',
  deleted = '󱀷 ',
}

function M.git_status()
  -- not a git repfunction M.git_status()
  -- Not a git repo
  if vim.fn.system('git rev-parse --is-inside-work-tree 2>/dev/null'):match 'true' ~= 'true' then return '' end

  local output = vim.fn.systemlist 'git status --porcelain 2>/dev/null'
  local flags = {
    staged = false, -- staged changes excluding renames
    modified = false,
    deleted = false,
    renamed = false,
    untracked = false,
  }

  for _, line in ipairs(output) do
    local x = line:sub(1, 1)
    local y = line:sub(2, 2)

    -- staged changes (exclude renamed from "staged")
    if x == 'A' or x == 'M' or x == 'D' then flags.staged = true end
    if x == 'D' then flags.deleted = true end
    if x == 'R' then flags.renamed = true end

    -- unstaged changes
    if y == 'M' then flags.modified = true end
    if y == 'D' then flags.deleted = true end

    -- untracked
    if x == '?' then flags.untracked = true end
  end

  -- stashes
  local stash_count = tonumber(vim.fn.system 'git stash list 2>/dev/null | wc -l') or 0
  local stash = stash_count > 0 and symbols.stashed or ''

  -- ahead/behind/diverged
  local ahead, behind = 0, 0
  local rev = vim.fn.systemlist 'git rev-list --left-right --count @{upstream}...HEAD 2>/dev/null'
  if #rev == 1 then
    ahead, behind = rev[1]:match '(%d+)%s+(%d+)'
    ahead, behind = tonumber(ahead), tonumber(behind)
  end
  local diverged = (ahead > 0 and behind > 0) and symbols.diverged or ''
  local ahead_sym = (ahead > 0 and behind == 0) and symbols.ahead or ''
  local behind_sym = (behind > 0 and ahead == 0) and symbols.behind or ''

  -- assemble result in Staship order
  local result = {
    stash,
    flags.deleted and symbols.deleted or '',
    flags.renamed and symbols.renamed or '',
    flags.modified and symbols.modified or '',
    flags.staged and symbols.staged or '',
    flags.untracked and symbols.untracked or '',
    behind_sym,
    ahead_sym,
    diverged,
  }
  return table.concat(result, '')
end

local function last_word(str) return string.match(str, '[^% ]+$') end

local special = {
  netrw = true,
  Trouble = true,
  fugitive = true,
  lazy = true,
  lspinfo = true,
  ['dapui_watches'] = last_word,
  ['dapui_breakpoints'] = last_word,
  ['dapui_stacks'] = last_word,
  ['dapui_scopes'] = last_word,
}

M.filetype = {
  'filetype',
  icon_only = true,
  colored = true,

  cond = function() return not special[vim.bo.ft] end,

  padding = { left = 1, right = 0 },
}

M.unsaved = {
  function()
    if Modified then return 'Unsaved changes!' end
    return ''
  end,
  color = { fg = 'LightGreen', gui = 'bold' },
}

M.diagnostics = {
  'diagnostics',
  sources = { 'nvim_diagnostic' },
  symbols = { error = ' ', warn = ' ', info = ' ', hint = ' ' },
  diagnostics_color = {
    color_error = 'DiagnosticSignError',
    color_warn = 'DiagnosticSignWarn',
    color_info = 'DiagnosticSignInfo',
    color_hint = 'DiagnosticSignHint',
  },
}

return M
