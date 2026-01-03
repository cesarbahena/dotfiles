# Try API Tests

This directory contains comprehensive tests for the Try API using **plenary.nvim**, the standard testing framework for Neovim plugins.

## Prerequisites

Install plenary.nvim (if not already installed):

```bash
# Using lazy.nvim (add to your plugins)
{ "nvim-lua/plenary.nvim" }

# Or manually for testing
git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/lazy/plenary.nvim
```

## Running Tests

### Command Line (Recommended)
```bash
# Run all tests
make test

# Run with verbose output  
make test-verbose

# Run minimal output
make test-minimal

# Run specific test file
make test-file
```

### Within Neovim
```lua
-- Run all tests
:PlenaryBustedDirectory tests/

-- Run specific test file
:PlenaryBustedFile tests/try_spec.lua

-- With custom options
:PlenaryBustedDirectory tests/ { verbose = true }
```

## Test Structure

- `try_spec.lua` - Main test suite for all Try API functionality
- `minimal_init.lua` - Minimal initialization for test environment
- `README.md` - This documentation

## Test Coverage

The test suite covers:

✅ **Simple Function Calls**
- Basic execution and error handling
- Multiple argument passing

✅ **Single Operations with Options**  
- or_else fallbacks (values and functions)
- catch handlers with/without error storage

✅ **Function with Multiple Argument Sets**
- Continue vs stop error handling modes
- Per-argument-set options (or_else, catch)
- Result collection control

✅ **Batch Operations**
- Sequential and any_success modes
- Per-operation error handling
- Complex batch scenarios

✅ **Error Handling and Storage**
- Proper error categorization
- Error structure validation
- Global error storage

✅ **Real-world Usage Patterns**
- Module loading scenarios
- Initialization with stop-on-error
- Complex configuration patterns

## Writing New Tests

Follow plenary.nvim patterns:

```lua
describe('Feature Name', function()
  before_each(function()
    _G.Errors = {} -- Reset state
  end)
  
  it('should do something specific', function()
    local result, success = try_fn(test_function, args)
    assert.are.equal(expected, result)
    assert.is_true(success)
  end)
end)
```

## Continuous Integration

These tests are designed to run in CI/CD environments:

```yaml
# GitHub Actions example
- name: Run Tests
  run: make test
```

## Assertions Available

- `assert.are.equal(expected, actual)`
- `assert.are.same(expected, actual)` (deep equality)
- `assert.is_true(value)`
- `assert.is_false(value)` 
- `assert.is_nil(value)`
- `assert.is_not_nil(value)`

All tests should be deterministic and isolated (no side effects between tests).