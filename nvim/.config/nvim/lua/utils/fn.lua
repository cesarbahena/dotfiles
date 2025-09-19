---@class FnModule
local M = {}

-- Helper Functions --

---Parse a module path string into module and function name
---@param module_path string The module.function or module::nested.property.path
---@return string|nil module_name The module name
---@return string|nil function_name The function name or property path
---@return string|nil error_msg Error message if parsing fails
local function parse_module_path(module_path)
  -- Check for :: syntax for nested properties
  if module_path:find '::' then
    local module_name, property_path = module_path:match '^(.-)::(.+)$'
    if module_name and property_path then
      return module_name, property_path, nil
    else
      return nil, nil, 'Invalid :: syntax in: "' .. module_path .. '"'
    end
  end

  -- Legacy single-level syntax (only last dot)
  local last_dot = module_path:match '.*()%.'
  if not last_dot then
    return nil,
      nil,
      'Module path must include function name: "module.function" or "module::nested.property", got "'
        .. module_path
        .. '"'
  end

  local module_name = module_path:sub(1, last_dot - 1)
  local function_name = module_path:sub(last_dot + 1)
  return module_name, function_name, nil
end

---Resolve a module path to the actual function
---@param module_path string The module.function path
---@return function|nil fn The resolved function
---@return string|nil error_msg Error message if resolution fails
local function resolve_module_function(module_path)
  local module_name, function_name, parse_error = parse_module_path(module_path)
  if parse_error then return nil, parse_error end

  local success, module = pcall(require, module_name)
  if not success then return nil, 'Module not found: ' .. module_name end

  -- Handle nested property access for :: syntax
  if module_path:find '::' then
    local current = module
    local properties = vim.split(function_name, '.', { plain = true })

    for i, property in ipairs(properties) do
      if current == nil then
        return nil, 'Property path broken at step ' .. i .. ' (' .. property .. ') in ' .. module_path
      end
      current = current[property]
    end

    if current == nil then return nil, 'Property ' .. function_name .. ' not found in module ' .. module_name end

    return current, nil
  else
    -- Legacy single-level access (last dot only)
    local module_fn = module[function_name]
    if not module_fn then return nil, 'Function ' .. function_name .. ' not found in module ' .. module_name end
    return module_fn, nil
  end
end

---Call a module function directly (without pcall)
---@param module_path string The module.function path
---@param args table Arguments to pass to the function
---@return any result The function result
local function call_module_function_direct(module_path, args)
  local module_name, function_name = parse_module_path(module_path)
  local module = require(module_name)
  return module[function_name](unpack(args))
end

---Call a module function with pcall
---@param module_path string The module.function path
---@param args table Arguments to pass to the function
---@return boolean success Whether the call succeeded
---@return any result The function result or error message
local function call_module_function_safe(module_path, args)
  return pcall(function() return call_module_function_direct(module_path, args) end)
end

---Merge function arguments with additional args
---@param fn_def table Function definition with arguments
---@param extra_args table Additional arguments to merge
---@return table merged_args The merged arguments
local function merge_function_args(fn_def, extra_args)
  local fn_args = {}

  -- Add function's own arguments
  for i = 2, #fn_def do
    table.insert(fn_args, fn_def[i])
  end

  -- Add extra arguments
  for i = 1, #extra_args do
    table.insert(fn_args, extra_args[i])
  end

  return fn_args
end

