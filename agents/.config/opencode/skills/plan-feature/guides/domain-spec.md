# Domain model specification guide

## Purpose

Defines domain language, aggregates, and invariants

## DSL

```yaml
bounded_context: "<name>"

ubiquitous_language:
  <term>: "<definition>"

aggregates:
  <Aggregate>:
    root: "<Entity>"
    description: |
      "<explaination with
      ubiquitous_language>"
    invariants: []

entities:
  <Entity>: "<description>"
value_objects: []
domain_events: []
commands: []
policies: []
```

## Rules

- Invariants belong to aggregates
- Code enforces invariants
- Tests validate invariants
