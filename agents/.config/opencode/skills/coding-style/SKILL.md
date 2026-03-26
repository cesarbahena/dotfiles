---
name: coding-style
description: Enforce consistent coding style through linting, formatting, and conventions.
---

## When to use me

When writing, reviewing, or refactoring code. Always active during code generation tasks.

## What do I do

### Philosophy

**Clarity over cleverness.** Write code for the next human who reads it, not to demonstrate intelligence. The best code is obvious.

**Consistency > "best" practice.** A codebase with consistent style is more readable than one mixing "better" but inconsistent approaches.

**Local conventions trump global rules.** Follow the existing patterns in the codebase, even if you'd do it differently elsewhere.

### Naming

**Variables & Functions:** Use descriptive names that reveal intent.

```
# Bad
d = 30
def proc(x):

# Good
days_since_creation = 30
def process_user_request(x):
```

**Booleans:** Use prefixes like `is_`, `has_`, `should_`, `can_`.

```
# Bad
active = True
items = []

# Good
is_active = True
items = []  # already plural, clear it's a collection
```

**Constants:** SCREAMING_SNAKE_CASE for true constants, camelCase for config keys.

**Avoid:**
- Single letters except: loop counters (`i`, `j`), coordinates (`x`, `y`), math (`n`)
- Abbreviations unless universally known (id, ok, url, api)
- Hungarian notation (strName, nCount)

### Functions

**Do one thing.** If you need "and" to describe what it does, split it.

**Small is beautiful.** Aim for < 20 lines. Hard limit: 50.

**Parameters:** Max 3. Use objects/options dict for more.

**Side effects:** Make them explicit. A function returning data shouldn't also mutate global state silently.

### Structure

**Declaration order:** Constants → Types → Interfaces → Functions → Main logic

**Group related code.** Logical sections should be visually separated (blank lines, comments).

**Indentation:** One style per file. Match existing.

### Comments

**Why, not what.** Code shows what; comments explain why it can't be obvious.

```
# Bad
# Increment counter
counter += 1

# Good
# Compensate for off-by-one in the legacy API
counter += 1
```

**Document public APIs.** Every exported function needs a docstring explaining:
- What it does
- Parameters and their types
- Return value
- Side effects
- Exceptions

**Never leave commented-out code.** Use version control.

### Error Handling

**Fail fast with clear messages.** Don't silently swallow errors.

```
# Bad
try:
    do_something()
except:
    pass

# Good
try:
    do_something()
except ValueError as e:
    raise ConfigurationError(f"Invalid value: {e}") from e
```

**Prefer exceptions over return codes.** They're more explicit and don't clutter control flow.

### Dependencies

**Depend on abstractions, not concretions.** Use interfaces/types to decouple.

**Explicit is better than implicit.** Import what you use, don't rely on globals.

### Code Review Checklist

- [ ] Names are descriptive
- [ ] Functions do one thing
- [ ] No magic numbers (use named constants)
- [ ] Error handling is explicit
- [ ] No commented-out code
- [ ] Tests cover the happy path and edge cases
- [ ] No hardcoded secrets
- [ ] Code matches project conventions

## Workflow

1. **Check existing patterns** before writing new code
2. **Run linters/formatters** before committing (eslint, rustfmt, black, etc.)
3. **Self-review** using the checklist above
4. **Fix issues** before presenting code for review
