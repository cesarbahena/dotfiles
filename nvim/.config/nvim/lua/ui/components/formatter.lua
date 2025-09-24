local M = {}

function M.discover_config_files(formatter_name)
  local patterns = {
    '.' .. formatter_name .. 'rc',
    '.' .. formatter_name .. 'rc.json',
    '.' .. formatter_name .. 'rc.js',
    '.' .. formatter_name .. 'rc.yaml',
    '.' .. formatter_name .. 'rc.yml',
    formatter_name .. '.config.js',
    formatter_name .. '.config.json',
    formatter_name .. '.toml',
    '.' .. formatter_name .. '.toml',
    'package.json',
    'pyproject.toml',
  }

  local found = {}
  for _, pattern in ipairs(patterns) do
    if vim.fn.filereadable(pattern) == 1 then table.insert(found, pattern) end
  end
  return found
end

function M.parse_config_file(filepath, formatter_name)
  local content = vim.fn.readfile(filepath)
  if #content == 0 then return nil end

  local full_content = table.concat(content, '\n')

  local ok, config = pcall(vim.json.decode, full_content)
  if ok then
    if filepath:match 'package%.json$' then return config[formatter_name] or config.prettier or config.eslint end
    return config
  end

  config = {}
  for _, line in ipairs(content) do
    local trimmed = line:match '^%s*(.-)%s*$'
    if trimmed and not trimmed:match '^[#%[]' and trimmed:find '=' then
      local key, value = trimmed:match '^([^=]+)%s*=%s*(.+)$'
      if key and value then
        key = key:gsub('%s+', ''):gsub('%-', '_')
        value = value:gsub('^["\']', ''):gsub('["\']$', '')
        local num = tonumber(value)
        if num then
          config[key] = num
        elseif value:lower() == 'true' then
          config[key] = true
        elseif value:lower() == 'false' then
          config[key] = false
        else
          config[key] = value
        end
      end
    end
  end

  return next(config) and config or nil
end

function M.generate_flag_variants(key, value)
  local flag_name = key:gsub('([a-z])([A-Z])', '%1-%2'):gsub('_', '-'):lower()

  local full_flag
  if type(value) == 'boolean' then
    if value then
      full_flag = '--' .. flag_name
    else
      full_flag = '--no-' .. flag_name:gsub('^no%-', '')
    end
  else
    full_flag = '--' .. flag_name .. '=' .. tostring(value)
  end

  local abbrev_letters = {}
  for word in flag_name:gmatch '[^-]+' do
    table.insert(abbrev_letters, word:sub(1, 1))
  end
  local abbrev = '-' .. table.concat(abbrev_letters, '')
  if type(value) ~= 'boolean' then abbrev = abbrev .. '=' .. tostring(value) end

  local compact = table.concat(abbrev_letters, '')

  return full_flag, abbrev, compact
end

local formatter_cache = {}

function M.get_flag_levels(formatter_name)
  local cwd = vim.fn.getcwd()
  local cache_key = formatter_name .. ':' .. cwd

  if formatter_cache[cache_key] then return formatter_cache[cache_key] end

  local flag_levels = { '', '', '' }

  local config_files = M.discover_config_files(formatter_name)
  if #config_files == 0 then
    formatter_cache[cache_key] = flag_levels
    return flag_levels
  end

  local config = nil
  for _, config_file in ipairs(config_files) do
    config = M.parse_config_file(config_file, formatter_name)
    if config then break end
  end

  if not config then
    formatter_cache[cache_key] = flag_levels
    return flag_levels
  end

  local full_flags = {}
  local abbrev_flags = {}
  local compact_letters = {}

  for key, value in pairs(config) do
    if value ~= nil and (type(value) ~= 'boolean' or value ~= false or key:match 'semi') then
      local full, abbrev, compact = M.generate_flag_variants(key, value)
      table.insert(full_flags, full)
      table.insert(abbrev_flags, abbrev)
      table.insert(compact_letters, compact)
    end
  end

  flag_levels = {
    table.concat(full_flags, ' '),
    table.concat(abbrev_flags, ' '),
    #compact_letters > 0 and ('-' .. table.concat(compact_letters, '')) or '',
  }

  formatter_cache[cache_key] = flag_levels
  return flag_levels
end

function M.display()
  local current_cwd = vim.fn.getcwd()
  local total_width = vim.o.columns
  local working_dir_width = #vim.fn.fnamemodify(current_cwd, ':~')

  local branch_width = 10
  local git_status_width = 10
  local lsp_width = 10
  local harpoon_width = 10
  local right_side_width = 20

  local used_width = working_dir_width + branch_width + git_status_width + lsp_width + harpoon_width + right_side_width
  local space_budget = total_width - used_width - 5

  local result = {}
  local buf_clients = vim.lsp.get_clients { bufnr = 0 }

  for _, client in ipairs(buf_clients) do
    for _, lf_name in ipairs { 'efm', 'null-ls' } do
      if client.name:lower():find(lf_name:lower()) then
        table.insert(result, client.name)
        break
      end
    end
  end

  local ok, conform = pcall(require, 'conform')
  if ok then
    local formatters = conform.list_formatters(0)
    local space_used = 0

    for i, formatter in ipairs(formatters) do
      if formatter.available then
        local formatter_name = formatter.name
        local flag_levels = M.get_flag_levels(formatter_name)

        local chosen_flags = ''
        local space_remaining = space_budget - space_used
        local separator_cost = (#result > 0) and 3 or 0

        for j, level in ipairs(flag_levels) do
          local full_text = formatter_name .. (level ~= '' and (' ' .. level) or '')
          local total_cost = #full_text + separator_cost

          if total_cost <= space_remaining then
            chosen_flags = level
            space_used = space_used + total_cost
            break
          end
        end

        local formatter_str = formatter_name .. (chosen_flags ~= '' and (' ' .. chosen_flags) or '')
        table.insert(result, formatter_str)
      end
    end
  end

  if #result == 0 then return '' end

  return ' | ' .. table.concat(result, ' | ')
end

vim.api.nvim_create_autocmd('DirChanged', {
  callback = function() formatter_cache = {} end,
})

return M