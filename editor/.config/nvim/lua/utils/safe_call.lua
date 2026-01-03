---@class SafeCallResult
---@field value any The returned value if successful
---@field success boolean Whether the operation succeeded
---@field error? ErrorInfo The error information if failed

---@class ErrorInfo
---@field message string Cleaned error message
---@field details string[] Detailed error information
---@field traceback string[] Formatted stack trace
---@field module string Source module name
---@field line string Source line number
---@field category string Error category
---@field time string Timestamp when error occurred

---@class BatchConfig
---@field mode? 'sequential'|'any_success' Execution strategy (default: 'sequential')
---@field on_error? 'continue'|'stop' Error handling behavior (default: 'continue')
---@field collect_results? boolean Whether to collect return values (default: true)
---@field or_else? any|function Fallback value or function if all operations fail
---@field catch? function(error: ErrorInfo, index?: number): ErrorInfo? Error handler function

---@class OperationConfig
---@field [1] function The function to call
---@field [2] any First argument
---@field ... any Additional arguments
---@field or_else? any|function Fallback value if this operation fails
---@field catch? function(error: ErrorInfo): ErrorInfo? Error handler for this operation

local error_formatter = require 'utils.error_formatter'

local M = {}

-- Global error storage
_G.Errors = _G.Errors or {}

---Safely execute a single function with arguments
---@param fn function The function to execute
---@param ... any Arguments to pass to the function
---@return any result, boolean success
function M.safe_call(fn, ...)
  local args = { ... }

  local success, result = xpcall(function() return fn(unpack(args)) end, function(err)
    local error_info = error_formatter.create_error(err, fn)
    table.insert(_G.Errors, error_info)
    return nil
  end)

  if success then
    return result, true
  else
    return nil, false
  end
end

---Execute operations in batch mode
---@param operations table[] Array of operation configurations
---@param config? BatchConfig Batch execution configuration
---@return table|any results, boolean all_success
function M.safe_batch(operations, config)
  config = config or {}
  local mode = config.mode or 'sequential'
  local on_error = config.on_error or 'continue'
  local collect_results = config.collect_results ~= false

  local results = {}
  local all_success = true

  for i, operation in ipairs(operations) do
    local fn = operation[1]
    local args = {}
    for j = 2, #operation do
      table.insert(args, operation[j])
    end

    local success, result = xpcall(
      function() return fn(unpack(args)) end,
      function(err) return error_formatter.create_error(err, fn) end
    )

    if success then
      if collect_results then results[i] = result end
    else
      all_success = false
      local error_info = result

      -- Handle per-operation catch
      if operation.catch then
        local catch_result = operation.catch(error_info)
        if catch_result then
          table.insert(_G.Errors, catch_result)
          if collect_results then results[i] = catch_result end
        end
      else
        -- Handle batch-level catch
        if config.catch and not operation.catch then
          local modified_error = config.catch(error_info, i)
          if modified_error then table.insert(_G.Errors, modified_error) end
        else
          table.insert(_G.Errors, error_info)
        end
      end

      -- Handle per-operation or_else
      if operation.or_else and (not operation.catch or not results[i]) then
        if collect_results then
          if type(operation.or_else) == 'function' then
            results[i] = operation.or_else()
          else
            results[i] = operation.or_else
          end
        end
      end

      -- Stop on error if configured
      if on_error == 'stop' then break end

      -- For any_success mode, stop after first success
      if mode == 'any_success' and next(results) then break end
    end
  end

  -- Handle mode-specific results
  if mode == 'any_success' then
    for i = 1, #operations do
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

  -- For sequential mode
  if collect_results then
    -- Handle global or_else if all failed
    if not all_success and not next(results) and config.or_else then
      if type(config.or_else) == 'function' then
        return config.or_else(), false
      else
        return config.or_else, false
      end
    end
    return results, all_success
  else
    return nil, all_success
  end
end

---Execute a function with multiple argument sets
---@param fn function The function to execute
---@param arg_sets table[] Array of argument configurations
---@param config? BatchConfig Configuration options
---@return table|any results, boolean all_success
function M.safe_multi_call(fn, arg_sets, config)
  config = config or {}
  local on_error = config.on_error or 'continue'
  local collect_results = config.collect_results ~= false

  local results = {}
  local all_success = true

  for i, arg_config in ipairs(arg_sets) do
    local args = {}
    for j = 1, #arg_config do
      table.insert(args, arg_config[j])
    end

    local success, result = xpcall(
      function() return fn(unpack(args)) end,
      function(err) return error_formatter.create_error(err, fn) end
    )

    if success then
      if collect_results then results[i] = result end
    else
      all_success = false
      local error_info = result

      -- Handle per-arg-set catch
      if arg_config.catch then
        local catch_result = arg_config.catch(error_info)
        if catch_result then
          table.insert(_G.Errors, catch_result)
          if collect_results then results[i] = catch_result end
        end
      else
        table.insert(_G.Errors, error_info)
      end

      -- Handle per-arg-set or_else
      if arg_config.or_else and (not arg_config.catch or not results[i]) then
        if collect_results then
          if type(arg_config.or_else) == 'function' then
            results[i] = arg_config.or_else()
          else
            results[i] = arg_config.or_else
          end
        end
      end

      -- Stop on first error if configured
      if on_error == 'stop' then break end
    end
  end

  -- Handle global or_else if all failed
  if not all_success and collect_results and not next(results) and config.or_else then
    if type(config.or_else) == 'function' then
      return config.or_else(), false
    else
      return config.or_else, false
    end
  end

  if collect_results then
    return results, all_success
  else
    return nil, all_success
  end
end

return M

