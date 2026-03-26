---
name: module-design
description: |
  Design module interfaces, APIs, data structures, architecture patterns.
  Use when user wants to design something new, create an API, define
  interfaces, or explore architecture options.
---

Trigger phrases: "design", "API", "interface", "architecture", "module",
"how should we structure", "what interface", "data model"

## Philosophy

Ousterhout's "Design It Twice": your first idea is unlikely to be the best.
Generate multiple radically different designs, then compare.

## Workflow

### 1. Gather Requirements

Before designing, understand:

- What problem does this module solve?
- Who are the callers?
- What are the key operations?
- Any constraints? (performance, compatibility, existing patterns).
- What should be hidden inside vs exposed?

### 2. Generate Designs

Spawn 3+ sub-agents simultaneously. Each must produce a radically different
approach.

```
Prompt template for each sub-agent:

Design an module for: [module description]

Requirements: [gathered requirements]

Constraints for this design: [assign a different constraint to each agent]
- Agent 1: "Minimize method count - aim for 1-3 methods max"
- Agent 2: "Maximize flexibility - support many use cases"
- Agent 3: "Optimize for the most common case"
- Agent 4: "Take inspiration from [specific paradigm/library]"

Output format:
1. Interface signature (types/methods)
2. Usage example (how caller uses it)
3. What this design hides internally
4. Trade-offs of this approach
```

### 3. Present Designs

Show each design with:

1. **Interface signature** - types, methods, params
2. **Usage examples** - how callers actually use it in practice
3. **What it hides** - complexity kept internal

Present designs sequentially so user can absorb each approach before
comparison.

### 4. Compare Designs

After showing all designs, compare them on:

- **Interface simplicity**: fewer methods, simpler params.
- **General-purpose vs specialized**: flexibility vs focus.
- **Implementation efficiency**: does shape allow efficient internals?
- **Depth**: small interface hiding significant complexity (good) vs large
  interface with thin implementation (bad).
- **Ease of correct use** vs **ease of misuse**.

Discuss trade-offs in prose, not tables. Highlight where designs diverge most.

### 5. Synthesize

Often the best design combines insights from multiple options. Ask:

- "Which design best fits your primary use case?"
- "Any elements from other designs worth incorporating?"

## Anti-Patterns

- Don't let sub-agents produce similar designs - enforce radical difference.
- Don't skip comparison - the value is in contrast.
- Don't implement - this is purely about interface shape.
- Don't evaluate based on implementation effort.
