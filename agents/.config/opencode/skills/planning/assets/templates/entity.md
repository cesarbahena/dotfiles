---
id: ENT-XXX
type: entity
status: active
last_verified_at: YYYY-MM-DD
state_machines:
  - SM-XXX
---

## Description

[What this domain object represents]

## Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| id | UUID | yes | Unique identifier |
| [field_name] | [type] | yes/no | [Description] |

## Behaviors

- [behavior_name](): [What it does]
- [behavior_name](): [What it does]

## Lifecycle

[State transitions this entity goes through]

## Relationships

- [Entity A] has many [Entity B]
- [Entity A] belongs to [Entity B]

## Constraints

- [Constraint 1]
- [Constraint 2]

## Events

- [Event 1]: Fired when [condition]
- [Event 2]: Fired when [condition]

## Related

- related_state_machine: [SM-XXX]
- related_use_case: [UC-XXX]
- related_invariant: [INV-XXX]
