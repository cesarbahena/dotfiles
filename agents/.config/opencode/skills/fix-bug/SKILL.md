---
name: fix-bug
description: |
  Diagnose and fix bugs with strict spec alignment.
  Use when you find a bug or the user reports one.
---

## Goal

Fix bugs by aligning code, tests, and spec.

## Steps

1. TRACE
   - Identify affected feature
   - Locate `<feature-name>.acceptance.feature`

2. REPRODUCE
   - Create failing test OR reproduce manually
   - If ambiguous → ask targeted questions

3. SPEC CHECK
   - If behavior is NOT in spec:
     → update spec FIRST
   - If behavior IS in spec:
     → ensure test reflects it

4. ROOT CAUSE
   - Identify underlying issue
   - Avoid patches or shortcuts

5. FIX
   - Implement minimal correction

6. VERIFY
   - All tests pass
   - No regressions

7. LEARN
   - Improve:
     - tests
     - acceptance.feature (if clarity improves)

8. COMMIT
   - All changes must exist in repo

## Exit Condition

Bug resolved, behavior aligned with spec, tests passing.
