---
name: tdd
description: |
  Use to make any code changes
---

## RED

- Write a single failing test
- Assert a single atomic behavior
- Verify it does not pass

## GREEN

- Implement minimal code to pass
- Verify it passes

## LEARN

- Review your theory vs practice
- Consider if the theory was correct

## REPEAT

- Use your knowlegde to write a single other test
- Repeat until 90%+ coverage

## FREEZE TESTS

- Freeze the tests - they are immutable now
- Refactoring tests at this stage requires aproval
- For trivial obious mistakes parent agent can aprove
- Everything else requires user aproval

## REFACTOR

- Improve structure without changing behavior
- Strive for best practices and codebase conventions
