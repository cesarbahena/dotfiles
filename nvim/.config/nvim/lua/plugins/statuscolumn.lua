return {
  'luukvbaal/statuscol.nvim',
  opt = {
    setopt = true,
    segments = {
      {
        text = {
          function(args)
            -- Get diagnostic info for color coding
            local diagnostics = vim.diagnostic.get(0, { lnum = args.lnum - 1 })
            local diagnostic_hl = 'LineNr'
            if #diagnostics > 0 then
              local severity = math.min(unpack(vim.tbl_map(function(d) return d.severity end, diagnostics)))
              diagnostic_hl = severity == 1 and 'DiagnosticSignError'
                or severity == 2 and 'DiagnosticSignWarn'
                or severity == 3 and 'DiagnosticSignInfo'
                or 'DiagnosticSignHint'
            end

            -- Priority 1: DAP breakpoints
            local dap_signs = vim.fn.sign_getplaced(args.buf, { group = '*', lnum = args.lnum })
            for _, sign_group in pairs(dap_signs) do
              for _, sign in pairs(sign_group.signs) do
                if sign.name:match '^Dap' then
                  local sign_def = vim.fn.sign_getdefined(sign.name)[1]
                  if sign_def then return '%#' .. sign_def.texthl .. '#' .. sign_def.text .. '%*' end
                end
              end
            end

            -- Priority 2: Line numbers with left padding and color coding
            if args.relnum == 0 then
              -- Current line: left-padded line number
              local line_num = tostring(vim.fn.line '.')
              local padding = line_num:len() == 1 and ' ' or ''
              return '%#' .. diagnostic_hl .. '#' .. padding .. line_num .. '%*'
            else
              -- Other lines: left-padded relative numbers
              local rel_num = tostring(args.relnum)
              local padding = rel_num:len() == 1 and ' ' or ''
              return '%#' .. diagnostic_hl .. '#' .. padding .. rel_num .. '%*'
            end
          end,
        },
      },
      {
        text = {
          function(args)
            if args.relnum == 0 then
              -- Current line: 1 space + caret (red if dx, green otherwise)
              local diagnostics = vim.diagnostic.get(0, { lnum = args.lnum - 1 })
              local caret_hl = #diagnostics > 0 and 'DiagnosticSignError' or 'DiagnosticSignOk'
              return ' %#' .. caret_hl .. '#❯%*'
            else
              -- Non-current line: 2 spaces
              return '  '
            end
          end,
        },
        maxwidth = 3,
      },
      { sign = { namespace = { 'gitsigns' }, maxwidth = 1, colwidth = 1, fillchar = ' ' } },
    },
  },
}

