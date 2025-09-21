return {
  'b0o/incline.nvim',
  event = 'VeryLazy',
  opts = {
    render = function(props)
      -- Get window position info
      local win = props.win
      local tab = vim.api.nvim_win_get_tabpage(win)
      local wins_in_tab = vim.api.nvim_tabpage_list_wins(tab)

      -- Filter out floating windows and ensure we only work with normal windows
      local normal_wins = {}
      for _, w in ipairs(wins_in_tab) do
        local config = vim.api.nvim_win_get_config(w)
        if config.relative == '' and vim.api.nvim_win_is_valid(w) then table.insert(normal_wins, w) end
      end

      -- If no normal windows, don't show incline
      if #normal_wins == 0 then return nil end

      -- If only one window, it's both rightmost and topmost, so hide it
      if #normal_wins == 1 then return nil end

      -- Find the rightmost window in the top row only
      local top_right_window = nil
      local rightmost_col_in_top_row = -1
      local top_row = math.huge

      -- First find what the top row is
      for _, w in ipairs(normal_wins) do
        local pos = vim.api.nvim_win_get_position(w)
        local row = pos[1]
        if row < top_row then top_row = row end
      end

      -- Then find the rightmost window in that top row
      for _, w in ipairs(normal_wins) do
        local pos = vim.api.nvim_win_get_position(w)
        local col = pos[2]
        local row = pos[1]
        if row == top_row and col > rightmost_col_in_top_row then
          rightmost_col_in_top_row = col
          top_right_window = w
        end
      end

      -- Don't show anything for the top-right window
      if win == top_right_window then return nil end

      -- Get filename and icon
      local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
      if filename == '' then filename = '[No Name]' end

      -- Get icon and color using mini.icons
      local ft_icon, ft_hl_group = require('mini.icons').get('file', filename)
      local hl_attrs = vim.api.nvim_get_hl(0, { name = ft_hl_group })
      local ft_color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg)

      -- Helper function to get highlight group colors (matches heirline approach)
      local function get_hl_color(group)
        local hl = vim.api.nvim_get_hl(0, { name = group })
        return hl.fg and string.format('#%06x', hl.fg) or nil
      end

      -- Get git status color
      local function get_git_status_color()
        local filepath = vim.api.nvim_buf_get_name(props.buf)
        if filepath == '' then return get_hl_color('Normal') end

        local handle = io.popen('git status --porcelain ' .. vim.fn.shellescape(filepath) .. ' 2>/dev/null')
        if not handle then return nil end

        local result = handle:read '*a'
        handle:close()

        if result == '' then return get_hl_color('Normal') end

        local status = result:sub(1, 2)

        -- Check for serious git states (red - immediate attention needed)
        if status:match 'UU' or status:match 'AA' or status:match 'DD' then
          return get_hl_color('ErrorMsg') -- Red for merge conflicts
        elseif status:match 'AU' or status:match 'UA' or status:match 'UD' or status:match 'DU' then
          return get_hl_color('ErrorMsg') -- Red for conflict states
        end

        -- Regular git states
        if status:match '^%?%?' then
          return get_hl_color('GitSignsAdd') -- Green for untracked
        elseif status:match '[AM]' then
          return get_hl_color('GitSignsChange') -- Orange for modified/added
        end

        return get_hl_color('Normal')
      end

      local git_color = get_git_status_color()
      local has_diagnostics = #vim.diagnostic.get(props.buf) > 0

      local gui_style = 'none'
      if vim.bo[props.buf].modified then gui_style = 'italic' end
      if has_diagnostics then gui_style = vim.bo[props.buf].modified and 'italic,underline' or 'underline' end

      -- File format detection
      local fileformat = vim.api.nvim_get_option_value('fileformat', { buf = props.buf })

      local system_format = 'unix' -- default
      -- Check for WSL first (reports as unix, not windows)
      if vim.fn.has 'wsl' == 1 then
        system_format = 'unix'
      elseif vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
        system_format = 'dos'
      elseif vim.fn.has 'mac' == 1 then
        system_format = 'mac'
      end

      local function get_format_icon()
        if fileformat == 'dos' then
          return ' ' -- Windows CRLF
        elseif fileformat == 'mac' then
          return ' ' -- Mac CR
        elseif fileformat == 'unix' then
          return "F0311 " -- Unix LF
        end
        return ''
      end

      local format_icon = get_format_icon()

      local result = {}
      table.insert(result, { ft_icon and (ft_icon .. ' ') or '', guifg = ft_color })
      table.insert(result, {
        filename,
        guifg = git_color or get_hl_color('Normal'),
        gui = gui_style,
      })

      -- Show format icon only when different from system (matches heirline)
      if fileformat ~= system_format then
        table.insert(result, { format_icon, guifg = get_hl_color('ErrorMsg') }) -- ErrorMsg color
      end

      return result
    end,
    window = {
      padding = 0,
      margin = { horizontal = 0, vertical = 0 },
    },
  },
}
