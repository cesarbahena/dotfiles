---
name: sprint-planning
description: |
  Default methodology for agentic software development inspired in SCRUM.
  Use for any non trivial code changes or when users ask for a plan.
---

Sprint duration: 1 day

## Workflow

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
