---
name: hotfix
description: |
  Debug and fix bugs, investigate crashes, find root cause of errors.
  Use when user reports bug, error, crash, issue, broken, not working,
  or when you encounter exceptions during development.
---

Trigger phrases: "fix bug", "debug", "crash", "error", "broken", "not working",
"why did this fail", "root cause", "regression", "something is wrong"

Prefereably use it while the sub-agents are working in the background.
If you are doing another task, in most cases stop and fix the bug.
Investigate the root cause and create fix plan.
Mostly a hands-off workflow, minimize questions to the user.

### 1. Spawn explore agents to deeply investigate the codebase to find:

- **Where** the bug manifests (entry points, UI, API responses).
- **Which** code path is involved (trace the flow).
- **Why** it fails (the root cause, not just the symptom).
- **What** related code exists (similar patterns, tests, adjacent modules).

Look at:

- Related source files and their dependencies.
- Existing tests (what's tested, what's missing).
- Unstaged changes (find in the conversation why **you** modified it).
- Recent changes to affected files (`git log` on relevant files).
- Error handling in the code path.
- Similar patterns elsewhere in the codebase that work correctly.

### 2. Identify the fix approach:

- The minimal change needed to fix the root cause.
- Which modules are affected.
- What behaviors need to be verified via tests.
- Whether this is a regression, missing feature, or design flaw.

### 3. Design TDD fix plan

Use `tdd` skill to create a fix plan. Look for oportunities to add
more test that prevent this or similar bugs in all codebase.

If the codebase has no automated tests, use an apropriate methodology but you
must propose improvements to the user to prevent similar errors from happening.

### 4. Create the GitHub issue

If the plan is non trivial, create a GitHub issue using the
`backlog-refinement` skill.

### 5. Fix the problem

Depending in the complexity, fix it yourself autonomously, spawn agents to fix
it using `sprint-execution` skill or ask the user for authorization if it
requires architecture changes.