return {
  'b0o/incline.nvim',
  event = 'VeryLazy',
  config = function()
    require('incline').setup {
      render = function(props)
        -- Get window position info
        local win = props.win
        local tab = vim.api.nvim_win_get_tabpage(win)
        local wins_in_tab = vim.api.nvim_tabpage_list_wins(tab)

        -- Filter out floating windows
        local normal_wins = {}
        for _, w in ipairs(wins_in_tab) do
          if vim.api.nvim_win_get_config(w).relative == '' then table.insert(normal_wins, w) end
        end

        -- Find the rightmost column
        local rightmost_col = -1
        for _, w in ipairs(normal_wins) do
          local pos = vim.api.nvim_win_get_position(w)
          local col = pos[2]
          if col > rightmost_col then
            rightmost_col = col
          end
        end

        -- Find the topmost window in the rightmost column
        local topmost_in_rightmost = nil
        local topmost_row = math.huge
        for _, w in ipairs(normal_wins) do
          local pos = vim.api.nvim_win_get_position(w)
          local col = pos[2]
          local row = pos[1]
          if col == rightmost_col and row < topmost_row then
            topmost_row = row
            topmost_in_rightmost = w
          end
        end

        -- Don't show anything for the topmost window in the rightmost column
        if win == topmost_in_rightmost then return nil end

        -- Get filename and icon
        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ':t')
        if filename == '' then filename = '[No Name]' end

        -- Get icon and color using mini.icons
        local ft_icon, ft_hl_group = require('mini.icons').get('file', filename)
        local hl_attrs = vim.api.nvim_get_hl(0, { name = ft_hl_group })
        local ft_color = hl_attrs.fg and string.format('#%06x', hl_attrs.fg)

        -- Get git status color
        local function get_git_status_color()
          local filepath = vim.api.nvim_buf_get_name(props.buf)
          if filepath == '' then return nil end

          local handle = io.popen('git status --porcelain ' .. vim.fn.shellescape(filepath) .. ' 2>/dev/null')
          if not handle then return nil end

          local result = handle:read '*a'
          handle:close()

          if result == '' then return nil end

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

        local git_color = get_git_status_color()
        local gui_style = vim.bo[props.buf].modified and 'italic' or 'none'

        local result = {}
        table.insert(result, { ft_icon and (ft_icon .. ' ') or '', guifg = ft_color })
        table.insert(result, {
          filename,
          guifg = git_color or '#ffffff',
          gui = gui_style,
        })

        return result
      end,
      window = {
        padding = 0,
        margin = { horizontal = 0, vertical = 0 },
      },
    }
  end,
}

