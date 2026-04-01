# User flow specification

Mermaid diagram with conventions to express enforzable UX decisions.
By having a single source of truth, we turn emergent implementation
bad UX side effects into conscious actionable decisions

## DSL

- `[ ]` → action or system step
- `{ }` → decision
- `-->` → transition
- `|label|` → branch condition
- One node = one action
- Use `Click ...`, `Enter ...`, etc. for user actions
- Count "Click", etc. occurrences to measure UX cost

## Examples

### Good ux design

```mermaid
flowchart TD

  A[Start] --> B[Enter email and password]
  B --> C[Click Login]
  C --> D{Credentials valid}

  D -->|yes| E[Dashboard]
  D -->|no| F[Show error]

  E --> G[End]
  F --> B
```

- 1 click
- minimal steps
- fast retry loop

### Bad ux design evidenced

```mermaid
flowchart TD

  A[Start] --> B[Click Login]
  B --> C[Enter email]
  C --> D[Click Next]
  D --> E[Enter password]
  E --> F[Click Login]
  F --> G{Credentials valid}

  G -->|yes| H[Dashboard]
  G -->|no| I[Show error]

  H --> J[End]
  I --> C
```

- multiple clicks
- unnecessary steps
- fragmented flow
