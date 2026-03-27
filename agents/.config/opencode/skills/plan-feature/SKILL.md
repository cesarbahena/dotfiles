---
name: plan-feature
description: |
  Create or refine a feature acceptance spec from an issue.
  Use when planing any code changes that are not hotfixes.
---

# Skill: plan-feature

## Goal

Produce a complete, unambiguous `<feature-name>.acceptance.feature`.

## Steps

1. Fetch issue
2. Resolve linked `<feature-name>.acceptance.feature`

3. If not found:
   - Search repo for matching feature name
   - If found → reuse
   - If not found → enter discovery loop

4. Discovery loop:
   - Ask high-value, disambiguating questions
   - Focus on:
     - inputs
     - outputs
     - edge cases
     - failure modes
   - Continue until ALL branches are testable and unambiguous

5. Create `<feature-name>.acceptance.feature` using Gherkin

6. STOP
   - Wait for implicit or explicit approval

7. Transition to `implement-feature`

## Exit Condition

All scenarios are deterministic, testable, and complete.
