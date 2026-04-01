# Feature intent specification guide

## Purpose

Defines why the feature exists, who it serves, and success criteria

## DSL

```yaml
goal: ""
personas:
  primary: ""
  secondary: []
success: []
constraints: []
non_goals: []
```

## Rules

- Goal must not encode a solution
- Personas must be behavioral under constraints (not a role label)
- Choose an ideal primary persona to optimize for
- Success must be necessary for the goal (no removable metrics)
- Constraints must eliminate at least one viable approach
- Non-goals must prevent a plausible mis-scope (no generic exclusions)
