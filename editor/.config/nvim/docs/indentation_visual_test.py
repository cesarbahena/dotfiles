#!/usr/bin/env python3
"""
Visual Test Guide for Indentation Textobjects
==============================================

Place cursor at the marked positions and test these textobjects:
- ii: inner indentation (same level content)
- ai: outer indentation (includes surrounding blanks) 
- igi: indentation with line above (outer, inner)
- agi: indentation with line above (outer, inner)
- iI: rest of indentation (from cursor down with same/higher indent)
- aI: greedy outer indentation (includes blanks)

Expected Selections are marked with [START] and [END] comments.
"""

def test_function():
    # [START ii/ai from next line] 
    print("line 1")
    print("line 2")
    x = 5  # <- CURSOR HERE: test ii, ai, iI, aI
    print("line 3") 
    # [END ii/ai]
    
    if x > 0:
        # [START nested ii/ai from next line]
        result = calculate(x)
        process(result)  # <- CURSOR HERE: test nested selections
        final = cleanup(result)
        # [END nested ii/ai]
        
        return final

# [START standalone function ii/ai]        
def another_function():
    # Comment inside function
    value = 42  # <- CURSOR HERE: test function level indentation
    return value * 2
# [END standalone function ii/ai]

class TestClass:
    """Class for testing class-level indentation."""
    
    # [START class method ii/ai]
    def method_one(self):
        self.x = 1
        self.y = 2  # <- CURSOR HERE: test method level
        return self.x + self.y
    # [END class method ii/ai]
    
    def method_two(self):
        # Blank line above
        
        data = [1, 2, 3]
        
        for item in data:
            # [START for loop ii/ai]
            processed = item * 2
            if processed > 4:  # <- CURSOR HERE: test loop content
                print(f"Large: {processed}")
            else:
                print(f"Small: {processed}")
            # [END for loop ii/ai]
            
        return data

# Test iI (rest of indentation) specifically:
def rest_of_indentation_test():
    print("Before cursor")
    print("At cursor position")  # <- CURSOR HERE: iI should select from here down
    # iI should select these lines:
    if True:
        print("nested 1")
        print("nested 2")
        
    print("same level 1")  
    print("same level 2")
    
    # Until here (end of same indentation level)

def different_function():
    # This should NOT be included in iI from above cursor position
    pass

# Test edge cases:
def edge_cases():
    
    # Blank lines and comments
    x = 1  # <- CURSOR HERE: test with surrounding blanks
    
    y = 2
    
    # Final test
    return x + y

if __name__ == "__main__":
    # Module execution
    test_function()
    # <- CURSOR HERE: test main block indentation
    TestClass().method_one()
    edge_cases()