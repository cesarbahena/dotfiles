---
name: sprint-execution
description: Instruct sub-agents to deliver a single vertical code unit.
---

## When to use me

When ready to code after planing its done.

## What do I do

### Before spawn

1. **Identify durable decisions** unlikely to change throughout implementation:
   - Route paths and API structure
   - Database schema shapes
   - Data model names and relationships
   - Authentication and authorization approach
   - Third-party service boundaries

2. **Draft the slice** - define what complete means for this slice:
   - A narrow but complete path through schema → API → UI → tests
   - Demoable or verifiable on its own
   - Prefer thin slices over thick ones

### Prompt structure

Pass this to the sub-agent (aditional to other instructions):

```
High-level decisions:
_Any change to this must be authorized by the parent agent._
- [Route structures, DB schemas, auth approach, etc.]

Slice to build:
- [What this slice delivers]

Complete when: [how to verify/demo this slice]
```

