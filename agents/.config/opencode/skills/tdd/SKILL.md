---
name: tdd
description: |
  USE to enforce maintainability and product requirements
  WHEN making any code changes
---

## INPUT

### SOURCE OF TRUTH

#### Acceptance criteria spec

DEFAULT `<feature>/application/acceptance.feature`
OR any folder if prepended `<feature>.acceptance.feature`

#### Domain model spec

DEFAULT `<domain>/domain/model.yml`
OR any folder when prepended `<domain>.model.yml`

### REFERENCES

#### System specs

DEFAULT `system/<spec>`
OR some global folder

#### Other feature specs

DEFAULT `<feature>/application/{intent.yml,flow.mmd,layout.json}`
OR any folder if prepended `<feature>.<spec>`

## OUTPUT

### Unit tests

High-value tests with 90%+ coverage

### Green tests

100% passing tests
OR sumary of failing tests + cause + new approach

## STEPS

### AUTORITATIVE FILES

`acceptance.feature`: must implement features as designed here

`model.yml`: must enforce all invariants designed here

### RED-GREEN LOOP

WHILE coverage < 90% DO

- write a single failing test
- minimal changes to pass
- retrospect on your implementation experience (theory vs practice)
- CONTINUE with your new knowlegde, writing better tests

### REFACTOR

IF coverage < 90% GOTO red-green loop

READONLY tests UNLESS approved
IF obious mistake THEN parent agent can approve
ELSE require user approval

1. Improve structure without changing behavior
2. Strive for best practices and codebase conventions

## FALLBACK

- Report any blockers to the parent agent or user
- Feedback is appreciated, specs are expected to be refined
