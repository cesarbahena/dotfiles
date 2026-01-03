; extends

; Custom textobject for function declarations only
(function_declaration
  body: (statement_block)) @function_def.outer

(function_declaration
  body: (statement_block
    (_) @function_def.inner))