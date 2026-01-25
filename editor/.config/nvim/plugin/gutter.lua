require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '·' },
    delete = { text = '-' },
    topdelete = { text = '-' },
    changedelete = { text = '·' },
    untracked = { text = '+' },
  },
  on_attach = function(bufnr)
    local gs = require 'gitsigns'

    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gs.nav_hunk 'next'
      end
    end, { buffer = bufnr })

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gs.nav_hunk 'prev'
      end
    end, { buffer = bufnr })

    vim.keymap.set('n', '<leader>hp', gs.preview_hunk_inline, { buffer = bufnr })
    vim.keymap.set({ 'n', 'v' }, '<leader>hs', ':Gitsigns stage_hunk<CR>', { buffer = bufnr })
    vim.keymap.set({ 'n', 'v' }, '<leader>hr', ':Gitsigns reset_hunk<CR>', { buffer = bufnr })
  end,
}

local hl = vim.api.nvim_set_hl
hl(0, 'GitSignsAdd', { link = 'BashGreen' })
hl(0, 'GitSignsChange', { link = 'BashYellow' })
hl(0, 'GitSignsDelete', { link = 'BashRed' })
hl(0, 'GitSignsUntracked', { link = 'BashGreen' })

require('statuscol').setup {
  setopt = true,
  segments = {
    {
      text = {
        function(args)
          local hl = require('hl_groups').get_lnr_color(args.buf, args.lnum, args.relnum == 0)

          if args.relnum == 0 then
            return '%#' .. hl .. '# $%*'
          end

          return '%#' .. hl .. '#' .. string.format('%2d', args.relnum) .. '%*'
        end,
      },
    },
    {
      sign = { namespace = { 'gitsign' }, maxwidth = 1, colwidth = 1, auto = false },
    },
  },
}
