local edgy_filetypes = {
  'neotest-output-panel',
  'neotest-summary',
  'noice',
  'Trouble',
  'OverseerList',
  'Outline',
}

local edgy_titles = {
  ['neotest-output-panel'] = 'neotest',
  ['neotest-summary'] = 'neotest',
  noice = 'noice',
  Trouble = 'trouble',
  OverseerList = 'overseer',
  Outline = 'outline',
}

local function is_edgy_group(props) return vim.tbl_contains(edgy_filetypes, vim.bo[props.buf].filetype) end

-- Shared helper functions
local function to_subscript(n)
  local subscripts = { '₀', '₁', '₂', '₃', '₄', '₅', '₆', '₇', '₈', '₉' }
  return tostring(n):gsub('%d', function(d) return subscripts[tonumber(d) + 1] end)
end

local function to_superscript(n)
  local superscripts = { '⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹' }
  return tostring(n):gsub('%d', function(d) return superscripts[tonumber(d) + 1] end)
end

local function get_git_status_color(props)
  local filepath = vim.api.nvim_buf_get_name(props.buf)
  if filepath == '' then return nil end

  -- Get git status for file
  local handle = io.popen('git status --porcelain ' .. vim.fn.shellescape(filepath) .. ' 2>/dev/null')
  if not handle then return nil end

  local result = handle:read '*a'
  handle:close()

  if result == '' then return nil end -- Clean file

  local status = result:sub(1, 2)

  -- Check for serious git states (red - immediate attention needed)
  if status:match 'UU' or status:match 'AA' or status:match 'DD' then
    return '#f38ba8' -- Red for merge conflicts
  elseif status:match 'AU' or status:match 'UA' or status:match 'UD' or status:match 'DU' then
    return '#f38ba8' -- Red for conflict states
  end

  -- Regular git states
  if status:match '^%?%?' then
    return '#a6e3a1' -- Green for untracked
  elseif status:match '[AM]' then
    return '#fab387' -- Orange for modified/added
  end

  return nil
end

local function get_title(props)
  local title = ' ' .. edgy_titles[vim.bo[props.buf].filetype] .. ' '
  local result = {}

  -- Simple title styling
  table.insert(result, {
    title,
    gui = props.focused and 'bold' or nil,
    group = props.focused and 'FloatTitle' or 'Title',
  })

  return result
end

local function get_filename(props)
  local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
  if filename == '' then filename = '[No Name]' end

  -- Get icon and color using mini.icons
  local ft_icon, ft_hl_group = require('mini.icons').get('file', filename)
  local hl_attrs = vim.api.nvim_get_hl(0, { name = ft_hl_group })
  local ft_color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg)

  local result = {}
  local git_color = get_git_status_color(props)

  -- Simple gui style: just italic for modified files
  local gui_style = vim.bo[props.buf].modified and 'italic' or 'none'

  -- Add filename - git status colors only
  table.insert(result, { ft_icon and (ft_icon .. ' ') or '', guifg = ft_color })
  table.insert(result, {
    filename,
    guifg = git_color or '#ffffff',
    gui = gui_style,
  })

  return result
end

return {
  'b0o/incline.nvim',
  dependencies = { 'folke/edgy.nvim' },
  opts = {
    window = {
      zindex = 30,
      margin = {
        vertical = { top = 0, bottom = 0 },
        horizontal = { left = 0, right = 0 },
      },
      overlap = {
        tabline = true,
        winbar = false,
        borders = true,
        statusline = false,
      },
    },
    ignore = {
      buftypes = {},
      filetypes = {},
      unlisted_buffers = false,
    },
    render = function(props)
      if is_edgy_group(props) then return get_title(props) end

      -- Simple filename for regular files
      return get_filename(props)
    end,
  },
  event = 'VeryLazy',
}
