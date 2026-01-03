-- Blink.cmp source for vim-dadbod-completion

local M = {}

M.new = function()
  return setmetatable({}, { __index = M })
end

function M:get_trigger_characters()
  return { '.', ' ' }
end

function M:get_completions(ctx, callback)
  if vim.bo.filetype ~= 'sql' and vim.bo.filetype ~= 'mysql' and vim.bo.filetype ~= 'plsql' then
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} })
    return
  end

  -- Use vim-dadbod-completion's omnifunc
  local line = ctx.line
  local col = ctx.column
  
  -- Call the omnifunc to get completions
  local completions = vim.fn['vim_dadbod_completion#omni'](0, '')
  if not completions or #completions == 0 then
    callback({ is_incomplete_forward = false, is_incomplete_backward = false, items = {} })
    return
  end

  local items = {}
  for _, item in ipairs(completions) do
    table.insert(items, {
      label = item.word or item,
      kind = vim.lsp.protocol.CompletionItemKind.Field,
      documentation = item.info or nil,
    })
  end

  callback({
    is_incomplete_forward = false,
    is_incomplete_backward = false,
    items = items
  })
end

return M