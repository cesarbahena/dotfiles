local M = {}

-- Load key descriptions from JSON
local function load_key_descriptions()
  local config_path = vim.fn.stdpath 'config' .. '/json/' .. _G.KeyboardLayout .. '.json'
  if vim.fn.filereadable(config_path) == 1 then
    local content = table.concat(vim.fn.readfile(config_path), '')
    return vim.json.decode(content)
  end
  return {}
end

local key_descriptions = load_key_descriptions()
_G.key_descriptions = key_descriptions

-- Helper function to normalize description for lookup
local function normalize_desc(desc)
  -- Convert numbers to strings first
  desc = tostring(desc)
  return desc:lower():gsub('[%s%-_%*]', '')
end

-- Helper function to build key string from category and key
local function build_key(category, key)
  if category == 'keys' then
    return key -- Use key as-is
  elseif category == 'control' then
    return '<c-' .. key .. '>'
  elseif category == 'alt' then
    return '<m-' .. key .. '>'
  elseif category == 'leader' then
    return '<leader>' .. key
  elseif category == 'local_leader' then
    return '<localleader>' .. key
  end
end

-- Build initial lookup from structured table
local description_to_key = {}
for category, keys in pairs(key_descriptions) do
  -- Skip meta section as it's configuration, not keybindings
  if category ~= 'meta' then
    for key, desc_or_table in pairs(keys) do
      local full_key = build_key(category, key)

      if type(desc_or_table) == 'string' then
        -- Single description
        local normalized = normalize_desc(desc_or_table)
        if description_to_key[normalized] then
          error(
            'Duplicate description found: "'
              .. desc_or_table
              .. '" normalizes to "'
              .. normalized
              .. '" which conflicts with existing key "'
              .. description_to_key[normalized]
              .. '"'
          )
        end
        description_to_key[normalized] = full_key
      elseif type(desc_or_table) == 'table' then
        -- Multiple descriptions - add each to lookup
        for _, desc in pairs(desc_or_table) do
          local normalized = normalize_desc(desc)
          if description_to_key[normalized] then
            error(
              'Duplicate description found: "'
                .. desc
                .. '" normalizes to "'
                .. normalized
                .. '" which conflicts with existing key "'
                .. description_to_key[normalized]
                .. '"'
            )
          end
          description_to_key[normalized] = full_key
        end
      end
    end
  end -- Close the meta skip condition
end

-- vim.print(description_to_key)
-- Function to rebuild reverse lookup when key_descriptions changes
local function rebuild_lookup()
  description_to_key = {}
  for category, keys in pairs(key_descriptions) do
    if category ~= 'meta' then
      for key, desc_or_table in pairs(keys) do
        local full_key = build_key(category, key)

        if type(desc_or_table) == 'string' then
          description_to_key[normalize_desc(desc_or_table)] = full_key
        elseif type(desc_or_table) == 'table' then
          for _, desc in pairs(desc_or_table) do
            description_to_key[normalize_desc(desc)] = full_key
          end
        end
      end
    end
  end
end

-- Core spec generator function
function M.key(spec)
  local normalized = normalize_desc(spec[1])

  local lhs = description_to_key[normalized]
  if not lhs then error('No key found for description: ' .. spec[1]) end

  spec.desc = spec[1]
  spec[1] = lhs

  if not spec.details then return spec end

  local separator = spec.details:match '^,' and '' or ' '
  spec.desc = spec.desc .. separator .. spec.details
  spec.details = nil

  return spec
end

-- Mode-specific helper functions

function M.insert(spec)
  spec.mode = 'i'
  return M.key(spec)
end

function M.on_selection(spec)
  spec.mode = 'x'
  return M.key(spec)
end

-- Mode combinations
function M.motion(spec)
  spec.mode = { 'n', 'o', 'x' }
  return M.key(spec)
end

function M.operator(spec)
  spec.mode = { 'o', 'x' }
  return M.key(spec)
end

function M.auto_select(spec)
  spec.mode = { 'n', 'x' }
  return M.key(spec)
end

-- Helper functions
function M.get_key(desc) return description_to_key[desc] end

function M.get_description(key) return key_descriptions[key] end

function M.add_key_mapping(category, key, desc)
  if not key_descriptions[category] then key_descriptions[category] = {} end
  key_descriptions[category][key] = desc
  rebuild_lookup()
end

function M.update_key_mapping(category, old_key, new_key)
  if key_descriptions[category] and key_descriptions[category][old_key] then
    local desc = key_descriptions[category][old_key]
    key_descriptions[category][old_key] = nil
    key_descriptions[category][new_key] = desc
    rebuild_lookup()
  end
end

return M
