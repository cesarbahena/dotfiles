---
name: sprint-planning
description: This is standard methodology for agentic software development inspired in SCRUM.
---

## When to use me

Any non trivial code change.

## What do I do

Sprint duration: 1 day

### Workflow

1. Order PBI github issues by priority.
2. Calculate how many PBI can your paralel agents solve in a day.
3. Consider Epic github tag to work in related PBIs together.
4. Use the question tool to desambiguate priorities.
5. Use the todowrite tool to plan the sprint.
6. Do not code, use the `sping-execution` skill to make subagents do it
   in git worktrees in `feature/*` or `hotfix/*` branches.
7. You are the scrum master, unblock the agents or fail fast if the user
   input is needed (like sudo priviledges).
8. When the sprint is done use the `sprint-review` skill.
