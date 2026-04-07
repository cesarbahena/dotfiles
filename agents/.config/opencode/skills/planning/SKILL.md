---
name: planning
description: Plans product development by analyzing requirements and creating SDLD specs. Use when starting new feature, epic, or product initiative. Creates Feature, Use Case, Acceptance, Invariant, Entity, State Machine, and NFR specs.
---

Analyzes requirements and creates specs using SDLD framework

## 1. Analyze requirements

Understand product, users, and problem.

If user provides sufficient context (goal + at least one of: users, problem, success criteria), proceed.

If minimal input, ask user clarifying questions:
- What are you building?
- Who are the users?
- What problem does this solve?
- What are the constraints?

## 2. Identify entities

What domain objects exist?

Create entity specs using assets/templates/entity.md

ID format: ENT-{DOMAIN}-{NNN}

## 3. Define flows

How do users interact with system?

Create use case specs using assets/templates/use_case.md

ID format: UC-{DOMAIN}-{NNN}

Include feature reference in frontmatter.

## 4. Identify rules

What must always be true?

Create invariant specs using assets/templates/invariant.md

ID format: INV-{DOMAIN}-{NNN}

## 5. Define states

What are valid states and transitions?

Create state machine specs using assets/templates/state_machine.md

ID format: SM-{DOMAIN}-{NNN}

## 6. Define constraints

What are non-functional requirements?

Create NFR specs using assets/templates/nfr.md

ID format: NFR-{DOMAIN}-{NNN}

## 7. Document decisions

Why were certain choices made?

Create ADR specs using assets/templates/adr.md

Save to docs/adr/, not docs/specs/

## 8. Create acceptance specs

Define executable tests for each use case.

Create acceptance specs using assets/templates/acceptance.md

ID format: ACC-{UC}-{NNN}

Use Gherkin: Feature, Scenario, Given, When, Then

## 9. Write specs

Save all specs to docs/specs/

Save ADRs to docs/adr/

Ensure correct frontmatter:
```yaml
---
id: {TYPE}-{DOMAIN}-{NNN}
type: {feature|use_case|acceptance|invariant|entity|state_machine|nfr}
status: draft | active
last_verified_at: YYYY-MM-DD
---
```

Use correct body sections from templates.

Ensure cross-references between specs.
