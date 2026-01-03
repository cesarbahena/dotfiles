---
description: The only allowed agent to make git commits
mode: subagent
model: anthropic/claude-haiku-4-20251001
temperature: 0
tools:
  write: false
  edit: false
  bash: true
permission:
  bash:
    "git backdate": "allow"
    "git backdate --detailed": "ask"
---

!`git backdate what`
