---@class KeyAutoRegister
local M = {}

local spec_gen = require('utils.keymap_spec_generator')

-- Save current key_descriptions to JSON with fixed category order and sorted keys
local function save_to_json()
  local config_path = vim.fn.stdpath('config') .. '/json/' .. _G.KeyboardLayout .. '.json'
  
  -- Fixed category order
  local category_order = { 'keys', 'leader', 'control', 'alt', 'local_leader' }
  
  -- Build sorted structure
  local sorted_data = {}
  for _, category in ipairs(category_order) do
    if _G.key_descriptions[category] then
      -- Sort keys within each category
      local keys = _G.key_descriptions[category]
      local sorted_keys = {}
      for key in pairs(keys) do
        table.insert(sorted_keys, key)
      end
      table.sort(sorted_keys)
      
      -- Build sorted category
      sorted_data[category] = {}
      for _, key in ipairs(sorted_keys) do
        sorted_data[category][key] = keys[key]
      end
    end
  end
  
  -- Preserve meta section if it exists
  if _G.key_descriptions.meta then
    sorted_data.meta = _G.key_descriptions.meta
  end
  
  local encoded = vim.json.encode(sorted_data)
  vim.fn.writefile(vim.split(encoded, '\n'), config_path)
end

-- Scan for missing key descriptions in content
function M.scan_for_missing_keys(content)
  local missing = {}
  
  -- List of all helper functions that use the key system
  local key_functions = {
    'key', 'motion', 'operator', 'auto_select', 'on_selection', 'insert'
  }
  
  -- Check each function individually since Lua patterns don't support | alternation
  for _, func_name in ipairs(key_functions) do
    local pattern = func_name .. '%s*{%s*[\'"]([^\'",]+)[\'"]*'
    
    for desc in content:gmatch(pattern) do
      -- Test if the description exists in the lookup table
      local success = pcall(spec_gen.key, { desc })
      if not success then
        -- Check if already added to avoid duplicates
        local already_added = false
        for _, existing in ipairs(missing) do
          if existing == desc then
            already_added = true
            break
          end
        end
        if not already_added then
          table.insert(missing, desc)
        end
      end
    end
  end
  
  return missing
end

-- Prompt for key assignment
local function prompt_for_key(desc)
  local categories = { k = 'keys', c = 'control', l = 'leader', a = 'alt' }
  
  local cat_input = vim.fn.input('Category for "' .. desc .. '"? [k/c/l/a]: ')
  local category = categories[cat_input:lower()]
  
  if not category then
    vim.notify('Invalid category', vim.log.levels.WARN)
    return
  end
  
  local key = vim.fn.input('Key for "' .. desc .. '": ')
  if key == '' then
    vim.notify('No key provided', vim.log.levels.WARN)
    return
  end
  
  -- Always handle multiple descriptions - never override existing keys
  if _G.key_descriptions[category] and _G.key_descriptions[category][key] then
    local existing = _G.key_descriptions[category][key]
    if type(existing) == 'string' then
      -- Convert single description to array and add new one
      _G.key_descriptions[category][key] = { existing, desc }
    elseif type(existing) == 'table' then
      -- Add to existing array
      table.insert(_G.key_descriptions[category][key], desc)
    end
    -- Update the mapping (this calls rebuild_lookup internally)
    spec_gen.add_key_mapping(category, key, _G.key_descriptions[category][key])
  else
    -- Use existing add_key_mapping for new keys
    spec_gen.add_key_mapping(category, key, desc)
  end
  
  -- Save to JSON
  save_to_json()
  
  vim.notify('Added: ' .. key .. ' → "' .. desc .. '"')
end

-- Handle missing keys
function M.handle_missing_keys(missing_keys)
  if #missing_keys == 0 then return end
  
  for _, desc in ipairs(missing_keys) do
    prompt_for_key(desc)
  end
end

-- Setup autocommand (deprecated - now handled in core/autocmd.lua)
function M.setup()
  -- This function is kept for backwards compatibility but does nothing
  -- The autocommand is now set up in core/autocmd.lua
end

return M