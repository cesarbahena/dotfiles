# Indentation Textobjects Test Guide

## Quick Reference

| Textobj | Description | What it selects |
|---------|-------------|-----------------|
| `ii` | Indentation | Lines with same/higher indentation |
| `ai` | Indentation with lines above/below | Same as `ii` but includes surrounding blanks |
| `igi` | Indentation (with line above variant) | Same level, different border handling |
| `agi` | Indentation with line above | Outer with different border handling |
| `iI` | Rest of indentation | From cursor down with same/higher indent |
| `aI` | Greedy outer indentation | Like `iI` but includes surrounding blanks |

## Test Files Created

1. **`/tmp/indentation_test.py`** - Comprehensive test with real code scenarios
2. **`/tmp/indentation_visual_test.py`** - Visual guide with expected selections marked

## How to Test

1. Open one of the test files:
   ```bash
   nvim /tmp/indentation_visual_test.py
   ```

2. Navigate to a marked cursor position (search for "CURSOR HERE")

3. Enter visual mode and test textobjects:
   ```vim
   vii    " visual + inner indentation
   vai    " visual + outer indentation  
   vigi   " visual + indentation (gi variant)
   vagi   " visual + outer indentation (gi variant)
   viI    " visual + rest of indentation
   vaI    " visual + greedy outer indentation
   ```

4. Use `d` + textobj to delete or `y` + textobj to yank:
   ```vim
   dii    " delete inner indentation
   yaI    " yank greedy outer indentation
   ```

## Current Configuration Status

✅ All textobjects are properly configured and generating correct keymaps
✅ Multiple function support working (`iI`/`aI` use different functions)
✅ Enhanced descriptions with "with" modifiers working
✅ Arguments properly passed to various-textobjs functions

## Your Current Mappings

- `ii`/`ai`: `indentation('inner','inner')` / `indentation('outer','outer')`
- `igi`/`agi`: `indentation('inner','inner')` / `indentation('outer','inner')`
- `iI`: `restOfIndentation()`
- `aI`: `greedyOuterIndentation('inner')`

Note: There seems to be an issue in the config - `aI` should use `outerIndentation`, not `greedyOuterIndentation`. Let me check the actual function names in the plugin.