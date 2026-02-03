Be extremely concise. Sacrifice grammar for the sake of concision.

# Use tools, not bash

These bash commands are blocked. Use the tool instead:

Tool  | Denied bash
------|------------
Read  | cat
Write | echo, printf, touch, tee
Edit  | sed, awk
Glob  | ls, find
Grep  | grep

Use `rg`, `head` and `tail` for piping (allowed).
