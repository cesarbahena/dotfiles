local M = {}

local VALID_OPTS =  {
  noremap = true,
  nowait = true,
  silent = true,
  expr = true,
  unique = true,
  script = true,
  desc = true,
  callback = true,
  replace_keycodes = true,
  remap = true,
  buffer = true,
}

-- It's meant to be used when which-key is not installed
function M.add(tbl, inherited_opts)
  -- Inherit valid opts
  local inherited_opts = inherited_opts or {}
  local opts = {}
  local mode = inherited_opts.mode
  for k, v in pairs(inherited_opts) do
    if VALID_OPTS[k] then opts[k] = v end
  end
  
  -- Override/add local valid opts
  for k, v in pairs(tbl) do
    if VALID_OPTS[k] then opts[k] = v end
    if k == 'mode' then mode = v end
  end
  
  -- Handle a keymap definition in this table if present
  if type(tbl[1]) == 'string' and tbl[2] ~= nil then
    vim.keymap.set(mode or 'n', tbl[1], tbl[2], opts)
  end
  
  -- Recurse into child tables
  for _, v in ipairs(tbl) do
    if type(v) == "table" then
      try(
        M.add, 
        v, 
        vim.tbl_extend(
          "force", 
          { mode = tbl.mode or inherited_opts.mode }, 
          opts
        )
      )
    end
  end
end

return M
