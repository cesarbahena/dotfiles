Spec-Driven Development Framework (v1)
Philosophy

This system defines a spec-driven development framework where:

Specs are the single source of truth
Code is an implementation of specs
Issues are execution artifacts
Specs are optimized for human discoverability first, RAG later

Core principle:

Specs define truth. Issues define work. Code implements both.

Design Principles
Separation of concerns
Product intent ≠ behavior ≠ execution ≠ correctness
No duplication of domain truth
Entities, invariants, and state machines are global
Colocation for behavior
Feature-related specs live together
Architecture-agnostic
Works with clean architecture, vertical slices, or spaghetti
Human-first design
If humans can’t navigate it, RAG won’t help
Folder Structure

/docs
README.md ← ENTRY POINT
/specs ← SYSTEM TRUTH
/adr ← DECISIONS (RAG-READY)
/diagrams ← VISUAL CONTEXT

Navigation Principle

The README is the experience layer.

It should guide users to:

features
ADRs
diagrams
specific specs

Folders alone are not enough for discoverability.

Spec Types (Located in /docs/specs)

1. Feature (REQUIRED)

Purpose:
Defines product intent and boundaries.

Lifecycle:

Created: Planning
Updated: Rarely
Long-lived

Required Frontmatter:
id: FEAT-XXX
type: feature
status: draft | active | deprecated
last_verified_at: YYYY-MM-DD

Body:

Goal
Context
Success Signals
Metrics
Tradeoffs
Non-Goals
Risks
Assumptions
Open Questions 2. Use Case (REQUIRED)

Purpose:
Defines system behavior and flows.

Lifecycle:

Created: Planning
Updated: Frequently during development

Required Frontmatter:
id: UC-XXX
type: use_case
feature: FEAT-XXX
status: draft | active
last_verified_at: YYYY-MM-DD

Body:

Goal
Preconditions
Main Flow
Alternative Flows
Postconditions
Notes 3. Acceptance Spec (REQUIRED)

Purpose:
Defines executable behavior (tests).

Lifecycle:

Created: Planning or early development
Updated: Very frequently

Frontmatter:
id: ACC-XXX
type: acceptance
use_case: UC-XXX
status: active
last_verified_at: YYYY-MM-DD

Body (Gherkin inside Markdown):
Feature: …

Scenario: …
Given …
When …
Then …

4. Invariant (REQUIRED)

Purpose:
Defines rules that must never be broken.

Lifecycle:

Created: Planning + discovered during development
Updated: Occasionally

Frontmatter:
id: INV-XXX
type: invariant
status: active
last_verified_at: YYYY-MM-DD

Body:

Rule
Why
Examples
Enforcement
Related 5. Entity (REQUIRED)

Purpose:
Defines domain objects.

Lifecycle:

Created: Planning
Updated: Occasionally

Frontmatter:
id: ENT-XXX
type: entity
status: active
last_verified_at: YYYY-MM-DD
state_machines:

SM-XXX

Body:

Description
Fields
Behaviors
Lifecycle
Relationships
Constraints
Events 6. State Machine (REQUIRED)

Purpose:
Defines valid state transitions.

Lifecycle:

Created: Planning
Updated: Rarely

Frontmatter:
id: SM-XXX
type: state_machine
status: active
last_verified_at: YYYY-MM-DD

Body:

States
Transitions
Invalid Transitions 7. NFR (REQUIRED)

Purpose:
Defines cross-cutting system constraints.

Lifecycle:

Created: Planning
Updated: Rarely

Frontmatter:
id: NFR-XXX
type: nfr
status: active
last_verified_at: YYYY-MM-DD

Body:

Definition
Why it matters
Measurement
Notes
ADR (Architectural Decision Records)

Location:
/docs/adr

Purpose:
Explain WHY decisions were made.

Key Insight:

Specs define what the system is
ADRs define why the system is that way

Important:

ADRs are NOT part of the system truth
They are decision history
They should be indexed for RAG
They must be linked from specs

Example usage inside specs:
related_adr:

ADR-001
Lifecycle Summary

Planning Phase:

Feature
Use Cases
Entities
Core Invariants
State Machines
NFRs

Development Phase:

Acceptance specs (frequently updated)
Use cases refined
New invariants discovered

Post-Release:

Specs verified
Invariants refined
Metrics adjusted
Execution Layer (External)

Use GitHub Issues (or similar tools).

Example:
[FEAT-PAY-001] Implement payment capture

Refs:

UC-PAY-001
INV-PAY-001
Core Flow

Feature → Use Case → Acceptance → Code
↓
Invariants

Key Principle

Put everything under /docs, but make /specs the gravitational center.

/docs = entry point + navigation
/specs = system truth
/adr = decision history
/diagrams = visualization
Final Insight

Navigation is designed by README, not by folders.

Folders store information.
README creates discovery.

Specs remain the backbone of the system.
