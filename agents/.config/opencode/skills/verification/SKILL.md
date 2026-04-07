---
name: verification
description: Verifies SDLD specs and implementation align. Runs acceptance tests, validates consistency, updates verification dates. Use when testing, reviewing, or preparing for release.
---

Verifies specs are current and consistent with implementation

## 1. Gather specs

Read all specs from docs/specs/ related to the feature.

## 2. Run acceptance tests

Execute acceptance specs to verify implementation.

## 3. Verify entities

Check entity specs match implementation:
- All fields present
- Types correct
- Relationships accurate

## 4. Verify state machines

Validate state transitions:
- All states reachable
- Invalid transitions rejected
- Events firing correctly

## 5. Verify invariants

Confirm invariants hold:
- Run tests for each invariant
- Check database constraints
- Validate business rules

## 6. Update verification dates

For specs that pass verification:
- Update last_verified_at to today
- Change status to active if draft

## 7. Document issues

Note any discrepancies between specs and implementation.

## 8. Save updates

Write verified specs to docs/specs/
