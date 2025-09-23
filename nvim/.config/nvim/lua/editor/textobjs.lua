local function format_desc(desc, mode, spec)
  if type(desc) == 'string' then return desc end

  if type(desc) == 'table' then
    -- Use mode-specific description if available, otherwise fall back to [1]
    local base_desc = desc[mode] or desc[1] or ''

    -- Add "with" modifier to 'a' mode
    if mode == 'a' and desc.with then base_desc = base_desc .. ' with ' .. desc.with end

    -- Add "only" modifier to 'i' mode
    if mode == 'i' and desc.only then base_desc = base_desc .. ' (only ' .. desc.only .. ')' end

    return base_desc
  end

  return ''
end

local textobjs = {
  d = {
    desc = 'Function definition',
    provider = 'treesitter',
    'function_def',
  },
  l = {
    desc = 'Class',
    provider = 'treesitter',
    args = { i = 'outer' },
    'class',
  },
  t = {
    desc = 'Tag',
    provider = 'mini.ai',
    '<([%p%w]-)%f[^<%w][^<>]->.-</%1>',
    '^<.->().*()</[^/]->$',
  },
  b = {
    desc = 'Block',
    provider = 'treesitter',
    'block',
    'conditional',
    'loop',
  },
  ['\\'] = {
    desc = 'Regex',
    provider = 'treesitter',
    'regex',
  },
  k = {
    desc = 'Bracket',
    provider = 'mini.ai',
    { '%b()', '%b[]', '%b{}' },
    '^.().*().$',
  },
  ['/'] = {
    desc = 'Date',
    provider = 'mini.ai',
    '()%d+[/%-]%w+[/%-]%d+()',
  },
  D = {
    desc = 'Double bracket string',
    provider = 'mini.ai',
    '()%[%[().-()%]%]()',
  },
  x = {
    desc = 'XML attribute',
    provider = 'mini.ai',
    '()%w+=["{]().-()["}]()',
  },
  N = {
    desc = 'Subword',
    provider = 'mini.ai',
    {
      '%u[%l%d]+%f[^%l%d]',
      '%f[%S][%l%d]+%f[^%l%d]',
      '%f[%P][%l%d]+%f[^%l%d]',
      '^[%l%d]+%f[^%l%d]',
    },
    '^().*()$',
  },
  K = {
    desc = 'To next closing bracket',
    provider = 'various-textobjs',
    args = false,
    'toNextClosingBracket',
  },
  -- {
  --   desc = 'Near EoL',
  --   provider = 'various-textobjs',
  --   args = false,
  --   'nearEoL',
  -- },
  Q = {
    desc = 'To next quotation mark',
    provider = 'various-textobjs',
    args = false,
    'toNextQuotationMark',
  },
  P = {
    desc = 'Paragraph',
    provider = 'various-textobjs',
    args = false,
    'restOfParagraph',
  },
  gG = {
    desc = 'Entire buffer',
    provider = 'various-textobjs',
    custom_keymap = true,
    'entireBuffer',
  },
  ['_'] = {
    desc = 'Line characterwise',
    provider = 'various-textobjs',
    'lineCharacterwise',
  },
  ['<c-v>'] = {
    desc = 'Column',
    provider = 'various-textobjs',
    'column',
  },
  v = {
    desc = 'Value',
    provider = 'various-textobjs',
    'value',
  },
  V = {
    desc = 'Variable assignment',
    provider = 'various-textobjs',
    'key',
  },
  L = {
    desc = 'URL',
    provider = 'various-textobjs',
    args = false,
    'url',
  },
  ['!'] = {
    desc = 'Diagnostic',
    provider = 'various-textobjs',
    args = false,
    'diagnostic',
  },
  m = {
    desc = 'Chain member',
    provider = 'various-textobjs',
    'chainMember',
  },
  gw = {
    desc = 'Visible in window',
    provider = 'various-textobjs',
    args = false,
    'visibleInWindow',
  },
  gW = {
    desc = 'Rest of window',
    provider = 'various-textobjs',
    args = false,
    'restOfWindow',
  },
  ['<c-e>'] = {
    desc = 'Last change',
    provider = 'various-textobjs',
    args = false,
    'lastChange',
  },
  ['.'] = {
    desc = 'Emoji',
    provider = 'various-textobjs',
    args = false,
    'emoji',
  },
  ['<c-a>'] = {
    desc = { 'Number', i = 'natural', a = 'real' },
    provider = 'various-textobjs',
    'number',
  },
  F = {
    desc = 'Filepath',
    provider = 'various-textobjs',
    'filepath',
  },
  ['#'] = {
    desc = { 'Color', only = 'value' },
    provider = 'various-textobjs',
    'color',
  },
  S = {
    desc = { 'css Selector', with = 'trailing comma and space' },
    provider = 'various-textobjs',
    'cssSelector',
  },
  ['|'] = {
    desc = { 'shell pipe', with = '|' },
    provider = 'various-textobjs',
    'shellPipe',
  },
  i = {
    desc = { 'Indentation', with = 'lines above/below' },
    provider = 'various-textobjs',
    'indentation',
    args = { i = { 'inner', 'inner' }, a = { 'outer', 'outer' } },
  },
  I = {
    desc = { i = 'Rest of indentation', a = 'Greedy outer indentation' },
    provider = 'various-textobjs',
    { i = 'restOfIndentation', a = 'greedyOuterIndentation' },
    args = { i = false, a = 'inner' },
  },
}

