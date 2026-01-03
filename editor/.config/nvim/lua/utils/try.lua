---@class TryAPI
---A comprehensive error-safe execution API for Neovim Lua configurations
---
---This module provides multiple overloads for safe function execution:
---1. try(function, args...) -> Simple function call with error handling
---2. try { function, args..., options } -> Single operation with advanced options
---3. try { {func1, args...}, {func2, args...}, options } -> Batch operations
---4. try { function, {args1...}, {args2...}, options } -> Function with multiple argument sets
---
---All errors are automatically captured and stored in _G.Errors for later analysis.

local safe_call = require 'utils.safe_call'

---@class TryOptions
---@field or_else? any|function Fallback value or function if operation fails
---@field catch? function(error: ErrorInfo, index?: number): ErrorInfo? Error handler function
---@field mode? 'sequential'|'any_success' Execution strategy for batch operations
---@field on_error? 'continue'|'stop' Error handling behavior for batch operations
---@field collect_results? boolean Whether to collect return values (default: true)

local M = {}

---Detect the type of try operation based on the configuration
---@param config table Configuration table
---@return 'simple_call'|'single_operation'|'batch_operations'|'multi_call'
local function detect_operation_type(config)
  -- Simple function call: try(function, args...)
  if type(config) == 'function' then return 'simple_call' end

  -- Table-based operations
  if type(config) == 'table' then
    -- Function with multiple argument sets: try { function, {args1...}, {args2...} }
    if type(config[1]) == 'function' and type(config[2]) == 'table' then return 'multi_call' end

    -- Batch operations: try { {func1, args...}, {func2, args...} }
    if type(config[1]) == 'table' then return 'batch_operations' end

    -- Single operation: try { function, args..., options }
    if type(config[1]) == 'function' then return 'single_operation' end
  end

  error 'Invalid try usage. Expected function or table configuration.'
end

---Execute a single operation with comprehensive error handling
---@param fn function The function to execute
---@param args table Function arguments
---@param options? TryOptions Operation options
---@return any result, boolean success
local function execute_single_operation(fn, args, options)
  options = options or {}

  local success, result = xpcall(
    function() return fn(unpack(args)) end,
    function(err) return require('utils.error_formatter').create_error(err, fn) end
  )

  if success then
    return result, true
  else
    local error_info = result

    -- Handle catch callback
    if options.catch then
      local catch_result = options.catch(error_info)
      if catch_result then table.insert(_G.Errors, catch_result) end
    else
      -- No catch handler, automatically store error
      table.insert(_G.Errors, error_info)
    end

    -- Handle or_else fallback
    if options.or_else then
      if type(options.or_else) == 'function' then
        return options.or_else(), false
      else
        return options.or_else, false
      end
    end

    return nil, false
  end
end

---Main try function with multiple overloads
---@param config function|table Function to call or configuration table
---@param ... any Additional arguments for simple function calls
---@return any result, boolean success
function M.try(config, ...)
  local operation_type = detect_operation_type(config)

  if operation_type == 'simple_call' then
    -- try(function, args...)
    return safe_call.safe_call(config, ...)
  end

  if operation_type == 'single_operation' then
    -- try { function, args..., options }
    local fn = config[1]
    local args = {}
    for i = 2, #config do
      table.insert(args, config[i])
    end
    local options = {
      or_else = config.or_else,
      catch = config.catch,
    }
    return execute_single_operation(fn, args, options)
  end

  if operation_type == 'batch_operations' then
    -- try { {func1, args...}, {func2, args...}, options }
    local operations = {}
    local batch_config = {}

    -- Separate operations from configuration
    for i, item in ipairs(config) do
      if type(item) == 'table' and type(item[1]) == 'function' then table.insert(operations, item) end
    end

    -- Extract configuration options
    batch_config.mode = config.mode
    batch_config.on_error = config.on_error
    batch_config.collect_results = config.collect_results
    batch_config.or_else = config.or_else
    batch_config.catch = config.catch

    return safe_call.safe_batch(operations, batch_config)
  end

  if operation_type == 'multi_call' then
    -- try { function, {args1...}, {args2...}, options }
    local fn = config[1]
    local arg_sets = {}
    local multi_config = {}

    -- Separate argument sets from configuration
    for i = 2, #config do
      if type(config[i]) == 'table' then table.insert(arg_sets, config[i]) end
    end

    -- Extract configuration options
    multi_config.on_error = config.on_error
    multi_config.collect_results = config.collect_results
    multi_config.or_else = config.or_else
    multi_config.catch = config.catch

    return safe_call.safe_multi_call(fn, arg_sets, multi_config)
  end
end

-- Export the try function
return M
