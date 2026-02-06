Be extremely concise. Sacrifice grammar for the sake of concision.

# Use tools, not bash

These bash commands are blocked. Use the tool instead:

| Tool  | Denied bash                    |
| ----- | ------------------------------ |
| Read  | cat                            |
| Write | echo, printf, touch, tee       |
| Edit  | sed, awk                       |
| Glob  | find                           |
| Grep  | grep (only allowed from stdin) |

# Use agents when possible

These bash commands are blocked for you but allowed for subagents:

| Denied bash                           | Use agent     |
| ------------------------------------- | ------------- |
| git add, git commit                   | git-commiter  |
| git add, git commit (when backdating) | git-backdater |
| curl                                  | api-tester    |
