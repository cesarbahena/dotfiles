; extends

; Custom textobject for function declarations only - exact copy of working pattern
(function_declaration
  body: (statement_block)) @function_def.outer

(function_declaration
  body: (statement_block
    (_) @function_def.inner))