# Custom Treesitter Textobjects

This directory contains custom treesitter queries for enhanced textobject functionality.

## Function Definition Textobject (`d`)

### Purpose
The `d` textobject provides a function textobject that **only** matches function declarations, not:
- Function expressions
- Arrow functions  
- Method definitions
- Function calls

### Usage
- `ad` - Select around function declaration (entire function including signature)
- `id` - Select inside function declaration (first statement in function body)
- `]d` / `[d` - Navigate to next/previous function declaration
- `{d` / `}d` - Navigate to function declaration end/start

### Implementation
Custom queries in:
- `javascript/textobjects.scm` - For JavaScript files
- `typescript/textobjects.scm` - For TypeScript files

Both create `@function_def.outer` and `@function_def.inner` captures that only match `function_declaration` nodes.

### Example
```javascript
// These will be selected by 'ad':
function getConfig() {
  return Config.all({
    port: 3000
  });
}

function simpleFunc() {
  console.log('test');
}

// These will NOT be selected by 'ad':
const arrowFunc = () => console.log('arrow');  // arrow function
class.methodFunc() { return 'method'; }        // method definition  
const result = getConfig();                    // function call
```

### Technical Details
- Uses `; extends` to add to existing queries without replacing them
- Simple `(_) @function_def.inner` pattern avoids complex `#make-range!` directives
- Custom capture names prevent conflicts with built-in `@function` textobjects