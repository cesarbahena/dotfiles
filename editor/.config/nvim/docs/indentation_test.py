#!/usr/bin/env python3
"""
Test file for nvim-various-textobjs indentation textobjects.

This file demonstrates different indentation scenarios to test:
- ii/ai: inner/outer indentation 
- igi/agi: indentation with line above
- iI/aI: rest of indentation / greedy outer indentation

Instructions:
1. Place cursor at various marked positions (# <- cursor here)
2. Test different indentation textobjects to see what gets selected
3. Use visual mode (v) then textobject (e.g., vii, vai, viI, vaI)
"""

class OuterClass:
    """Outer class docstring."""
    
    def __init__(self):
        # <- cursor here: test ii, ai, iI, aI
        self.value = 42
        self.name = "test"
    
    def outer_method(self):
        """Method with nested structures."""
        
        if True:
            # <- cursor here: test all indentation textobjects
            print("Level 1")
            
            if self.value > 0:
                # <- cursor here: test what gets selected
                print("Level 2a")
                print("Level 2b")
                
                for i in range(3):
                    # <- cursor here: inner loop
                    print(f"Loop {i}")
                    if i == 1:
                        print("Special case")
            else:
                print("Alternative branch")
        
        # Comment after if block
        return "done"
    
    def method_with_decorators(self):
        # <- cursor here: test before decorator block
        @property
        @staticmethod
        def nested():
            # <- cursor here: inside decorated function
            pass
            
        return nested

# Module level comment

def standalone_function():
    """Standalone function for testing."""
    # <- cursor here: beginning of function
    
    try:
        # <- cursor here: inside try block
        result = complex_calculation()
        
        if result:
            # <- cursor here: nested if in try
            return result
            
    except Exception as e:
        # <- cursor here: inside except
        print(f"Error: {e}")
        raise
    
    finally:
        # <- cursor here: inside finally
        cleanup()


def complex_calculation():
    # <- cursor here: simple function start
    data = {
        'key1': 'value1',
        'key2': [
            # <- cursor here: inside list in dict
            'item1',
            'item2',
            {
                'nested_key': 'nested_value',
                # <- cursor here: inside nested dict
                'another_key': 'another_value'
            }
        ]
    }
    
    # List comprehension
    results = [
        # <- cursor here: inside list comprehension
        x * 2 
        for x in range(10) 
        if x % 2 == 0
    ]
    
    return results


# Test different indentation styles
if __name__ == "__main__":
    # <- cursor here: main block
    obj = OuterClass()
    
    # Call methods
    obj.outer_method()
    
    # Inline comment
    standalone_function()  # <- cursor here: end of line


# End of file comment