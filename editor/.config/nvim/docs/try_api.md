# Try API Documentation

A comprehensive error-safe execution API for Neovim Lua configurations. The Try API provides multiple patterns for safe function execution with automatic error capture, categorization, and flexible fallback mechanisms.

## Table of Contents

- [Overview](#overview)
- [Installation](#installation)
- [API Reference](#api-reference)
  - [Simple Function Calls](#simple-function-calls)
  - [Single Operations with Options](#single-operations-with-options)
  - [Function with Multiple Argument Sets](#function-with-multiple-argument-sets)
  - [Batch Operations](#batch-operations)
- [Error Handling](#error-handling)
- [Configuration Options](#configuration-options)
- [Examples](#examples)
- [Testing](#testing)

## Overview

The Try API eliminates the need for manual `pcall` usage throughout your Neovim configuration. It automatically captures errors, categorizes them, and provides flexible fallback mechanisms. All errors are stored in `_G.Errors` for later analysis and debugging.

### Key Features

- **Multiple execution patterns** for different use cases
- **Automatic error capture** and categorization
- **Flexible fallback mechanisms** with `or_else` and `catch`
- **Batch execution** with configurable error handling
- **Rich error information** including source location and stack traces
- **Type-safe** with comprehensive LSP annotations

## Installation

Add the Try API modules to your Neovim configuration:

```lua
-- In your init.lua or appropriate module
local try = require('utils.try').try

-- Make it globally available (optional)
_G.try = try
```

## API Reference

### Simple Function Calls

The most basic usage pattern for safe function execution.

```lua
try(function, args...) -> (result, success)
```

**Parameters:**
- `function` - The function to execute safely
- `args...` - Arguments to pass to the function

**Returns:**
- `result` - The function's return value (or `nil` if error)
- `success` - Boolean indicating whether execution succeeded

**Example:**

```lua
local result, success = try(require, 'my_module')
if success then
  print('Module loaded successfully')
else
  print('Failed to load module, check _G.Errors')
end
```

### Single Operations with Options

Execute a single operation with advanced error handling options.

```lua
try { function, args..., options } -> (result, success)
```

**Options:**
- `or_else` - Fallback value or function if operation fails
- `catch` - Error handler function that receives error info

**Examples:**

```lua
-- With fallback value
local config, success = try { 
  require, 'user_config', 
  or_else = { default = 'settings' } 
}

-- With fallback function
local data, success = try { 
  vim.fn.readfile, 'config.json', 
  or_else = function() return {} end 
}

-- With error handler
local result, success = try { 
  risky_operation, 
  catch = function(error_info) 
    vim.notify('Operation failed: ' .. error_info.message, vim.log.levels.WARN)
    error_info.handled = true
    return error_info -- Store modified error
  end 
}
```

### Function with Multiple Argument Sets

Execute the same function with different argument sets efficiently.

```lua
try { function, {args1...}, {args2...}, options } -> (results, all_success)
```

**Configuration Options:**
- `on_error` - `'continue'` (default) or `'stop'`
- `collect_results` - Whether to collect return values (default: `true`)
- `or_else` - Global fallback if all operations fail
- `catch` - Global error handler for operations without individual handlers

**Per-argument-set Options:**
- `or_else` - Fallback for this specific argument set
- `catch` - Error handler for this specific argument set

**Examples:**

```lua
-- Load multiple modules with error handling
local modules, all_loaded = try {
  require,
  { 'core.options' },
  { 'core.keymaps' },
  { 'core.plugins', catch = function(e) return { disabled = true } end },
  { 'core.lsp', or_else = { lsp_disabled = true } },
  on_error = 'continue'
}

-- Execute function with multiple configurations
local results, success = try {
  vim.keymap.set,
  { 'n', '<leader>f', ':find', { desc = 'Find files' } },
  { 'n', '<leader>g', ':grep', { desc = 'Grep' } },
  { 'n', '<leader>b', ':buffers', { desc = 'Buffers' } },
  on_error = 'stop' -- Stop if any keymap fails
}
```

### Batch Operations

Execute multiple different operations with comprehensive error handling.

```lua
try { {func1, args...}, {func2, args...}, options } -> (results, all_success)
```

**Configuration Options:**
- `mode` - `'sequential'` (default) or `'any_success'`
- `on_error` - `'continue'` (default) or `'stop'`
- `collect_results` - Whether to collect return values (default: `true`)
- `or_else` - Global fallback if all operations fail
- `catch` - Global error handler

**Per-operation Options:**
- `or_else` - Fallback for this specific operation
- `catch` - Error handler for this specific operation

**Examples:**

```lua
-- Sequential execution with error handling
local results, success = try {
  { require, 'telescope' },
  { require, 'nvim-treesitter', or_else = { disabled = true } },
  { require, 'lspconfig' },
  mode = 'sequential',
  on_error = 'continue'
}

-- Any success mode - return first successful result
local plugin, found = try {
  { require, 'telescope' },
  { require, 'fzf-lua' },
  { require, 'ctrlp' },
  mode = 'any_success',
  or_else = function() 
    vim.notify('No fuzzy finder plugin found', vim.log.levels.WARN)
    return nil 
  end
}
```

## Error Handling

All errors captured by the Try API are automatically processed and stored in `_G.Errors`. Each error contains comprehensive information:

```lua
-- Error structure
{
  message = "Clean error message",
  details = { "Additional error details..." },
  traceback = { "Formatted stack trace..." },
  source = "source_file_path",
  line = "line_number",
  category = "error_category", -- 'module_missing', 'function_error', etc.
  time = "2024-01-01 12:00:00"
}
```

### Error Categories

- `module_missing` - Required module not found
- `function_error` - Attempt to call non-function
- `nil_access` - Attempt to index nil value
- `syntax_error` - Lua syntax errors
- `lsp_error` - LSP-related errors
- `plugin_error` - Plugin-specific errors
- `general_error` - Other errors

### Custom Error Handlers

Use `catch` functions to customize error handling:

```lua
local result, success = try { 
  dangerous_operation,
  catch = function(error_info)
    -- Log error
    vim.notify(error_info.message, vim.log.levels.ERROR)
    
    -- Modify error for storage
    error_info.custom_handled = true
    
    -- Return error_info to store it, or nil to ignore
    return error_info
  end
}
```

## Configuration Options

### Global Options

- **`mode`** (`'sequential'` | `'any_success'`)
  - `sequential`: Execute all operations in order
  - `any_success`: Stop after first successful operation

- **`on_error`** (`'continue'` | `'stop'`)
  - `continue`: Continue execution after errors
  - `stop`: Stop execution on first error

- **`collect_results`** (`boolean`, default: `true`)
  - Whether to collect and return operation results

- **`or_else`** (`any` | `function`)
  - Global fallback value or function

- **`catch`** (`function(error, index?) -> error?`)
  - Global error handler function

### Per-operation Options

- **`or_else`** (`any` | `function`)
  - Fallback for this specific operation

- **`catch`** (`function(error) -> error?`)
  - Error handler for this specific operation

## Examples

### Configuration Loading

```lua
-- Safe configuration loading with fallbacks
try {
  require,
  { 'user.options' },
  { 'user.keymaps' },
  { 'user.plugins', or_else = { plugins_disabled = true } },
  { 'user.lsp', catch = function(e) 
    vim.notify('LSP config failed, using defaults', vim.log.levels.WARN)
    return nil -- Don't store error
  end },
  on_error = 'continue'
}
```

### Plugin Management

```lua
-- Try multiple fuzzy finders, use first available
local finder, available = try {
  { require, 'telescope' },
  { require, 'fzf-lua' },
  { require, 'vim.ui.select' }, -- Fallback to builtin
  mode = 'any_success'
}

if available then
  -- Setup the found fuzzy finder
  finder.setup()
end
```

### Keymap Setup

```lua
-- Setup keymaps with error recovery
try {
  vim.keymap.set,
  { 'n', '<leader>ff', '<cmd>Telescope find_files<cr>' },
  { 'n', '<leader>fg', '<cmd>Telescope live_grep<cr>' },
  { 'n', '<leader>fb', '<cmd>Telescope buffers<cr>', 
    catch = function(e) 
      vim.notify('Buffer keymap failed: ' .. e.message)
      return nil 
    end },
  on_error = 'continue'
}
```

## Testing

The Try API includes a comprehensive test framework following Lua testing best practices:

### Running Tests

```lua
-- Run all tests
local test_results = require('test.try_spec').run()

-- Check results
if test_results.success then
  print('All tests passed!')
else
  print(string.format('%d tests failed', test_results.failed))
end
```

### Test Structure

Tests are organized using a BDD-style framework with descriptive test names:

```lua
describe('Feature Name', function()
  before_each(function()
    -- Setup before each test
  end)
  
  it('should do something specific', function()
    -- Test implementation with assertions
    assert_equal(actual, expected)
  end)
end)
```

### Writing Custom Tests

```lua
local test = require('test.framework')

test.describe('My Feature', function()
  test.it('should work correctly', function()
    local result, success = try(my_function, 'test_arg')
    test.assert_equal(success, true)
    test.assert_equal(result, 'expected_value')
  end)
end)

-- Run tests
test.run()
```

---

## Best Practices

1. **Use appropriate patterns**: Choose the right overload for your use case
2. **Handle errors gracefully**: Use `or_else` and `catch` for important operations
3. **Monitor error storage**: Regularly check `_G.Errors` for issues
4. **Test your configurations**: Use the testing framework to verify behavior
5. **Document custom handlers**: Add comments for complex error handling logic

The Try API makes Neovim configurations more robust by providing safe execution patterns with comprehensive error handling and flexible fallback mechanisms.