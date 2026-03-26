---
name: sprint-review
description: |
  Review and verify completed sprint tasks, validate production quality.
  Use when sprint execution is done and you need to verify the work.
---

Trigger phrases: "review", "verify", "done", "complete", "sprint done",
"check work", "validate", "QA", "acceptance"

## Philosophy

Verify, dont trust. Goal is prod-grade quality - no shortcuts, no mocked data.

## Workflow

### 1. Gather Sprint Outputs

- What was delivered (features, fixes, refactors)
- Branch names created (feature/*, hotfix/*)
- Test results and coverage reports
- Documentation changes

### 2. Verify Each Task

For each PBI/ticket completed:

**Functional:**
- Feature works as specified in the issue
- User completes core workflow
- Edge cases handled
- No console errors or crashes

**Technical:**
- Tests pass (run them, dont check CI status only)
- Coverage meets threshold
- No lint errors
- Types pass (if applicable)
- No hardcoded secrets or debug code

**Code Quality:**
- Follows coding-style
- No TODO/FIXME left behind
- Error handling is explicit
- Functions do one thing

### 3. Production Readiness

```
Environment:
- Config via env vars, not hardcoded
- Secrets not committed
- Logs dont leak sensitive data

Security:
- Input validation
- No SQL injection vectors
- Auth correct

Performance:
- No obvious N+1 queries
- No blocking in hot paths

Observability:
- Errors logged with context
- Key metrics tracked
```

### 4. No Mocked Data

Critical: Verify against REAL data.

- API calls to real services (or mocked at boundary)
- Database queries actually work
- Integration tests run against real components

If tests use mocks:
- Mock boundaries at system interfaces
- Mocks injected, not hardcoded
- Integration tests exist for the real thing

### 5. Report

**Completed**
- List of PBIs verified and working

**Issues**
- Each issue with severity (blocker/high/medium/low)
- What needs fixing before merge

**Recommendations**
- Improvements for future sprints
- Technical debt to track

### 6. Merge Decision

Green: All blockers resolved - approve merge
Red: Blockers present - request fixes before merge
Yellow: Medium issues - merge with follow-up ticket

## Agent Behavior

Be strict: Production means production
Dont accept "it works" - verify it
If tests missing - blocker
If code has obvious bugs - blocker
Document what you checked