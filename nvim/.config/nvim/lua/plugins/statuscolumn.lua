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
                    if sign_def then 
                      return '%#' .. sign_def.texthl .. '#' .. sign_def.text .. '%*'
                    end
                  end
                end
              end

              -- Priority 2: Color-coded line numbers
              if args.relnum == 0 then
                -- Current line number (caret will be in git signs column)
                local hl_group = #diagnostics > 0 and diagnostic_hl or 'DiagnosticSignOk'
                return '%#' .. hl_group .. '#' .. vim.fn.line('.') .. '%*'
              else
                -- Other lines: colored line numbers
                return '%#' .. diagnostic_hl .. '#' .. tostring(args.relnum) .. '%*'
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
        {
          text = {
            function(args)
              if args.relnum == 0 then
                -- Current line: show caret instead of git sign
                local diagnostics = vim.diagnostic.get(0, { lnum = args.lnum - 1 })
                local hl_group = #diagnostics > 0 and 
                  (diagnostics[1].severity == 1 and 'DiagnosticSignError'
                    or diagnostics[1].severity == 2 and 'DiagnosticSignWarn'
                    or diagnostics[1].severity == 3 and 'DiagnosticSignInfo'
                    or 'DiagnosticSignHint')
                  or 'DiagnosticSignOk'
                return '%#' .. hl_group .. '#❯%*'
              else
                return ''
              end
            end
          },
          maxwidth = 1,
        },
        { sign = { namespace = { 'gitsigns' }, maxwidth = 1, auto = true, colwidth = 1, fillchar = '' } },
      },
    }
  end,
}