---Evaluate a condition (string, function, boolean, or options table)
---@param condition any The condition to evaluate
---@return boolean|any result The evaluation result
local function evaluate_condition(condition)
  if type(condition) == 'table' then
    local base_condition = condition[1] -- The actual condition (string or function)
    local options = condition

    -- Handle in_this option (single scope evaluation)
    if options.in_this then
      local scope = options.in_this
      local vim_table
      if scope == 'window' then
        vim_table = vim.w
      elseif scope == 'buffer' then
        vim_table = vim.b
      elseif scope == 'tab' then
        vim_table = vim.t
      elseif scope == 'global' then
        vim_table = vim.g
      elseif scope == 'option' then
        vim_table = vim.o
      elseif scope == 'env' then
        vim_table = vim.env
      elseif scope == 'state' then
        vim_table = vim.v
      else
        return false -- Invalid scope
      end

      local result
      if type(base_condition) == 'string' then
        if scope == 'window' then
          -- Check both vim.w and vim.wo
          result = vim_table[base_condition] -- vim.w[key]
          if not result then
            local success, val = pcall(function() return vim.wo[base_condition] end)
            result = success and val or nil
          end
        elseif scope == 'buffer' then
          -- Check both vim.b and vim.bo
          result = vim_table[base_condition] -- vim.b[key]
          if not result then
            result = vim.bo[base_condition]
          end
        elseif scope == 'global' then
          -- Check both vim.g and vim.go
          result = vim_table[base_condition] or vim.go[base_condition]
        else
          -- Evaluate as property access on vim table
          result = vim_table[base_condition]
        end
      elseif type(base_condition) == 'function' then
        if scope == 'window' then
          result = base_condition(vim_table, vim.wo)
        elseif scope == 'buffer' then
          result = base_condition(vim_table, vim.bo)
        elseif scope == 'global' then
          result = base_condition(vim_table, vim.go)
        else
          result = base_condition(vim_table)
        end
      else
        result = base_condition
      end

      -- Apply comparison operators
      if options.eq ~= nil then
        return result == options.eq
      elseif options.ne ~= nil then
        return result ~= options.ne
      elseif options.gt ~= nil then
        return result > options.gt
      elseif options.lt ~= nil then
        return result < options.lt
      elseif options.gte ~= nil then
        return result >= options.gte
      elseif options.lte ~= nil then
        return result <= options.lte
      elseif options.contains ~= nil then
        if type(result) == 'table' then
          return result[options.contains] ~= nil
        elseif type(result) == 'string' then
          return result:find(options.contains) ~= nil
        end
        return false
      end

      return not not result
    end

    -- Handle in_any option (iterate over multiple scopes)
    if options.in_any then
      local scope = options.in_any
      local vim_tables = {}

      if scope == 'window' then
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          table.insert(vim_tables, { table = vim.w[winid], id = winid })
        end
      elseif scope == 'buffer' then
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          table.insert(vim_tables, { table = vim.b[bufnr], id = bufnr })
        end
      elseif scope == 'tab' then
        for _, tabnr in ipairs(vim.api.nvim_list_tabpages()) do
          table.insert(vim_tables, { table = vim.t[tabnr], id = tabnr })
        end
      elseif scope == 'wo' then
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          table.insert(vim_tables, { table = vim.wo[winid], id = winid })
        end
      elseif scope == 'bo' then
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
          table.insert(vim_tables, { table = vim.bo[bufnr], id = bufnr })
        end
      else
        return false -- Invalid scope (global scopes don't iterate)
      end

      for _, entry in ipairs(vim_tables) do
        local result
        if type(base_condition) == 'string' then
          if scope == 'window' then
            -- Check both vim.w[winid] and vim.wo[winid]
            result = entry.table[base_condition] -- vim.w[winid][key]
            if not result then
              local success, val = pcall(function() return vim.wo[entry.id][base_condition] end)
              result = success and val or nil
            end
          elseif scope == 'buffer' then
            -- Check both vim.b[bufnr] and vim.bo[bufnr]
            result = entry.table[base_condition] -- vim.b[bufnr][key]
            if not result then
              result = vim.bo[entry.id][base_condition]
            end
          else
            result = entry.table[base_condition]
          end
        elseif type(base_condition) == 'function' then
          if scope == 'window' then
            result = base_condition(entry.table, vim.wo[entry.id], entry.id)
          elseif scope == 'buffer' then
            result = base_condition(entry.table, vim.bo[entry.id], entry.id)
          else
            result = base_condition(entry.table, entry.id)
          end
        else
          result = base_condition
        end

        -- Apply comparison if specified, otherwise check truthiness
        local matches = false
        if options.eq ~= nil then
          matches = result == options.eq
        elseif options.ne ~= nil then
          matches = result ~= options.ne
        elseif options.gt ~= nil then
          matches = result > options.gt
        elseif options.lt ~= nil then
          matches = result < options.lt
        elseif options.gte ~= nil then
          matches = result >= options.gte
        elseif options.lte ~= nil then
          matches = result <= options.lte
        elseif options.contains ~= nil then
          if type(result) == 'table' then
            matches = result[options.contains] ~= nil
          elseif type(result) == 'string' then
            matches = result:find(options.contains) ~= nil
          else
            matches = false
          end
        else
          matches = not not result
        end

        if matches then
          return entry.id -- Return the matching ID
        end
      end
      return false -- No match found
    end

    -- Handle forEach option
    if options.forEach then
      local iterable = options.forEach
      local is_windows = false

      if type(iterable) == 'string' and iterable == 'windows' then
        iterable = vim.api.nvim_list_wins()
        is_windows = true
      elseif type(iterable) == 'function' then
        iterable = iterable()
      end

      for _, item in ipairs(iterable) do
        local context = { item = item, vim = vim }

        -- For windows, add winid and buf to context
        if is_windows then
          context.winid = item
          context.buf = vim.api.nvim_win_get_buf(item)
        end

        local result
        if type(base_condition) == 'string' then
          local func = load('return ' .. base_condition, nil, 't', context)
          result = func and func() or false
        elseif type(base_condition) == 'function' then
          result = base_condition(item)
        else
          result = base_condition
        end

        -- Apply comparison if specified, otherwise check truthiness
        local matches = false
        if options.eq ~= nil then
          matches = result == options.eq
        elseif options.ne ~= nil then
          matches = result ~= options.ne
        elseif options.gt ~= nil then
          matches = result > options.gt
        elseif options.lt ~= nil then
          matches = result < options.lt
        elseif options.gte ~= nil then
          matches = result >= options.gte
        elseif options.lte ~= nil then
          matches = result <= options.lte
        elseif options.contains ~= nil then
          if type(result) == 'table' then
            matches = result[options.contains] ~= nil
          elseif type(result) == 'string' then
            matches = result:find(options.contains) ~= nil
          else
            matches = false
          end
        else
          matches = not not result
        end

        if matches then
          return item -- Early return with the matching item
        end
      end
      return false -- No match found
    end

    -- Evaluate base condition
    local result
    if type(base_condition) == 'string' then
      -- Keep strings as literals (no evaluation)
      result = base_condition
    elseif type(base_condition) == 'function' then
      local success, val = pcall(base_condition)
      if options.ok then
        result = success  -- Return pcall success status
      else
        result = success and val or false  -- Return function result or false
      end
    else
      result = base_condition
    end
    
    -- Handle 'at' option for property access
    if options.at and type(result) == 'table' then
      if type(options.at) == 'string' and options.at:find '%.' then
        -- Handle dot notation: '1.name' -> result[1].name
        local props = vim.split(options.at, '.', { plain = true })
        for _, prop in ipairs(props) do
          if type(result) == 'table' then
            -- Handle array indices
            if prop:match '^%d+$' then
              result = result[tonumber(prop)]
            else
              result = result[prop]
            end
          else
            result = nil
            break
          end
        end
      else
        -- Single property access
        if type(options.at) == 'string' and options.at:match '^%d+$' then
          result = result[tonumber(options.at)]
        else
          result = result[options.at]
        end
      end
    end

    -- Helper function to evaluate comparison values
    local function eval_comparison_value(value)
      if type(value) == 'table' and value[1] then
        -- Handle { function, at = 'property' } format
        local func = value[1]
        if type(func) == 'function' then
          local success, val = pcall(func)
          if success and val and value.at then
            if type(value.at) == 'string' and value.at:find '%.' then
              -- Handle dot notation: '1.name' -> val[1].name
              local props = vim.split(value.at, '.', { plain = true })
              for _, prop in ipairs(props) do
                if type(val) == 'table' then
                  -- Handle array indices
                  if prop:match '^%d+$' then
                    val = val[tonumber(prop)]
                  else
                    val = val[prop]
                  end
                else
                  val = nil
                  break
                end
              end
            else
              -- Single property access
              if type(value.at) == 'string' and value.at:match '^%d+$' then
                val = val[tonumber(value.at)]
              else
                val = val[value.at]
              end
            end
            return val
          end
          return success and val or nil
        end
        return value
      elseif type(value) == 'function' then
        local success, val = pcall(value)
        return success and val or nil
      end
      return value
    end

    -- Apply comparison operators
    if options.eq ~= nil then
      local compare_val = eval_comparison_value(options.eq)
      return result == compare_val
    elseif options.ne ~= nil then
      local compare_val = eval_comparison_value(options.ne)
      return result ~= compare_val
    elseif options.gt ~= nil then
      local compare_val = eval_comparison_value(options.gt)
      return result > compare_val
    elseif options.lt ~= nil then
      local compare_val = eval_comparison_value(options.lt)
      return result < compare_val
    elseif options.gte ~= nil then
      local compare_val = eval_comparison_value(options.gte)
      return result >= compare_val
    elseif options.lte ~= nil then
      local compare_val = eval_comparison_value(options.lte)
      return result <= compare_val
    elseif options.contains ~= nil then
      if type(result) == 'table' then
        return result[options.contains] ~= nil
      elseif type(result) == 'string' then
        return result:find(options.contains) ~= nil
      end
      return false
    end

    -- Default: return truthy value of result
    return not not result
  elseif type(condition) == 'string' then
    -- Lazy evaluation: execute the string as Lua code
    local func, err = load('return ' .. condition)
    if not func then return false end

    local success, result = pcall(func)
    return success and not not result
  elseif type(condition) == 'function' then
    -- Lazy evaluation: call the function
    local success, result = pcall(condition)
    return success and not not result
  elseif type(condition) == 'boolean' then
    -- Immediate evaluation
    return condition
  end

  return false
end

---Execute a function (table, string, or function) with appropriate handling
---@param target_fn any The function to execute
---@param args table Arguments to pass
---@param use_pcall boolean Whether to use pcall
---@param fn_resolver function The fn resolver function (for recursive calls)
---@return boolean success Whether the call succeeded (only relevant if use_pcall is true)
---@return any result The function result or error message
local function execute_function(target_fn, args, use_pcall, fn_resolver)
  if type(target_fn) == 'table' then
    local fn_args = merge_function_args(target_fn, args)

    if type(target_fn[1]) == 'string' then
      if use_pcall then
        return call_module_function_safe(target_fn[1], fn_args)
      else
        return true, call_module_function_direct(target_fn[1], fn_args)
      end
    else
      if use_pcall then
        return pcall(target_fn[1], unpack(fn_args))
      else
        return true, target_fn[1](unpack(fn_args))
      end
    end
  elseif type(target_fn) == 'string' then
    if use_pcall then
      return call_module_function_safe(target_fn, args)
    else
      return true, call_module_function_direct(target_fn, args)
    end
  elseif type(target_fn) == 'function' then
    if use_pcall then
      return pcall(target_fn, unpack(args))
    else
      return true, target_fn(unpack(args))
    end
  else
    -- Use fn_resolver for other cases
    if use_pcall then
      return pcall(function() return fn_resolver(target_fn, unpack(args))() end)
    else
      return true, fn_resolver(target_fn, unpack(args))()
    end
  end
end

-- Main API Functions --

---Handle conditional execution: { when = condition, [1] = fn, or_else = fn }
---@param spec table The conditional specification
---@param args table Arguments passed to the fn call
---@param fn_resolver function The fn resolver function
---@return function executable The executable function
local function handle_conditional(spec, args, fn_resolver)
  return function()
    local condition = spec['when']
    local condition_result = evaluate_condition(condition)

    local target_fn = condition_result and spec[1] or spec['or_else']
    if not target_fn then return nil end

    local success, result = execute_function(target_fn, args, false, fn_resolver)
    return result
  end
end

---Check if main function error should be notified
---@param notify_option string The notify option
---@return boolean should_notify Whether to notify main errors
local function should_notify_main_error(notify_option) return notify_option == 'main' or notify_option == 'both' end

---Check if fallback function should use pcall
---@param notify_option string The notify option
---@return boolean should_pcall Whether to use pcall for fallback
local function should_pcall_fallback(notify_option) return notify_option == 'fallback' or notify_option == 'both' end

---Handle try/notify execution: { [1] = fn, or_else = fn, notify = 'main'|'fallback'|'both' }
---@param spec table The try/notify specification
---@param args table Arguments passed to the fn call
---@param fn_resolver function The fn resolver function
---@return function executable The executable function
local function handle_try_notify(spec, args, fn_resolver)
  return function()
    local main_fn = spec[1]
    local notify_option = spec['notify'] or 'fallback'

    -- Validate notify option
    if notify_option ~= 'main' and notify_option ~= 'fallback' and notify_option ~= 'both' then
      error("Invalid notify option: '" .. tostring(notify_option) .. "'. Expected 'main', 'fallback', or 'both'")
    end

    -- Execute main function with pcall
    local success, result = execute_function(main_fn, args, true, fn_resolver)

    -- Early return on success
    if success then return result end

    -- Handle main function failure notification
    if should_notify_main_error(notify_option) then vim.notify(tostring(result), vim.log.levels.ERROR) end

    -- Execute or_else if available
    local or_else_fn = spec['or_else']
    if not or_else_fn then return nil end

    -- Determine execution strategy for or_else function
    local use_pcall_for_fallback = should_pcall_fallback(notify_option)

    if use_pcall_for_fallback then
      -- Use pcall and handle errors with notifications
      local or_else_success, or_else_result = execute_function(or_else_fn, args, true, fn_resolver)
      if not or_else_success then
        vim.notify(tostring(or_else_result), vim.log.levels.ERROR)
        return nil
      end
      return or_else_result
    else
      -- Call directly - let errors propagate naturally (for 'main' mode)
      if type(or_else_fn) == 'table' then
        local fn_args = merge_function_args(or_else_fn, args)
        if type(or_else_fn[1]) == 'string' then
          return call_module_function_direct(or_else_fn[1], fn_args)
        else
          return or_else_fn[1](unpack(fn_args))
        end
      elseif type(or_else_fn) == 'string' then
        return call_module_function_direct(or_else_fn, args)
      elseif type(or_else_fn) == 'function' then
        return or_else_fn(unpack(args))
      else
        error('Unsupported or_else type: ' .. type(or_else_fn))
      end
    end
  end
end

---Handle direct function execution with error handling
---@param func function The function to execute
---@param args table Arguments to pass to the function
---@return function executable The executable function
local function handle_direct_function(func, args)
  return function()
    local success, result = pcall(func, unpack(args))
    if not success then
      vim.notify(tostring(result), vim.log.levels.WARN)
      return nil
    end
    return result
  end
end

---Handle module path execution with error handling
---@param module_path string The module.function path
---@param args table Arguments to pass to the function
---@return function executable The executable function
local function handle_module_path(module_path, args)
  return function()
    local module_fn, error_msg = resolve_module_function(module_path)
    if error_msg then
      vim.notify(error_msg, vim.log.levels.ERROR)
      return nil
    end

    local success, result = pcall(module_fn, unpack(args))
    if not success then
      vim.notify(tostring(result), vim.log.levels.ERROR)
      return nil
    end

    return result
  end
end

-- Public API --

---Create a lazy function wrapper with conditional execution, error handling, and notifications
---
---See docs/fn_api.md for comprehensive documentation and examples.
---
---@param fn_or_module_path function|string|table The function, module path, or specification table
---@param ... any Arguments to pass to the function
---@return function lazy_function A function that executes the specified logic when called
function M.fn(fn_or_module_path, ...)
  local args = { ... }

  -- Guard clause: Handle table specifications
  if type(fn_or_module_path) == 'table' then
    -- Guard clause: Handle conditional execution
    if fn_or_module_path['when'] ~= nil and fn_or_module_path[1] then
      return handle_conditional(fn_or_module_path, args, M.fn)
    end

    -- Guard clause: Handle try/notify execution
    if fn_or_module_path[1] then return handle_try_notify(fn_or_module_path, args, M.fn) end

    error 'Invalid table format. Expected { when = condition, [1] = fn, or_else = fn } or { [1] = fn, or_else = fn }'
  end

  -- Guard clause: Handle direct function calls
  if type(fn_or_module_path) == 'function' then return handle_direct_function(fn_or_module_path, args) end

  -- Guard clause: Validate string input
  if type(fn_or_module_path) ~= 'string' then
    error('Expected function, string, or table, got ' .. type(fn_or_module_path))
  end

  -- Handle module path execution
  return handle_module_path(fn_or_module_path, args)
end

return M
