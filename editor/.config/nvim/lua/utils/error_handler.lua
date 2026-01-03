local M = {}

-- Enhanced error message parsing
function M.split_error_message(msg)
  if type(msg) ~= 'string' then return '', {} end

  local first_line = msg:match '([^\n]*)'
  local rest = msg:sub(#first_line + 2)
  local raw_lines = vim.split(rest, '\n', { plain = true, trimempty = true })

  -- Clean and filter traceback lines
  local details = {}
  for _, line in ipairs(raw_lines) do
    local cleaned = vim.trim(line)
    -- Skip internal lua/nvim lines and keep user code
    if cleaned ~= '' and not cleaned:match '^%s*%[C%]' and not cleaned:match 'vim/_editor%.lua' then
      table.insert(details, cleaned)
    end
  end

  return vim.trim(first_line), details
end

-- Clean error message by removing redundant file path
function M.clean_error_message(msg)
  -- Handle nested error messages - get the actual error after the last file path
  -- Pattern: "file1.lua:0: file2.lua:123: actual error" -> "actual error"
  local cleaned = msg:match '^.*%.lua:%d+: (.+)$' or msg
  return cleaned
end

-- Format traceback for better readability
function M.format_traceback(traceback_lines)
  local formatted = {}
  local step = 1
  local last_location = nil

  for _, line in ipairs(traceback_lines) do
    -- Skip header line
    if line:match '^stack traceback:' then goto continue end

    -- Extract file path and line number
    local file, line_num, func_info = line:match '([^:]+):(%d+): ?(.*)$'

    if file and line_num then
      -- Get just the filename, not full path
      local filename = file:match '([^/]+)$' or file
      local location = filename .. ':' .. line_num

      -- Skip error_handler internal calls and duplicate consecutive locations
      if filename:match 'error_handler%.lua' or location == last_location then goto continue end

      -- Clean up function information
      local context = func_info and func_info ~= '' and func_info or 'main chunk'
      -- Remove various noise patterns
      context = context:gsub('^in ', '')
      context = context:gsub('^function ', '')
      context = context:gsub("^'(.+)'$", '%1') -- Remove quotes around function names
      context = context:gsub('^<.+>$', 'anonymous function') -- Clean up <path> patterns

      table.insert(formatted, string.format('%d. %s → %s', step, location, context))
      step = step + 1
      last_location = location
    end

    ::continue::
  end

  return formatted
end

-- Initialize global errors table
_G.Errors = _G.Errors or {}

-- Create error object helper
local function create_error(err, fn)
  local first_line, details = M.split_error_message(err)
  local full_traceback = debug.traceback('', 2)
  local _, raw_traceback = M.split_error_message(full_traceback)

  local source_info = M.extract_source_info(full_traceback, fn, first_line)
  local category = M.categorize_error(first_line, source_info)
  local formatted_traceback = M.format_traceback(raw_traceback)

  return {
    message = M.clean_error_message(first_line),
    details = details,
    traceback = formatted_traceback,
    source = source_info.source,
    line = source_info.line,
    category = category,
    time = os.date '%Y-%m-%d %H:%M:%S',
  }
end

-- Helper function to detect table type
local function detect_table_type(config)
  -- Check if first element is a function and second is a table
  if type(config[1]) == 'function' and type(config[2]) == 'table' then return 'function_with_arg_tables' end
  -- Check if first element is a table (traditional batching)
  if type(config[1]) == 'table' then return 'batching' end
  -- Single operation
  return 'single_operation'
end

-- Execute a single operation with error handling
local function execute_single(operation_config)
  local fn = operation_config[1]
  local fn_args = {}
  for i = 2, #operation_config do
    -- Skip named parameters
    if type(i) == 'number' and not operation_config.or_else and not operation_config.catch then
      table.insert(fn_args, operation_config[i])
    elseif
      type(operation_config[i]) ~= 'string'
      or (operation_config[i] ~= 'or_else' and operation_config[i] ~= 'catch')
    then
      table.insert(fn_args, operation_config[i])
    end
  end

  if type(fn) ~= 'function' then error 'Operation first element must be a function' end

  local ok, result = xpcall(function() return fn(unpack(fn_args)) end, function(err) return create_error(err, fn) end)

  if not ok then
    local error_obj = result

    -- Handle per-operation catch
    if operation_config.catch then
      if type(operation_config.catch) == 'function' then
        local modified_error = operation_config.catch(error_obj)
        if modified_error then table.insert(_G.Errors, modified_error) end
      end
    else
      -- Store error if no catch handler
      table.insert(_G.Errors, error_obj)
    end

    -- Handle per-operation or_else
    if operation_config.or_else then
      if type(operation_config.or_else) == 'function' then
        return true, operation_config.or_else()
      else
        return true, operation_config.or_else
      end
    end
  end

  return ok, result
end

-- Execute function with multiple argument sets
local function execute_function_with_arg_tables(config)
  local fn = config[1]
  local results = {}
  local all_ok = true
  local collect_results = config.collect_results ~= false
  local on_error = config.on_error or 'continue'

  -- Process each argument table
  for i = 2, #config do
    local arg_config = config[i]
    if type(arg_config) == 'table' then
      -- Extract arguments (skip named parameters)
      local fn_args = {}
      for j = 1, #arg_config do
        table.insert(fn_args, arg_config[j])
      end

      local ok, result = xpcall(
        function() return fn(unpack(fn_args)) end,
        function(err) return create_error(err, fn) end
      )

      if ok then
        if collect_results then
          results[i - 1] = result -- Adjust index since we start at 2
        end
      else
        all_ok = false
        local error_obj = result

        -- Handle per-arg-set catch
        if arg_config.catch then
          if type(arg_config.catch) == 'function' then
            local catch_result = arg_config.catch(error_obj)
            if catch_result then
              -- If catch returns something, use it as both error storage and result value
              table.insert(_G.Errors, catch_result)
              if collect_results then results[i - 1] = catch_result end
            end
          end
        else
          -- Store error if no catch handler
          table.insert(_G.Errors, error_obj)
        end

        -- Handle per-arg-set or_else (only if no catch handler provided a result)
        if arg_config.or_else and (not arg_config.catch or not results[i - 1]) then
          if collect_results then
            if type(arg_config.or_else) == 'function' then
              results[i - 1] = arg_config.or_else()
            else
              results[i - 1] = arg_config.or_else
            end
          end
        end

        -- Stop on first error if configured
        if on_error == 'stop' then break end
      end
    end
  end

  -- Handle global or_else fallback if all failed
  if not all_ok and collect_results and not next(results) and config.or_else then
    if type(config.or_else) == 'function' then
      return config.or_else(), false
    else
      return config.or_else, false
    end
  end

  if collect_results then
    return results, all_ok
  else
    return nil, all_ok
  end
end

-- Execute batch operations
local function execute_batch(config)
  local mode = config.mode or 'sequential'
  local on_error = config.on_error or 'continue'
  local collect_results = config.collect_results ~= false -- default true

  local results = {}
  local errors = {}
  local all_ok = true

  for i, operation in ipairs(config) do
    if type(operation) == 'table' then
      local ok, result = execute_single(operation)

      if ok then
        if collect_results then results[i] = result end
      else
        all_ok = false
        local error_obj = result

        -- Handle batch-level catch (only if operation didn't have its own catch)
        if config.catch and not operation.catch then
          if type(config.catch) == 'function' then
            local modified_error = config.catch(error_obj, i)
            if modified_error then table.insert(_G.Errors, modified_error) end
          end
        end

        table.insert(errors, { index = i, error = error_obj })

        -- Stop on first error if configured
        if on_error == 'stop' then break end

        -- For any_success mode, continue until we get one success
        if mode == 'any_success' and next(results) then break end
      end
    end
  end

  -- Handle results based on mode
  if mode == 'any_success' then
    -- Find first successful result
    for i = 1, #config do
      if results[i] ~= nil then return results[i], true end
    end
    -- No successes, handle fallback
    if config.or_else then
      if type(config.or_else) == 'function' then
        return config.or_else(), false
      else
        return config.or_else, false
      end
    end
    return nil, false
  end

  -- For sequential/parallel modes
  if collect_results then
    -- Handle or_else fallback if all operations failed
    if not all_ok and #results == 0 and config.or_else then
      if type(config.or_else) == 'function' then
        return config.or_else(), false
      else
        return config.or_else, false
      end
    end
    return results, all_ok
  else
    return nil, all_ok
  end
end

-- Try function with multiple overloads
function M.try(...)
  local args = { ... }
  local first_arg = args[1]

  -- Overload 1: try(function, args...) -> (value, ok)
  if type(first_arg) == 'function' then
    local fn = first_arg
    local fn_args = { select(2, ...) }

    local ok, result = xpcall(function() return fn(unpack(fn_args)) end, function(err)
      local error_obj = create_error(err, fn)
      table.insert(_G.Errors, error_obj)
      return nil
    end)

    if ok then
      return result, true
    else
      return nil, false
    end
  end

  -- Overload 2-7: try { ... } -> table-based overloads
  if type(first_arg) == 'table' then
    local config = first_arg

    -- Detect table type and handle accordingly
    local table_type = detect_table_type(config)
    if table_type == 'function_with_arg_tables' then
      return execute_function_with_arg_tables(config)
    elseif table_type == 'batching' then
      return execute_batch(config)
    end

    -- Single operation mode
    local fn = config[1]
    -- Extract function arguments from the table (config[2], config[3], etc.)
    local fn_args = {}
    for i = 2, #config do
      table.insert(fn_args, config[i])
    end

    if type(fn) ~= 'function' then error 'try table: first element must be a function' end

    local ok, result = xpcall(function() return fn(unpack(fn_args)) end, function(err) return create_error(err, fn) end)

    if ok then
      return result, true
    else
      local error_obj = result

      -- Handle catch callback
      if config.catch then
        if type(config.catch) == 'function' then
          local modified_error = config.catch(error_obj)
          -- Only store error if catch function returns it (modified or not)
          if modified_error then table.insert(_G.Errors, modified_error) end
        end
      else
        -- No catch handler, automatically store error
        table.insert(_G.Errors, error_obj)
      end

      -- Handle or_else fallback
      if config.or_else then
        if type(config.or_else) == 'function' then
          return config.or_else(), false
        else
          return config.or_else, false
        end
      end

      return nil, false
    end
  end

  error 'Invalid try usage. Expected try(function, args...) or try { function, ... }'
end

-- Extract source information from traceback and error message
function M.extract_source_info(traceback, fn, error_message)
  -- Handle nested error messages like "vim/loader.lua:0: /path/file.lua:123: actual error"
  -- Look for the LAST .lua file path in the message (the actual source)
  local all_matches = {}
  for match in error_message:gmatch '([^%s:]+%.lua:%d+)' do
    table.insert(all_matches, match)
  end

  -- Use the last match (most specific/actual source)
  if #all_matches > 0 then
    local full_path_match = all_matches[#all_matches]
    local filename = full_path_match:match '([^/]+)%.lua:(%d+)'
    if filename then
      local module = filename or 'unknown'
      local line = full_path_match:match ':(%d+)' or 'unknown'
      return {
        source = module,
        line = line,
      }
    end
  end

  -- Fallback: Get the first user code line from traceback
  local source_line = traceback:match '([^/\n]*%.lua):(%d+)' or 'unknown'
  local module = source_line:match '([^/]+)' or 'unknown'
  local line = source_line:match ':(%d+)' or 'unknown'

  -- For require calls, try to get the module being required
  if fn == require then
    local required_module = traceback:match "module '([^']+)' not found"
    if required_module then module = required_module:match '([^%.]+)$' or required_module end
  end

  return {
    source = module,
    line = line,
  }
end

-- Categorize errors for better organization
function M.categorize_error(message, source_info)
  if message:match 'module.*not found' then
    return 'module_missing'
  elseif message:match 'attempt to call' then
    return 'function_error'
  elseif message:match 'attempt to index' then
    return 'nil_access'
  elseif
    message:match 'syntax error'
    or message:match 'expected.*near'
    or message:match 'unexpected symbol'
    or message:match '<eof> expected'
    or message:match "'end' expected"
  then
    return 'syntax_error'
  elseif source_info.source:match 'lsp' then
    return 'lsp_error'
  elseif source_info.source:match 'plugin' then
    return 'plugin_error'
  else
    return 'general_error'
  end
end

return M
