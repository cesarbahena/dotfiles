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

#### Domain spec

IF new domain THEN skip

DEFAULT `<domain>/domain/<domain>.yml`

#### Feature specs

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

output = `intent.yml`, `acceptance.feature`, `flow.mmd`
IF feature with ui THEN output += `layout.json`

IF new feature for existing domain THEN create feature folder
DEFAULT `<domain>/application/<artifact>`

IF new domain THEN create folders AND output += `<domain>.yml`
DEFAULT `<domain>/{domain,application,infrastructure,interface}`
IF modified domain THEN output += `<domain>.yml`

RETURN output

## STEPS

1. Consider all your inputs (global system specs and current feature
   and domain specs, user answers, codebase)
2. Write the specs using the feature and domain templates
3. Template's fields are used for product documents autogeneration, if you
   consider a new field adds value, debate it, feedback is appreciated
4. Do not force fields, just report to the user it is not needed for the
   use case

## RULES

- Your job is to refine artifacts, not to implement the solution

## VERIFY

- All specs must respect the product requirements

## FALLBACK

This skill is a WIP, feedback is appreciated
