return {
  'luukvbaal/statuscol.nvim',
  config = function()
    local builtin = require 'statuscol.builtin'
    require('statuscol').setup {
      setopt = true,
      segments = {
        {
          text = {
            function(args)
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

              -- Priority 2: Diagnostics
              local diagnostics = vim.diagnostic.get(0, { lnum = args.lnum - 1 })
              if #diagnostics > 0 then
                local severity = math.min(unpack(vim.tbl_map(function(d) return d.severity end, diagnostics)))
                local sign_text = severity == 1 and ' '
                  or severity == 2 and ' '
                  or severity == 3 and ' '
                  or ' '
                local hl_group = severity == 1 and 'DiagnosticSignError'
                  or severity == 2 and 'DiagnosticSignWarn'
                  or severity == 3 and 'DiagnosticSignInfo'
                  or 'DiagnosticSignHint'
                return '%#' .. hl_group .. '#' .. sign_text .. '%*'
              end

              -- Priority 3: Line numbers with error highlighting for current line
              if args.relnum == 0 then
                local has_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) > 0
                local hl_group = has_errors and 'ErrorMsg' or 'CursorLineNr'
                return '%#' .. hl_group .. '# ❯%*'
              else
                return tostring(args.relnum)
              end
            end,
          },
          condition = { true },
        },
        {
          text = {
            function(args)
              -- Check if there's a breakpoint on this line
              local dap_signs = vim.fn.sign_getplaced(args.buf, { group = '*', lnum = args.lnum })
              for _, sign_group in pairs(dap_signs) do
                for _, sign in pairs(sign_group.signs) do
                  if sign.name:match '^Dap' then
                    return ' ' -- Breakpoints get 1 space padding
                  end
                end
              end

              -- Check if there's a diagnostic on this line
              local diagnostics = vim.diagnostic.get(0, { lnum = args.lnum - 1 })
              if #diagnostics > 0 then
                return ' ' -- Diagnostics get 1 space padding
              end

              -- Add padding for line numbers only
              if args.relnum == 0 then
                return ' '
              else
                local padding = args.relnum < 10 and '  ' or ' '
                return padding
              end
            end,
          },
          maxwidth = 3,
        },
        { sign = { namespace = { 'gitsigns' }, maxwidth = 1, auto = true, colwidth = 1, fillchar = '' } },
      },
    }
  end,
}
