---
name: backlog-refinement
description: |
  Create GitHub issues, refine backlog, write user stories, define requirements.
  Use when user wants to create issues, stories, tasks, or when clarifying
  what needs to be built.
---

Trigger phrases: "create issue", "write story", "add to backlog",
"define requirement", "what should we build", "PBI", "ticket"

## Workflow (if applicable):

1. Use your question tool disambiguate the problem they want to solve.
2. Explore the repo to verify their assertions and understand the current state of the codebase.
3. Interview them relentlessly until you reach a shared understanding. Walk down each branch of the design
   tree, resolving dependencies between decisions one-by-one. Dont hesitate to go back to disambiguate.
   If it can be answered by exploring the codebase, @explore instead.
4. For each PBI use the `backlog_item.md` to create or modify a gh issue.
