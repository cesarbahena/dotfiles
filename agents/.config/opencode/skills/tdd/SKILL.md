---
name: tdd
description: |
  Test-driven development: write tests first, then implementation.
  Use when user asks to add tests, write tests, test coverage, unit test,
  or when fixing bugs to prevent regression.
---

Trigger phrases: "write test", "add tests", "test coverage", "unit test",
"TDD", "red green refactor", "test first", "prevent regression"

## Philosophy

**Core principle:** Tests verify behavior through public interfaces,
not implementation details. Code can change; tests should not.

**Good tests** execute real code paths through public APIs. They describe
_what_ the system does, not _how_ it does it. A good test reads like a
specification, "user can checkout with valid cart" tells you exactly what
capability exists. These tests survive refactors because they don't care
about internal structure.

**Bad tests** are coupled to implementation. They mock internals, test private
methods, or verify through external means (like querying a database directly
instead of using the interface). The warning sign: your test breaks when you
refactor, but behavior hasn't changed.

**Mocking:** Mock only at system boundaries.

## Anti-Pattern: Horizontal Slices

**Do not write all tests first, then all implementation.** This causes
speculative test just to fill a quote and its correlated to bad quality.

Correct approach: Vertical slices. One test → one implementation → repeat.
Each test builds on the learnings of the previous cycle. This help you refine
what behavior matters.

So is not really RED, GREEN, REFACTOR.
It's RED, GREEN, [RED, GREEN, ...], REFACTOR.

## Workflow

### RED:

1. Write one test that confirms one thing about the system.
2. Run it and confirm it fails.
3. Evidence the RED step: RED test are your spec, commit it if not in main repo
   (you should be in a feature branch in most cases), otherwise just report
   it to the user.

### GREEN:

4. Make minimal changes to make the test pass.
5. Do not refactor yet, go back to RED and add more tests with your new
   knowledge.

### REFACTOR:

6. When 90% coverage, look for refactor candidates.
7. Tests written in the RED phase are specs, so they must not change unless
   you document to the user the justification.
