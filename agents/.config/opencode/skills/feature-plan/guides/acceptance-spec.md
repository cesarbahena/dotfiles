# Feature acceptance specification guide

## Purpose

Executable behavior specification for TDD

## DSL

```gherkin
Feature: <feature>

  Scenario: <name>
    Given <state>
    When <action>
    Then <outcome>
```

## Rules

- One scenario = one behavior
- Must be testable end-to-end
- Use domain language
- Enforce invariants in domain spec
- Cover edge cases
- No implementation details
