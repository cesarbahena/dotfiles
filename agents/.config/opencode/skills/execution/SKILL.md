---
name: execution
description: Manages post-release phase. Deprecates specs, creates migration paths, archives features. Use when decommissioning features or planning migrations.
---

Manages post-release spec lifecycle and migrations

## 1. Identify specs to deprecate

Read specs marked for deprecation or superseded.

## 2. Assess impact

What depends on these specs?
- Which use cases reference them?
- Which entities are affected?
- Which features include them?

## 3. Create migration path

Document how to move from old to new:
- Step-by-step migration process
- Rollback procedure
- Timeline

## 4. Update specs

Add deprecation to frontmatter:
```yaml
deprecated:
  reason: Why deprecated
  timeline: Migration deadline
  migration_path: How to migrate
  superseded_by: New spec ID
```

Change status to deprecated.

## 5. Create new specs

If new system replacing old:
- Create new Feature, Entity, etc specs
- Link from deprecated specs using superseded_by

## 6. Archive issues

Close or archive GitHub issues for deprecated features.

## 7. Save updates

Write all modified specs to docs/specs/
