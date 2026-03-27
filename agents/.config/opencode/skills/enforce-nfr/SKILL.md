---
name: enforce-nfr
description: |
  Validate that system changes comply with non-functional requirements.
  Use when a subagent claims to have completed a feature implementation.
---

## Goal

Ensure that implemented changes comply with all non-functional requirements.

## Steps

### 1. LOAD CONTEXT

- Read `system/nfr.yaml`
- Identify impacted components from diff
- Identify related features and tests

---

### 2. CLASSIFY NFRs

Evaluate:

- performance
- security
- reliability
- scalability
- maintainability

---

### 3. EVALUATE

#### PERFORMANCE

- Detect inefficient loops
- Check repeated DB/API calls
- Validate response time expectations

#### SECURITY

- Validate auth presence
- Check input validation
- Detect sensitive data exposure
- Detect injection risks

#### RELIABILITY

- Ensure error handling
- Validate retries/fallbacks
- Detect silent failures

#### SCALABILITY

- Detect unbounded operations
- Detect blocking/synchronous bottlenecks

#### MAINTAINABILITY

- Function length exceeds limits
- File size too large
- High cyclomatic complexity
- Code duplication
- Poor naming (generic identifiers)
- Violations of layering
- God objects
- Missing tests per behavior
- Redundant or missing critical comments

---

### 4. CROSS-CHECK WITH SPEC

- Ensure alignment with `<feature-name>.acceptance.feature`
- Ensure tests reflect expected behavior

---

### 5. DETECT VIOLATIONS

- Classify:
  - critical
  - warning

---

### 6. ENFORCE

If violations exist:

- For behavior-impacting issues:
  → spawn `fix-bug` or `implement-feature`

- For maintainability issues:
  → spawn `refactor-safe`

---

### 7. VERIFY

- Re-run tests
- Re-check NFR compliance

---

## Exit Condition

- All critical NFRs satisfied
- No unresolved violations
- System behavior unchanged unless explicitly intended
