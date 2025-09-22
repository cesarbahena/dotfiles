-- Python-specific keymap overrides
-- Remap ai to use (outer, inner) behavior for better Python indentation

keymap({
  operator {
    'Indentation with line above',
    fn { 'various-textobjs.indentation', 'outer', 'inner' },
  },
}, { buffer = true })

