---
name: development
description: Implements features during development phase. Creates acceptance specs, updates existing specs, and links specs to implementation. Use when actively building features or writing tests.
---

Implements features by creating acceptance criteria and updating SDLD specs

## 1. Get existing specs

Read relevant specs from docs/specs/:
- Feature spec for context
- Use cases for flows
- Entities for data model

## 2. Create acceptance specs

Define executable tests for each use case.

Use assets/templates/acceptance.md:
- Gherkin format: Feature, Scenario, Given, When, Then
- Cover happy path and alternatives
- Reference use_case in frontmatter

ID format: ACC-{UC}-{NNN}

Save to docs/specs/

## 3. Update use cases

Refine use case specs based on implementation:
- Add discovered edge cases
- Update postconditions if needed
- Note any scope changes

## 4. Update entities

Add implementation details to entity specs:
- Field types
- Validation rules
- API representations

## 5. Create issues

Generate GitHub issues for implementation tasks.

Reference spec IDs in each issue.

Format: [FEAT-XXX] description

## 6. Link specs

Ensure all specs reference each other:
- Use cases → entities (related_entity)
- Acceptance → use cases (related_use_case)
- Feature → use cases (related_use_case)

## 7. Save updates

Write all modified specs to docs/specs/

Update status where appropriate.