return {
  {
    'echasnovski/mini.ai',
    event = 'VeryLazy',
    opts = function()
      local custom_textobjects = {}
      for key, spec in pairs(textobjs) do
        if spec.provider == 'treesitter' then
          if spec.args == false then
            vim.notify(
              ('Textobj %s: args = false is not supported for treesitter provider'):format(key),
              vim.log.levels.WARN,
              { title = 'mini.ai' }
            )
            break
          end
          local args = vim.tbl_deep_extend('force', {
            i = 'inner',
            a = 'outer',
          }, spec.args or {})

          local ts_spec = { i = {}, a = {} }
          if spec[2] == nil then
            ts_spec.i = '@' .. spec[1] .. '.' .. args.i
            ts_spec.a = '@' .. spec[1] .. '.' .. args.a
          else
            for _, node in ipairs(spec) do
              ts_spec.i[#ts_spec.i + 1] = '@' .. node .. '.' .. args.i
              ts_spec.a[#ts_spec.a + 1] = '@' .. node .. '.' .. args.a
            end
          end

          custom_textobjects[key] = fn { 'mini.ai::gen_spec.treesitter', ts_spec }()
        end

        if spec.provider == 'mini.ai' then
          local mini_spec = {}
          for _, pattern in ipairs(spec) do
            mini_spec[#mini_spec + 1] = pattern
          end
          custom_textobjects[key] = mini_spec
        end
      end

      return {
        custom_textobjects = vim.tbl_deep_extend('force', custom_textobjects, {
          u = fn 'mini.ai::gen_spec.function_call',
          U = fn { 'mini.ai::gen_spec.function_call', { name_pattern = '[%w_]' } },
        }),
        mappings = {
          goto_left = '', -- custom behavior defined in keys
          goto_right = '}',
          around_next = ']a',
          inside_next = ']i',
          around_last = '[a',
          inside_last = '[i',
        },
      }
    end,

    keys = function()
      local keys = {}

      for key, spec in pairs(textobjs) do
        if spec.provider == 'treesitter' or spec.provider == 'mini.ai' then
          local desc = format_desc(spec.desc, 'a', spec)

          table.insert(keys, {
            (']%s'):format(key),
            fn { 'mini.ai.move_cursor', 'left', 'a', key, { search_method = 'next' } },
            desc = ('next %s start'):format(desc),
          })

          table.insert(keys, {
            ('[%s'):format(key),
            fn { 'mini.ai.move_cursor', 'left', 'a', key, { search_method = 'cover_or_prev' } },
            desc = ('this or previous %s start'):format(desc),
          })

          table.insert(keys, {
            ('{%s'):format(key),
            fn { 'mini.ai.move_cursor', 'right', 'a', key, { search_method = 'prev' } },
            desc = ('previous %s end'):format(desc),
          })
        end
      end

      return keys
    end,
  },

  {
    'chrisgrieser/nvim-various-textobjs',
    dependencies = { 'echasnovski/mini.ai' },
    opts = {},
    keys = function()
      local keys = {}
      for key, spec in pairs(textobjs) do
        if spec.provider == 'various-textobjs' then
          local args = vim.tbl_deep_extend('force', {
            i = 'inner',
            a = 'outer',
          }, spec.args or {})

          local vto_spec = { i = '', a = '' }
          if type(args.i) == 'table' then
            for index, arg in ipairs(args.i) do
              vto_spec.i = vto_spec.i .. "'" .. arg .. "'"
              if index < #args.i then vto_spec.i = vto_spec.i .. ', ' end
            end
          end
          if type(args.a) == 'table' then
            for index, arg in ipairs(args.a) do
              vto_spec.a = vto_spec.a .. "'" .. arg .. "'"
              if index < #args.a then vto_spec.a = vto_spec.a .. ', ' end
            end
          end

          if type(args.i) == 'string' then vto_spec.i = "'" .. args.i .. "'" end
          if type(args.a) == 'string' then vto_spec.a = "'" .. args.a .. "'" end

          if spec[2] == nil then
            -- Handle multiple functions case with { i = 'func1', a = 'func2' }
            if type(spec[1]) == 'table' and spec[1].i and spec[1].a then
              vto_spec.i = ("<cmd>lua require 'various-textobjs'.%s(%s)<cr>"):format(spec[1].i, vto_spec.i)
              vto_spec.a = ("<cmd>lua require 'various-textobjs'.%s(%s)<cr>"):format(spec[1].a, vto_spec.a)
            else
              -- Single function case
              vto_spec.i = ("<cmd>lua require 'various-textobjs'.%s(%s)<cr>"):format(spec[1], vto_spec.i)
              vto_spec.a = ("<cmd>lua require 'various-textobjs'.%s(%s)<cr>"):format(spec[1], vto_spec.a)
            end
          else
            -- TODO: handle multiple patterns
            vim.notify(
              ('Textobj %s: multiple patterns are not supported yet for various-textobjs provider'):format(key),
              vim.log.levels.WARN,
              { title = 'various-textobjs' }
            )
          end

          for mode, mapping in pairs { i = vto_spec.i, a = vto_spec.a } do
            local desc = format_desc(spec.desc, mode, spec)

            table.insert(keys, {
              (mode .. key),
              mapping,
              desc = desc,
              mode = { 'o', 'x' },
            })
          end
        end
      end

      return keys
    end,
    -- keys = {
    --   { desc = 'Subword', 'iN', VTO:format [[subword 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Subword and hyphens', 'aN', VTO:format [[subword 'outer']], mode = { 'o', 'x' } },
    --
    --   {
    --     desc = 'next Subword',
    --     'N',
    --     function() require('mini.ai').move_cursor('left', 'i', 'N', { search_method = 'next' }) end,
    --     mode = { 'n', 'x', 'o' },
    --   },
    --   {
    --     desc = 'prev Subword',
    --     'M',
    --     function() require('mini.ai').move_cursor('left', 'i', 'N', { search_method = 'prev' }) end,
    --     mode = { 'n', 'x', 'o' },
    --   },
    --
    --   { desc = 'To next closing bracket', 'iK', VTO:format [[toNextClosingBracket()]], mode = { 'o', 'x' } },
    --   { desc = 'To next closing bracket', 'aK', VTO:format [[toNextClosingBracket()]], mode = { 'o', 'x' } },
    --   { desc = 'Near EoL', ',', VTO:format 'nearEoL()', mode = { 'o', 'x' } },
    --   { desc = 'To next quotation mark', 'iQ', VTO:format [[toNextQuotationMark()]], mode = { 'o', 'x' } },
    --   { desc = 'To next quotation mark', 'aQ', VTO:format [[toNextQuotationMark()]], mode = { 'o', 'x' } },
    --   { desc = 'Rest of paragraph', 'iP', VTO:format [[restOfParagraph()]], mode = { 'o', 'x' } },
    --   { desc = 'Rest of paragraph', 'aP', VTO:format [[restOfParagraph()]], mode = { 'o', 'x' } },
    --   { desc = 'Entire buffer', 'gG', VTO:format [[entireBuffer()]], mode = { 'o', 'x' } },
    --   { desc = 'Near EoL', ',', VTO:format 'nearEoL()', mode = { 'o', 'x' } },
    --   { desc = 'Line characterwise', 'i_', VTO:format [[lineCharacterwise 'inner']], mode = { 'o', 'x' } },
    --   {
    --     desc = 'Line characterwise with indentation and trailing space',
    --     'a_',
    --     VTO:format [[lineCharacterwise 'outer']],
    --     mode = { 'o', 'x' },
    --   },
    --   { desc = 'Rest of column', 'i<c-v>', VTO:format [[column('down')]], mode = { 'o', 'x' } },
    --   { desc = 'Column', 'a<c-v>', VTO:format [[column('both')]], mode = { 'o', 'x' } },
    --   { desc = 'Value', 'iv', VTO:format [[value 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Value and trailing comma or semicolon', 'av', VTO:format [[value 'outer']], mode = { 'o', 'x' } },
    --   { desc = 'Variable', 'iV', VTO:format [[key 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Variable and operator)', 'aV', VTO:format [[key 'outer']], mode = { 'o', 'x' } },
    --   { desc = 'URL', 'L', VTO:format [[url()]], mode = { 'o', 'x' } },
    --   { desc = 'Diagnostic', '!', VTO:format [[diagnostic()]], mode = { 'o', 'x' } },
    --   -- { desc = "Closed fold", "iz", VTO:format[[closedFold 'inner']], mode = { 'o', 'x' } },
    --   -- { desc = "Closed fold and blank line", "az", VTO:format[[closedFold 'outer']], mode = { 'o', 'x' } },
    --   { desc = 'Chain member', 'im', VTO:format [[chainMember 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Dot/colon and chain Member', 'am', VTO:format [[chainMember 'outer']], mode = { 'o', 'x' } },
    --   { desc = 'Visible in window', 'gw', VTO:format [[visibleInWindow()]], mode = { 'o', 'x' } },
    --   { desc = 'Rest of window', 'gW', VTO:format [[restOfWindow()]], mode = { 'o', 'x' } },
    --   { desc = 'Last change', 'ie', VTO:format [[lastChange()]], mode = { 'o', 'x' } },
    --   { desc = 'Last change', 'ae', VTO:format [[lastChange()]], mode = { 'o', 'x' } },
    --   { desc = 'Emoji', '.', VTO:format [[emoji()]], mode = { 'o', 'x' } },
    --   { desc = 'Natural number', 'i<c-a>', VTO:format [[number 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Real number', 'a<c-a>', VTO:format [[number 'outer']], mode = { 'o', 'x' } },
    --   { desc = 'Filepath', 'iF', VTO:format [[filepath 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Filepath', 'aF', VTO:format [[filepath 'outer']], mode = { 'o', 'x' } },
    --   { desc = 'Color (value only)', 'i#', VTO:format [[color 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Color', 'a#', VTO:format [[color 'outer']], mode = { 'o', 'x' } },
    --   { desc = 'CSS selector', 'iS', VTO:format [[cssSelector 'inner']], mode = { 'o', 'x' } },
    --   {
    --     desc = 'CSS selector with trailing comma and space',
    --     'aS',
    --     VTO:format [[cssSelector 'outer']],
    --     mode = { 'o', 'x' },
    --   },
    --   { desc = 'Program after pipe', 'i|', VTO:format [[shellPipe 'inner']], mode = { 'o', 'x' } },
    --   { desc = 'Pipe and program', 'a|', VTO:format [[shellPipe 'outer']], mode = { 'o', 'x' } },
    --
    --   {
    --     desc = 'Delete Surrounding Indentation',
    --     'rdi',
    --     function()
    --       require('various-textobjs').indentation('outer', 'outer')
    --       -- plugin only switches to visual mode when textobj found
    --       local notOnIndentedLine = vim.fn.mode():find 'V' == nil
    --       if notOnIndentedLine then return end
    --       -- dedent indentation
    --       vim.cmd.normal { '>', bang = true }
    --       -- delete surrounding lines
    --       local endBorderLn = vim.api.nvim_buf_get_mark(0, '>')[1] + 1
    --       local startBorderLn = vim.api.nvim_buf_get_mark(0, '<')[1] - 1
    --       vim.cmd(tostring(endBorderLn) .. ' delete') -- delete end first so line index is not shifted
    --       vim.cmd(tostring(startBorderLn) .. ' delete')
    --     end,
    --   },
    --
    --   {
    --     'ryi',
    --     function()
    --       local startPos = vim.api.nvim_win_get_cursor(0)
    --
    --       -- identify start- and end-border
    --       require('various-textobjs').indentation('outer', 'outer')
    --       local indentationFound = vim.fn.mode():find 'V'
    --       if not indentationFound then return end
    --       vim.cmd.normal { 'V', bang = true }
    --
    --       -- copy them into the + register
    --       local startLn = vim.api.nvim_buf_get_mark(0, '<')[1] - 1
    --       local endLn = vim.api.nvim_buf_get_mark(0, '>')[1] - 1
    --       local startLine = vim.api.nvim_buf_get_lines(0, startLn, startLn + 1, false)[1]
    --       local endLine = vim.api.nvim_buf_get_lines(0, endLn, endLn + 1, false)[1]
    --       vim.fn.setreg([["]], startLine .. '\n' .. endLine .. '\n')
    --
    --       -- highlight yanked text
    --       local dur = 500
    --       local ns = vim.api.nvim_create_namespace 'ysi'
    --       local bufnr = vim.api.nvim_get_current_buf()
    --       vim.hl.range(bufnr, ns, 'IncSearch', { startLn, 0 }, { startLn, -1 }, { timeout = dur })
    --       vim.hl.range(bufnr, ns, 'IncSearch', { endLn, 0 }, { endLn, -1 }, { timeout = dur })
    --
    --       -- restore cursor position
    --       vim.api.nvim_win_set_cursor(0, startPos)
    --     end,
    --     desc = 'Yank surrounding indentation',
    --   },
    --
    --   {
    --     '<leader>ryi',
    --     function()
    --       local startPos = vim.api.nvim_win_get_cursor(0)
    --
    --       -- identify start- and end-border
    --       require('various-textobjs').indentation('outer', 'outer')
    --       local indentationFound = vim.fn.mode():find 'V'
    --       if not indentationFound then return end
    --       vim.cmd.normal { 'V', bang = true }
    --
    --       -- copy them into the + register
    --       local startLn = vim.api.nvim_buf_get_mark(0, '<')[1] - 1
    --       local endLn = vim.api.nvim_buf_get_mark(0, '>')[1] - 1
    --       local startLine = vim.api.nvim_buf_get_lines(0, startLn, startLn + 1, false)[1]
    --       local endLine = vim.api.nvim_buf_get_lines(0, endLn, endLn + 1, false)[1]
    --       vim.fn.setreg('+', startLine .. '\n' .. endLine .. '\n')
    --
    --       -- highlight yanked text
    --       local dur = 500
    --       local ns = vim.api.nvim_create_namespace 'ysi'
    --       local bufnr = vim.api.nvim_get_current_buf()
    --       vim.hl.range(bufnr, ns, 'IncSearch', { startLn, 0 }, { startLn, -1 }, { timeout = dur })
    --       vim.hl.range(bufnr, ns, 'IncSearch', { endLn, 0 }, { endLn, -1 }, { timeout = dur })
    --
    --       -- restore cursor position
    --       vim.api.nvim_win_set_cursor(0, startPos)
    --     end,
    --     desc = 'Yank surrounding indentation to clipboard',
    --   },
    -- },
  },
}
