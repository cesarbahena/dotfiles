local eq = assert.are.equal
local same = assert.are.same
local is_nil = assert.is_nil
local is_true = assert.is_true
local is_false = assert.is_false

-- Import the fn module
local fn_module = require('utils')
local fn = fn_module.fn

describe('fn API', function()
  local original_notify
  local notifications = {}

  before_each(function()
    -- Mock vim.notify to capture notifications
    original_notify = vim.notify
    notifications = {}
    vim.notify = function(message, level)
      table.insert(notifications, { message = message, level = level })
    end
  end)

  after_each(function()
    -- Restore original vim.notify
    vim.notify = original_notify
  end)

  describe('Basic Function Calls', function()
    it('should execute successful function calls', function()
      local test_fn = fn(function(x, y) return x + y end, 5, 3)
      local result = test_fn()
      eq(8, result)
      eq(0, #notifications) -- No notifications on success
    end)

    it('should handle module path calls', function()
      local test_fn = fn('string.format', 'Hello %s', 'World')
      local result = test_fn()
      eq('Hello World', result)
    end)
  end)

  describe('Conditional Execution (when/or_else)', function()
    it('should execute main function when condition is true', function()
      local test_fn = fn {
        when = true,
        function() return 'main_executed' end,
        or_else = function() return 'or_else_executed' end,
      }
      local result = test_fn()
      eq('main_executed', result)
    end)

    it('should execute or_else when condition is false', function()
      local test_fn = fn {
        when = false,
        function() return 'main_executed' end,
        or_else = function() return 'or_else_executed' end,
      }
      local result = test_fn()
      eq('or_else_executed', result)
    end)

    it('should handle lazy function evaluation for when', function()
      local test_fn = fn {
        when = fn('string.find', 'hello world', 'world'),
        function() return 'found' end,
        or_else = function() return 'not_found' end,
      }
      local result = test_fn()
      eq('found', result) -- string.find returns truthy value
    end)
  end)

  describe('Error Handling with notify options', function()
    describe('notify = "main" (notify main errors only)', function()
      it('should notify main error and execute or_else without pcall', function()
        local test_fn = fn {
          function() error('Main error') end,
          notify = 'main',
          or_else = function() return 'or_else_success' end,
        }
        
        local result = test_fn()
        eq('or_else_success', result)
        eq(1, #notifications)
        assert.truthy(string.find(notifications[1].message, 'Main error'))
        eq(vim.log.levels.ERROR, notifications[1].level)
      end)

      it('should not notify or_else errors', function()
        local test_fn = fn {
          function() error('Main error') end,
          notify = 'main',
          or_else = function() error('Or_else error') end,
        }
        
        -- In 'main' mode, or_else is called directly (no pcall) so errors should propagate
        local success, err = pcall(test_fn)
        is_false(success)
        assert.truthy(string.find(err, 'Or_else error'))
        eq(1, #notifications) -- Only main error notified
        assert.truthy(string.find(notifications[1].message, 'Main error'))
      end)
    end)

    describe('notify = "fallback" (default - notify fallback errors only)', function()
      it('should not notify main error but notify or_else error', function()
        local test_fn = fn {
          function() error('Main error') end,
          notify = 'fallback',
          or_else = function() error('Fallback error') end,
        }
        
        local result = test_fn()
        is_nil(result)
        eq(1, #notifications)
        assert.truthy(string.find(notifications[1].message, 'Fallback error'))
        eq(vim.log.levels.ERROR, notifications[1].level)
      end)

      it('should execute successfully when or_else succeeds', function()
        local test_fn = fn {
          function() error('Main error') end,
          notify = 'fallback',
          or_else = function() return 'fallback_success' end,
        }
        
        local result = test_fn()
        eq('fallback_success', result)
        eq(0, #notifications) -- No notifications when fallback succeeds
      end)

      it('should work as default when notify not specified', function()
        local test_fn = fn {
          function() error('Main error') end,
          or_else = function() return 'default_behavior' end,
        }
        
        local result = test_fn()
        eq('default_behavior', result)
        eq(0, #notifications) -- Default fallback mode - no main error notification
      end)
    end)

    describe('notify = "both" (notify both main and fallback errors)', function()
      it('should notify both main and or_else errors', function()
        local test_fn = fn {
          function() error('Main error') end,
          notify = 'both',
          or_else = function() error('Fallback error') end,
        }
        
        local result = test_fn()
        is_nil(result)
        eq(2, #notifications)
        assert.truthy(string.find(notifications[1].message, 'Main error'))
        assert.truthy(string.find(notifications[2].message, 'Fallback error'))
      end)

      it('should notify main error even when or_else succeeds', function()
        local test_fn = fn {
          function() error('Main error') end,
          notify = 'both',
          or_else = function() return 'fallback_success' end,
        }
        
        local result = test_fn()
        eq('fallback_success', result)
        eq(1, #notifications)
        assert.truthy(string.find(notifications[1].message, 'Main error'))
      end)
    end)

    describe('notify option validation', function()
      it('should validate notify option and reject invalid values', function()
        local test_fn = fn {
          function() error('Main error') end,
          notify = 'invalid',
          or_else = function() return 'fallback' end,
        }
        
        local success, err = pcall(test_fn)
        is_false(success)
        assert.truthy(string.find(err, 'Invalid notify option'))
      end)
    end)
  end)

  describe('Complex nested fn calls', function()
    it('should handle nested fn calls with different notify options', function()
      local test_fn = fn {
        when = false,
        function() return 'main' end,
        or_else = fn {
          function() error('Nested main error') end,
          notify = 'main',
          or_else = function() return 'nested_fallback' end,
        },
      }
      
      local result = test_fn()
      eq('nested_fallback', result)
      eq(1, #notifications)
      assert.truthy(string.find(notifications[1].message, 'Nested main error'))
    end)

    it('should handle module path resolution in tables', function()
      local test_fn = fn {
        { 'string.format', 'Hello %s %s', 'beautiful', 'world' },
        notify = 'main',
        or_else = function() return 'fallback' end,
      }
      
      local result = test_fn()
      eq('Hello beautiful world', result)
      eq(0, #notifications)
    end)
  end)

  describe('Edge cases', function()
    it('should return nil when main fails and no or_else provided', function()
      local test_fn = fn {
        function() error('No fallback') end,
        notify = 'main',
      }
      
      local result = test_fn()
      is_nil(result)
      eq(1, #notifications)
      assert.truthy(string.find(notifications[1].message, 'No fallback'))
    end)

    it('should handle successful main function without or_else', function()
      local test_fn = fn {
        function() return 'success' end,
        notify = 'both',
      }
      
      local result = test_fn()
      eq('success', result)
      eq(0, #notifications)
    end)
  end)
end)