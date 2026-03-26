---
name: sprint-planning
description: |
  Plan development work, estimate tasks, prioritize backlog, organize sprints.
  Use when user asks to plan, estimate, prioritize, organize work, or
  when starting a new feature or significant code change.
---

Trigger phrases: "plan", "sprint", "prioritize", "estimate", "backlog",
"organize work", "roadmap", "what should we do first"

Sprint duration: 1 day

## Workflow

1. Order PBI github issues by priority.
2. Calculate how many PBI your parallel agents can solve in a day.
3. Consider Epic github tag to work in related PBIs together.
4. Use the question tool to disambiguate priorities.
5. Use the todowrite tool to plan the sprint.
6. Do not code, use the `sprint-execution` skill to make subagents do it
   in git worktrees in `feature/*` or `hotfix/*` branches.
7. You are the scrum master, unblock the agents or fail fast if the user
   input is needed (like sudo privileges).
8. When the sprint is done use the `sprint-review` skill.