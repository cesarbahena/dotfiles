# fn API Documentation

The `fn` API provides a powerful, lazy function wrapper system with conditional execution, error handling, and flexible notification options. It's designed to make complex function composition and error handling patterns more readable and maintainable.

## Table of Contents

- [Basic Concepts](#basic-concepts)
- [Usage Patterns](#usage-patterns)
- [Enhanced Condition Evaluation](#enhanced-condition-evaluation)
- [Notify Options](#notify-options)
- [Examples](#examples)
- [API Reference](#api-reference)

## Basic Concepts

The `fn` API creates **lazy functions** - functions that are defined now but executed later. This allows for:

- **Conditional execution**: Execute different functions based on runtime conditions
- **Error handling**: Graceful fallback when functions fail
- **Notification control**: Fine-grained control over error messaging
- **Function composition**: Chain and compose complex function calls

## Usage Patterns

### 1. Direct Function Call (No Arguments)

Wrap a function with basic error handling:

```lua
local safe_fn = fn(function_reference)
```

### 2. Direct Module Path Call (No Arguments)

Call a module function by string path (most common case):

```lua
local module_fn = fn('module.function_name')
-- Supports both syntaxes:
-- Legacy: 'module.function' (only last dot)
-- New: 'module::nested.property.path' (full dot notation after ::)
```

### 3. Function Call with Arguments

Use table format for functions with arguments:

```lua
local fn_with_args = fn({function_reference, arg1, arg2, arg3})
```

### 4. Module Path Call with Arguments

Call a module function with arguments:

```lua
local module_fn = fn({'module.function_name', arg1, arg2})
```

### 5. Conditional Execution

Execute different functions based on a condition:

```lua
local conditional_fn = fn {
  when = condition,           -- boolean, string, function, or table
  [1] = main_function,        -- MUST be a function (use nested fn() for lazy)
  or_else = fallback_function -- MUST be a function (optional)
}
```

### 6. Try/Catch with Error Handling

Handle function errors with configurable notifications:

```lua
local try_fn = fn {
  [1] = main_function,        -- MUST be a function (use nested fn() for lazy)
  or_else = fallback,         -- MUST be a function (optional)
  notify = 'fallback'         -- notification strategy ('main'|'fallback'|'both')
}
```

## Enhanced Condition Evaluation

The `when` condition in `fn` supports advanced evaluation patterns for vim variables, options, and custom iteration.

### Basic Condition Types

```lua
-- String expression (lazy evaluation)
when = 'vim.bo.filetype == "lua"'

-- Function (lazy evaluation)  
when = function() return vim.bo.filetype == "lua" end

-- Boolean (immediate evaluation)
when = true
```

### Vim Variable/Option Access

Access vim variables and options with clean, readable syntax:

```lua
-- Current buffer filetype
when = { 'filetype', eq = 'lua', in_this = 'buffer' }

-- Any window with gitsigns blame open
when = { 'gitsigns_preview', eq = 'blame', in_any = 'window' }

-- Global plugin loaded
when = { 'loaded_telescope', in_this = 'global' }

-- Vim state (count prefix > 0)
when = { 'count', gt = 0, in_this = 'state' }

-- Environment variable
when = { 'TERM', eq = 'xterm-256color', in_this = 'env' }
```

### Scope Options

#### Merged Scopes (check both variables and options)

| Scope | Variables | Options | Description |
|-------|-----------|---------|-------------|
| `window` | `vim.w` | `vim.wo` | Window variables + options |
| `buffer` | `vim.b` | `vim.bo` | Buffer variables + options |
| `global` | `vim.g` | `vim.go` | Global variables + options |

#### Single Scopes

| Scope | Access | Description |
|-------|--------|-------------|
| `tab` | `vim.t` | Tab-local variables |
| `option` | `vim.o` | Global options |
| `env` | `vim.env` | Environment variables |
| `state` | `vim.v` | Vim internal state (count, version, register, etc.) |

### Iteration Options

```lua
-- Check current context only
in_this = 'buffer'   -- vim.b[key] or vim.bo[key]

-- Iterate through all items, return ID of first match  
in_any = 'window'    -- Check all windows, return winid

-- Custom iteration
forEach = { 1, 2, 3, 4, 5 }           -- Iterate array
forEach = 'windows'                   -- Shortcut for vim.api.nvim_list_wins()
forEach = function() return my_list() end  -- Dynamic iteration
```

### Comparison Operators

| Operator | Description | Example |
|----------|-------------|---------|
| `eq` | Equal to | `{ 'filetype', eq = 'lua' }` |
| `ne` | Not equal to | `{ 'filetype', ne = 'help' }` |
| `gt` | Greater than | `{ 'count', gt = 0 }` |
| `lt` | Less than | `{ 'line_count', lt = 100 }` |
| `gte` | Greater than or equal | `{ 'version', gte = 801 }` |
| `lte` | Less than or equal | `{ 'tabstop', lte = 4 }` |
| `contains` | Contains key/substring | `{ result, contains = 'stage_hunk' }` |

### Property Access with `at` Option

Access properties from function results using the `at` option:

```lua
-- Compare values from state tables
when = { vim.fn.undotree, at = 'seq_cur', lt = { vim.fn.undotree, at = 'seq_last' } }

-- Access nested properties from LSP clients
when = { vim.lsp.get_clients, at = '1.name', eq = 'tailwindcss' }  -- Check first client name

-- Mix function calls with literals
when = { vim.fn.line, eq = 5 }  -- Current line is 5
when = { 'vim.bo.filetype', eq = 'lua' }  -- Literal string comparison
```

## Notify Options

The `notify` option controls when and how errors are reported:

| Option | Description | Main Function Error | Fallback Function Error |
|--------|-------------|---------------------|-------------------------|
| `'main'` | Notify only main errors | ✅ Notified | ❌ Silent (propagates) |
| `'fallback'` | Notify only fallback errors (default) | ❌ Silent | ✅ Notified |
| `'both'` | Notify both main and fallback errors | ✅ Notified | ✅ Notified |

### Notification Behavior Details

- **Notified**: Error message shown via `vim.notify()`
- **Silent**: No notification, execution continues
- **Propagates**: Error bubbles up to caller (function will throw)

## Examples

### Basic Function Calls

```lua
-- Direct function (no arguments)
local simple_fn = fn(vim.cmd.write)

-- Function with arguments  
local fn_with_args = fn({vim.cmd, 'edit ~/.vimrc'})

-- Module path call
local formatter = fn({'conform.format', { async = true }})
```

### Conditional Execution Examples

```lua
-- Simple boolean condition
local toggle_wrap = fn {
  when = vim.o.wrap,
  [1] = fn({vim.cmd, 'set nowrap'}),
  or_else = fn({vim.cmd, 'set wrap'}),
}

-- Function condition
local smart_save = fn {
  when = function() return vim.bo.modified end,
  [1] = fn(vim.cmd.write),
  or_else = fn(function() print('Buffer not modified') end),
}

-- Advanced vim scope condition
local typescript_action = fn {
  when = { 'filetype', eq = 'typescript', in_any = 'buffer' },
  [1] = fn({'typescript.organize_imports'}),
  or_else = fn(function() print('No TypeScript files open') end),
}
```

### Error Handling Examples

```lua
-- Basic try/catch
local safe_format = fn {
  [1] = fn({'conform.format', { async = true }}),
  or_else = fn({vim.cmd, '!stylua %'}),
  notify = 'main'  -- Show error if conform fails
}

-- Nested error handling
local complex_operation = fn {
  [1] = fn {
    [1] = fn({'project.load_config'}),
    or_else = fn({'project.create_default_config'}),
    notify = 'both'
  },
  or_else = fn(function() print('Project setup failed') end),
}
```

### Real-world Keymap Example

```lua
-- Your original keymap, updated for new API
local claude_keymap = fn {
  when = { fn({'vim.fn.system', 'pgrep -f claude'}), eq = '' },
  [1] = fn({vim.cmd, 'ClaudeCode --continue'}),
  or_else = fn({vim.cmd, 'ClaudeCodeAdd %'}),
}
```

## API Reference

### fn(spec)

Creates a lazy function wrapper.

#### Parameters

- `spec` (function|string|table): The function, module path, or specification table

#### Returns

- `function`: A lazy function that executes the specified logic when called

#### Specification Types

**1. Direct Function:**
```lua
fn(function_reference)
```

**2. Direct Module Path:**
```lua
fn('module.function')
```

**3. Function with Arguments:**
```lua
fn({function_reference, arg1, arg2, ...})
```

**4. Module Path with Arguments:**
```lua
fn({'module.function', arg1, arg2, ...})
```

**5. Conditional Execution:**
```lua
fn({
  when = condition,    -- any condition type
  [1] = function,      -- MUST be function
  or_else = function   -- MUST be function (optional)
})
```

**6. Try/Catch:**
```lua
fn({
  [1] = function,      -- MUST be function
  or_else = function,  -- MUST be function (optional)
  notify = 'option'    -- 'main'|'fallback'|'both' (optional, default: 'fallback')
})
```

### Module Path Resolution

Module paths support two syntaxes:

- **Legacy**: `'module.function'` (splits on last dot only)
- **New**: `'module::nested.property.path'` (supports deep property access)

Examples:
- ✅ `'vim.cmd'`, `'conform.format'`, `'telescope::extensions.ui-select.ui_select'`
- ❌ `'just_a_function'`, `'module.'`, `'.function'`

### Error Handling Strategy

- **Direct/Module calls**: Always use pcall, notify errors appropriately
- **Conditional execution**: No error handling - errors propagate naturally
- **Try/catch**: Configurable error handling based on `notify` option

## Key Changes from Previous API

1. **Simplified Arguments**: No more variadic parameters - use tables for arguments
2. **Functions Only for Conditionals**: `[1]` and `or_else` must be functions in conditional/try-catch patterns
3. **Nested fn() for Lazy Functions**: Use `fn()` calls explicitly instead of table specifications
4. **Cleaner Separation**: Clear distinction between function calls and control flow

## Best Practices

### 1. Use fn() for Lazy Functions in Conditionals
```lua
-- Good
fn {
  when = condition,
  [1] = fn({vim.cmd, 'command'}),
  or_else = fn(fallback_function),
}

-- Avoid (this will error)
fn {
  when = condition, 
  [1] = {vim.cmd, 'command'},  -- Error: must be function
}
```

### 2. Choose Appropriate Notify Options
```lua
-- For user-facing operations, notify main errors
local save_file = fn {
  [1] = fn(vim.cmd.write),
  notify = 'main',
  or_else = fn(function() print('Save failed') end),
}
```

### 3. Use Module Paths for External Dependencies
```lua
-- Good - clear dependency
local format = fn({'conform.format', options})

-- Also good - explicit function reference
local format = fn({require('conform').format, options})
```

This API provides a clean, predictable interface for complex function composition while maintaining powerful condition evaluation capabilities.