---
description: |
  USE to create or edit authoritative spec artifacts
  WHEN designing new feature
  OR refining an existing one
---

## INPUT

Understand the product

### READ

#### System specs

DEFAULT `system/<spec>`
OR some global folder

- `nfr.yml`
- `principle.yml`
- `scope.yml`
- `architecture.dsl`
- `adr/*`

#### Current domain spec

IF new domain THEN skip

DEFAULT `<domain>/domain/model.yml`
OR any folder IF prepended `<domain>.model.yml`

#### Current feature specs

IF new feature THEN skip

DEFAULT `<domain>/application/<feature>/<spec>`
OR any folder if prepended by feature-name `<feature>.<spec>`

- `intent.yml`
- `acceptance.feature`
- `flow.mmd`
- `layout.json`

### INTERVIEW

IF can be answered by exploring the code THEN skip

WHILE ambiguity OR decision tree unsolved
DO use your question tool to ask high-value questions
AND explore codebase to verify
CATCH user's wrong asumptions THEN explain
USE your `yagni` skill to debate

## OUTPUT

IF requires new or modified domain
THEN use your `domain-modeling` skill

IF new feature for existing domain THEN
MKDIR feature folder DEFAULT `<domain>/application/`

RETURN `intent.yml`, `acceptance.feature`, `flow.mmd`
AND `layout.json` IF feature with UI

## STEPS

1. Consider all your inputs (global system specs and current feature
   and domain specs, user answers, codebase)
2. Use the guides to understand each
3. Write the specs using the feature and domain templates
4. Template's fields are used for product documents autogeneration, if you
   consider a new field adds value, debate it, feedback is appreciated
5. Do not force fields, just report to the user it is not needed for the
   use case

## RULES

- Your job is to refine the specs, not to implement the solution

## VERIFY

- All specs must respect the product requirements

## FALLBACK

This skill is a WIP, feedback is appreciated
