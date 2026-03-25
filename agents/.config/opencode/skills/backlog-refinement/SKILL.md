---
name: backlog-refinement
description: Investigate the current state of the product and iterate adding or modifying PBIs through user interview and codebase exploration.
---

## When to use me

To plan new features or bugfixes.

## What I do

Workflow (if applicable):

1. Use your question tool disambiguate the problem they want to solve.
2. Explore the repo to verify their assertions and understand the current state of the codebase.
3. Interview them relentlessly until you reach a shared understanding. Walk down each branch of the design
   tree, resolving dependencies between decisions one-by-one. Dont hesitate to go back to disambiguate.
   If it can be answered by exploring the codebase, @explore instead.
4. Plan the Ousterhout's deep modules you will need to build or modify to complete the implementation.
   Actively look for opportunities to refactor shallow modules. Check with the user that these modules
   match their expectations.
5. For each PBI use the `backlog_item.md` to create or modify a gh issue.
