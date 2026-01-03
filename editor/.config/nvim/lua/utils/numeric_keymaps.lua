local M = {}

-- Generate numeric keymaps based on JSON configuration
function M.setup()
  local key_descriptions = _G.key_descriptions
  if not key_descriptions then return end

  -- Extract tens configuration from meta section
  local tens_digits = key_descriptions.meta and key_descriptions.meta.tens or {}

  -- Find keys that map to digits in leader section
  local digit_to_key = {}
  if key_descriptions.leader then
    for key, desc in pairs(key_descriptions.leader) do
      if desc:match '^%d$' then digit_to_key[tonumber(desc)] = key end
    end
  end

  -- Map single digits 1-0 (instant)
  for digit = 1, 9 do
    local key = digit_to_key[digit]
    if key then
      local lhs = '<leader>' .. key
      vim.keymap.set({ 'n', 'x', 'o' }, lhs, tostring(digit), { desc = 'Count ' .. digit })
    end
  end

  -- Map 0 (instant)
  local zero_key = digit_to_key[0]
  if zero_key then vim.keymap.set({ 'n', 'x', 'o' }, '<leader>' .. zero_key, '10', { desc = 'Count 10' }) end

  -- Generate tens combinations only for digits in tens array
  for _, tens in ipairs(tens_digits) do
    local tens_key = digit_to_key[tens]
    if tens_key then
      -- Generate combinations: tens_key + any digit key (11-19, 21-29, 31-39)
      for digit = 1, 9 do
        local ones_key = digit_to_key[digit]
        if ones_key then
          local lhs = '<leader>' .. tens_key .. ones_key
          local count = tens * 10 + digit

          vim.keymap.set({ 'n', 'x', 'o' }, lhs, tostring(count), { desc = 'Count ' .. count })
        end
      end

      -- Add tens + 0 combination (10, 20, 30)
      if zero_key then
        local lhs = '<leader>' .. tens_key .. zero_key
        local count = tens * 10

        vim.keymap.set({ 'n', 'x', 'o' }, lhs, tostring(count), { desc = 'Count ' .. count })
      end
    end
  end
end

return M

