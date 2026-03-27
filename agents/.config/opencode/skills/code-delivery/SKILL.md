---
name: code-delivery
description: |
  Execute implementation via sub-agents. Load AFTER plan-work.
---

## Triggers

Load after:
- plan-work skill used
- Clear plan exists
- User says "do it", "build it"

## Workflow

1. Pick one deliverable from plan
2. Prepare context: decisions, what's being built, completion criteria
3. Spawn sub-agent with task tool
4. Monitor progress
5. Verify delivered work