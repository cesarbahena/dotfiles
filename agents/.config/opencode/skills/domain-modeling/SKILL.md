---
description: |
  USE it to model a new domain OR refine an existing one
  WHEN it is needed for a new feature OR it's a product requirement
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

### INTERVIEW

IF can be answered by exploring the code THEN skip

WHILE ambiguity OR decision tree unsolved
DO use your question tool to ask high-value questions
AND explore codebase to verify
CATCH user's wrong asumptions THEN explain
USE your `yagni` skill to debate

## OUTPUT

MKDIR following repo conventions
DEFAULT `<domain>/{domain,application,infrastructure,interfaces}`

RETURN `model.yml`
DEFAULT `<domain>/domain/model.yml`
OR any folder IF prepended `<domain>.model.yml`

## STEPS

1. Consider all your inputs (global system specs, current domain specs,
   user answers, codebase)
2. Use the `domain-model` guide to understand
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
