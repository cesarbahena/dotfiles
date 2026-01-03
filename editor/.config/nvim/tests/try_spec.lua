local eq = assert.are.equal
local same = assert.are.same
local is_nil = assert.is_nil
local is_true = assert.is_true
local is_false = assert.is_false

-- Import the try module
local try_module = require('utils.try')
local try_fn = try_module.try

describe('Try API', function()
  before_each(function()
    -- Reset global error storage before each test
    _G.Errors = {}
  end)

  describe('Simple Function Calls', function()
    it('should execute successful function calls', function()
      local result, success = try_fn(function(x, y) return x + y end, 5, 3)
      eq(8, result)
      is_true(success)
    end)

    it('should handle function call errors', function()
      local result, success = try_fn(function() error('test error') end)
      is_nil(result)
      is_false(success)
      eq(1, #_G.Errors)
      eq('test error', _G.Errors[1].message)
    end)

    it('should pass multiple arguments correctly', function()
      local result, success = try_fn(function(a, b, c, d) 
        return string.format('%s-%s-%s-%s', a, b, c, d)
      end, 'hello', 'world', 123, true)
      
      eq('hello-world-123-true', result)
      is_true(success)
    end)
  end)

  describe('Single Operations with Options', function()
    it('should handle successful single operations', function()
      local result, success = try_fn { function(x) return x * 2 end, 10 }
      eq(20, result)
      is_true(success)
    end)

    it('should handle or_else fallback with value', function()
      local result, success = try_fn { 
        function() error('test error') end, 
        or_else = 'fallback_value' 
      }
      eq('fallback_value', result)
      is_false(success)
    end)

    it('should handle or_else fallback with function', function()
      local result, success = try_fn { 
        function() error('test error') end, 
        or_else = function() return 'dynamic_fallback' end 
      }
      eq('dynamic_fallback', result)
      is_false(success)
    end)

    it('should handle catch with error storage', function()
      local caught_error = nil
      local result, success = try_fn { 
        function() error('custom error') end,
        catch = function(e) 
          caught_error = e
          e.custom_field = 'modified'
          return e
        end 
      }
      
      is_nil(result)
      is_false(success)
      assert.is_not_nil(caught_error)
      eq('custom error', caught_error.message)
      eq('modified', caught_error.custom_field)
      eq(1, #_G.Errors)
    end)

    it('should handle catch without error storage', function()
      local result, success = try_fn { 
        function() error('ignored error') end,
        catch = function(e) 
          return nil -- Don't store error
        end 
      }
      
      is_nil(result)
      is_false(success)
      eq(0, #_G.Errors) -- No error stored
    end)
  end)

  describe('Function with Multiple Argument Sets', function()
    it('should execute function with multiple argument sets', function()
      local results, success = try_fn {
        function(x, y) return x + y end,
        { 1, 2 },
        { 10, 20 },
        { 100, 200 }
      }
      
      same({ 3, 30, 300 }, results)
      is_true(success)
    end)

    it('should handle errors with continue mode', function()
      local results, success = try_fn {
        function(x) 
          if x == 'error' then error('test error') end
          return x .. '_success'
        end,
        { 'first' },
        { 'error' },
        { 'third' },
        on_error = 'continue'
      }
      
      eq('first_success', results[1])
      is_nil(results[2])
      eq('third_success', results[3])
      is_false(success)
      eq(1, #_G.Errors)
    end)

    it('should handle errors with stop mode', function()
      local results, success = try_fn {
        function(x) 
          if x == 'stop' then error('stop error') end
          return x .. '_success'
        end,
        { 'first' },
        { 'stop' },
        { 'should_not_execute' },
        on_error = 'stop'
      }
      
      eq('first_success', results[1])
      is_nil(results[2])
      is_nil(results[3])
      eq(1, #results) -- Execution stopped
      is_false(success)
    end)

    it('should handle per-argument-set or_else', function()
      local results, success = try_fn {
        function(x) 
          if x == 'fail' then error('failure') end
          return x * 2
        end,
        { 5 },
        { 'fail', or_else = 'replacement' },
        { 7 }
      }
      
      eq(10, results[1])
      eq('replacement', results[2])
      eq(14, results[3])
      is_false(success)
    end)

    it('should not collect results when configured', function()
      local result, success = try_fn {
        function(x) return x * 2 end,
        { 5 },
        { 10 },
        collect_results = false
      }
      
      is_nil(result)
      is_true(success)
    end)

    it('should handle global or_else fallback', function()
      local result, success = try_fn {
        function() error('always fails') end,
        { 'arg1' },
        { 'arg2' },
        or_else = 'global_fallback'
      }
      
      eq('global_fallback', result)
      is_false(success)
    end)
  end)

  describe('Batch Operations', function()
    it('should execute batch operations successfully', function()
      local results, success = try_fn {
        { function(x) return x * 2 end, 5 },
        { function(x, y) return x + y end, 10, 20 },
        { function() return 'static' end }
      }
      
      same({ 10, 30, 'static' }, results)
      is_true(success)
    end)

    it('should handle batch errors with continue mode', function()
      local results, success = try_fn {
        { function(x) return x * 2 end, 5 },
        { function() error('batch error') end },
        { function(x) return x + 1 end, 7 },
        on_error = 'continue'
      }
      
      eq(10, results[1])
      is_nil(results[2])
      eq(8, results[3])
      is_false(success)
    end)

    it('should handle batch errors with stop mode', function()
      local results, success = try_fn {
        { function(x) return x * 2 end, 5 },
        { function() error('stop error') end },
        { function(x) return x + 1 end, 7 },
        on_error = 'stop'
      }
      
      eq(10, results[1])
      is_nil(results[2])
      is_nil(results[3])
      eq(1, #results)
      is_false(success)
    end)

    it('should handle any_success mode', function()
      local result, success = try_fn {
        { function() error('first error') end },
        { function() return 'success!' end },
        { function() return 'second success' end },
        mode = 'any_success'
      }
      
      eq('success!', result)
      is_true(success)
    end)
  end)

  describe('Error Handling and Storage', function()
    it('should store errors with proper structure', function()
      try_fn(function() error('test error message') end)
      
      eq(1, #_G.Errors)
      local err = _G.Errors[1]
      eq('test error message', err.message)
      assert.is_string(err.time)
      assert.is_string(err.category)
      assert.is_table(err.traceback)
      assert.is_string(err.source)
    end)

    it('should categorize different error types', function()
      try_fn(function() error('module not found') end)
      try_fn(function() error('attempt to call nil') end)
      
      eq(2, #_G.Errors)
      -- Should have categorized the errors
      assert.is_string(_G.Errors[1].category)
      assert.is_string(_G.Errors[2].category)
    end)
  end)

  describe('Real-world Usage Patterns', function()
    it('should handle module loading pattern', function()
      local modules, success = try_fn {
        function(name) 
          if name == 'bad_module' then error('Module not found: ' .. name) end
          return { module = name, loaded = true }
        end,
        { 'good_module' },
        { 'bad_module', catch = function(e) return { message = 'Fallback used' } end },
        { 'another_module' }
      }
      
      eq('good_module', modules[1].module)
      eq('Fallback used', modules[2].message)
      eq('another_module', modules[3].module)
      is_false(success) -- Because one operation had an error (even though handled)
    end)

    it('should handle stop on error for initialization', function()
      local step_count = 0
      local results, success = try_fn {
        function(step) 
          step_count = step_count + 1
          if step == 'fail_here' then error('Critical initialization failure') end
          return step .. '_initialized'
        end,
        { 'core_options' },
        { 'core_keymaps' },
        { 'fail_here' },
        { 'core_lsp' }, -- Should not execute
        on_error = 'stop'
      }
      
      eq(3, step_count) -- Only first 3 steps executed
      eq('core_options_initialized', results[1])
      eq('core_keymaps_initialized', results[2])
      is_nil(results[3]) -- Failed step
      is_nil(results[4]) -- Never reached
      eq(2, #results) -- Only successful results
      is_false(success)
    end)
  end)
end)