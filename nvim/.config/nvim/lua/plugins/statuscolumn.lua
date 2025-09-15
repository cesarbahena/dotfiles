return {
  'luukvbaal/statuscol.nvim',
  config = function()
    local builtin = require('statuscol.builtin')
    require('statuscol').setup {
      setopt = true,
      segments = {
        { text = { builtin.foldfunc }, click = 'v:lua.ScFa' },
        { sign = { namespace = { 'diagnostic*' } }, maxwidth = 1, auto = true },
        {
          text = { 
            function(args)
              -- Check for breakpoints first - they replace the number entirely
              local dap_signs = vim.fn.sign_getplaced(args.buf, { group = '*', lnum = args.lnum })
              for _, sign_group in pairs(dap_signs) do
                for _, sign in pairs(sign_group.signs) do
                  if sign.name:match('^Dap') then
                    local sign_def = vim.fn.sign_getdefined(sign.name)[1]
                    if sign_def then
                      return '%#' .. sign_def.texthl .. '#' .. sign_def.text .. '%*'
                    end
                  end
                end
              end
              
              -- No breakpoint - show line number with error highlighting
              if args.relnum == 0 then
                local has_errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR }) > 0
                local hl_group = has_errors and 'ErrorMsg' or 'CursorLineNr'
                return '%#' .. hl_group .. '# ❯%*'
              else
                return tostring(args.relnum)
              end
            end
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
                  if sign.name:match('^Dap') then
                    return ' ' -- Breakpoints get 1 space padding
                  end
                end
              end
              
              -- Add padding for alignment - current line gets 1 space, others get variable padding
              if args.relnum == 0 then
                return ' '
              else
                local padding = args.relnum < 10 and '  ' or ' '
                return padding
              end
            end
          },
          maxwidth = 3, 
        },
        { sign = { namespace = { 'gitsigns' } }, maxwidth = 1, auto = true },
      },
    }
  end,
}