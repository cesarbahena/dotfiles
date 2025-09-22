---@class FnModule
local M = {}

-- Helper Functions --

---Parse a module path string into module and function name
---@param module_path string The module.function or module::nested.property.path
---@return string|nil module_name The module name
---@return string|nil function_name The function name or property path
---@return string|nil error_msg Error message if parsing fails
local function parse_module_path(module_path)
  -- Check for :: syntax to mark module/table boundary for nested access
  if module_path:find '::' then
    local module_name, property_path = module_path:match '^(.-)::(.+)$'
    if module_name and property_path then
      return module_name, property_path, nil
    else
      return nil, nil, 'Invalid :: syntax in: "' .. module_path .. '"'
    end
  end

  -- Dot syntax for top-level exports (split on last dot only)
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

  -- Handle nested property access for :: syntax (module::nested.property.path)
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
    -- Dot syntax for top-level exports (module.function)
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

  -- Handle nested property access for :: syntax (module::nested.property.path)
  if module_path:find '::' then
    local current = module
    local properties = vim.split(function_name, '.', { plain = true })

    for _, property in ipairs(properties) do
      current = current[property]
    end

    return current(unpack(args))
  else
    -- Dot syntax for top-level exports (module.function)
    return module[function_name](unpack(args))
  end
end

---Call a module function with pcall
---@param module_path string The module.function path
---@param args table Arguments to pass to the function
---@return boolean success Whether the call succeeded
---@return any result The function result or error message
local function call_module_function_safe(module_path, args)
  return pcall(function() return call_module_function_direct(module_path, args) end)
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
          if not result then result = vim.bo[base_condition] end
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
      elseif scope == 'buffer:window' then
        for _, winid in ipairs(vim.api.nvim_list_wins()) do
          local bufnr = vim.api.nvim_win_get_buf(winid)
          table.insert(vim_tables, { table = vim.b[bufnr], id = bufnr, winid = winid })
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
            if not result then result = vim.bo[entry.id][base_condition] end
          elseif scope == 'buffer:window' then
            -- Check both vim.b[bufnr] and vim.bo[bufnr] for buffers attached to windows
            result = entry.table[base_condition] -- vim.b[bufnr][key]
            if not result then result = vim.bo[entry.id][base_condition] end
          else
            result = entry.table[base_condition]
          end
        elseif type(base_condition) == 'function' then
          if scope == 'window' then
            result = base_condition(entry.table, vim.wo[entry.id], entry.id)
          elseif scope == 'buffer' then
            result = base_condition(entry.table, vim.bo[entry.id], entry.id)
          elseif scope == 'buffer:window' then
            result = base_condition(entry.table, vim.bo[entry.id], entry.id, entry.winid)
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


    -- Evaluate base condition
    local result
    if type(base_condition) == 'string' then
      -- Keep strings as literals (no evaluation)
      result = base_condition
    elseif type(base_condition) == 'function' then
      local success, val = pcall(base_condition)
      if options.ok then
        result = success -- Return pcall success status
      else
        result = success and val or false -- Return function result or false
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

-- Main API Functions --

---Handle conditional execution: { when = condition, [1] = fn, or_else = fn }
---[1] and or_else must be functions (use nested fn() calls for lazy functions)
---@param spec table The conditional specification
---@return function executable The executable function
local function handle_conditional(spec)
  return function()
    local condition = spec['when']
    local condition_result = evaluate_condition(condition)

    local target_fn = condition_result and spec[1] or spec['or_else']
    if not target_fn then return nil end

    -- Call the function directly (no error handling for conditional)
    return target_fn()
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
---[1] and or_else must be functions (use nested fn() calls for lazy functions)
---@param spec table The try/notify specification
---@return function executable The executable function
local function handle_try_notify(spec)
  return function()
    local main_fn = spec[1]
    local notify_option = spec['notify'] or 'fallback'

    -- Validate notify option
    if notify_option ~= 'main' and notify_option ~= 'fallback' and notify_option ~= 'both' then
      error("Invalid notify option: '" .. tostring(notify_option) .. "'. Expected 'main', 'fallback', or 'both'")
    end

    -- Execute main function with pcall
    local success, result = pcall(main_fn)

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
      local or_else_success, or_else_result = pcall(or_else_fn)
      if not or_else_success then
        vim.notify(tostring(or_else_result), vim.log.levels.ERROR)
        return nil
      end
      return or_else_result
    else
      -- Call directly - let errors propagate naturally (for 'main' mode)
      return or_else_fn()
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
---Usage patterns:
---  fn(function)                              -- Direct function call (no args)
---  fn('module.function')                     -- Direct module path call (no args)
---  fn({function, arg1, arg2, ...})           -- Function with arguments
---  fn({'module.function', arg1, arg2, ...})  -- Module path call with arguments
---  fn({when = condition, [1] = fn, or_else = fn})  -- Conditional (functions only)
---  fn({[1] = fn, or_else = fn, notify = 'option'}) -- Try/catch (functions only)
---
---See docs/fn_api.md for comprehensive documentation and examples.
---
---@param spec function|string|table The function, module path, or specification table
---@return function lazy_function A function that executes the specified logic when called
function M.fn(spec)
  -- Guard clause: Handle direct function calls (no arguments)
  if type(spec) == 'function' then return handle_direct_function(spec, {}) end

  -- Guard clause: Handle direct module path calls (no arguments)
  if type(spec) == 'string' then return handle_module_path(spec, {}) end

  -- Guard clause: Validate table input
  if type(spec) ~= 'table' then error('Expected function, string, or table, got ' .. type(spec)) end

  -- Guard clause: Handle conditional execution
  if spec['when'] ~= nil then
    if type(spec[1]) ~= 'function' or (spec['or_else'] and type(spec['or_else']) ~= 'function') then
      error 'Conditional [1] and or_else must be functions. Use fn() for lazy functions.'
    end
    return handle_conditional(spec)
  end

  -- Guard clause: Handle try/catch with or_else (with or without notify)
  if spec['or_else'] ~= nil then
    if type(spec[1]) ~= 'function' or type(spec['or_else']) ~= 'function' then
      error 'Try/catch [1] and or_else must be functions. Use fn() for lazy functions.'
    end
    return handle_try_notify(spec)
  end

  -- Handle function calls with arguments: {function|string, arg1, arg2, ..., defer = ms}
  if not spec[1] then error 'Table must have [1] as function or module path' end

  local target = spec[1]
  local defer_ms = spec.defer
  local args = {}
  
  -- Extract numbered arguments, skipping defer option
  for i = 2, #spec do
    table.insert(args, spec[i])
  end

  local base_fn
  if type(target) == 'function' then
    base_fn = handle_direct_function(target, args)
  elseif type(target) == 'table' and getmetatable(target) and getmetatable(target).__call then
    -- Handle callable tables like vim.cmd
    base_fn = handle_direct_function(target, args)
  elseif type(target) == 'string' then
    base_fn = handle_module_path(target, args)
  else
    error('spec[1] must be function or string, got ' .. type(target))
  end

  -- If defer option is specified, wrap in vim.defer_fn
  if defer_ms then
    return function()
      vim.defer_fn(base_fn, defer_ms)
    end
  else
    return base_fn
  end
end

return M
