---
name: implement-feature
description: |
  Implement behavior using spec-driven TDD from acceptance.feature file.
  Use when making any code changes that are not hotfixes.
---

# Skill: implement-feature

## Goal

Implement behavior defined in `<feature-name>.acceptance.feature` using atomic TDD.

## Steps

1. SELECT next smallest unimplemented behavior from spec

2. RED
   - Write ONE failing test
   - Assert ONE observable outcome

3. GREEN
   - Implement minimal code to pass

4. VALIDATE
   - Test passes
   - No unrelated tests break

5. REPEAT
   - Continue until all scenarios covered

6. COVERAGE TARGET
   - ≥ 90% of spec scenarios mapped to tests

7. FREEZE TESTS
   - Tests cannot change unless:
     - spec changes OR
     - user explicitly approves

8. REFACTOR CODE
   - Improve structure without changing behavior

9. REFACTOR SPEC (optional)
   - Improve clarity only
   - Do NOT change behavior silently

## Exit Condition

All scenarios implemented, tests passing, behavior aligned with spec.
