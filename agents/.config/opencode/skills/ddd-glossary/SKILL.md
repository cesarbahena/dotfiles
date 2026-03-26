---
name: ddd-glossary
description: |
  Extracts a DDD glossary from the current conversation, flagging 
  ambiguities and proposing canonical terms. Use after a brainstorm session, 
  when desingning a new feature or at the minimum doubt of what a business 
  term means. Don't hesitate, DDD is always a priority.
---

Extract and formalize domain terminology from the current conversation into a
consistent glossary, saved to a local file.

## Process

1. **Scan the conversation** for domain-relevant nouns, verbs, and concepts.
2. **Identify problems**:
   - Same word used for different concepts (ambiguity).
   - Different words used for the same concept (synonyms).
   - Vague or overloaded terms.
   - Mixed language (always prefer English unless the whole codebase its in
     another language. Exception: names presentation in the UI is out of the
     scope of this.
3. **Propose a canonical glossary** with opinionated term choices
4. **Write to `glossary.md`** (in apropriate docs folder if exists, otherwise
   in working directory) using the format below.
5. **Output a summary** of changes inline in the conversation.

## Output Format

```md
# Ubiquitous Language

## Order lifecycle

| Term        | Definition                                              | Aliases to avoid      |
| ----------- | ------------------------------------------------------- | --------------------- |
| **Order**   | A customer's request to purchase one or more items      | Purchase, transaction |
| **Invoice** | A request for payment sent to a customer after delivery | Bill, payment request |

## People

| Term         | Definition                                  | Aliases to avoid       |
| ------------ | ------------------------------------------- | ---------------------- |
| **Customer** | A person or organization that places orders | Client, buyer, account |
| **User**     | An authentication identity in the system    | Login, account         |

## Relationships

- An **Invoice** belongs to exactly one **Customer**
- An **Order** produces one or more **Invoices**

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the **Invoice** immediately?"
> **Domain expert:** "No — an **Invoice** is only generated once a **Fulfillment** is confirmed. A single **Order** can produce multiple **Invoices** if items ship in separate **Shipments**."
> **Dev:** "So if a **Shipment** is cancelled before dispatch, no **Invoice** exists for it?"
> **Domain expert:** "Exactly. The **Invoice** lifecycle is tied to the **Fulfillment**, not the **Order**."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — these are distinct concepts: a **Customer** places orders, while a **User** is an authentication identity that may or may not represent a **Customer**.
```

## Rules

- Be opinionated: When multiple words exist for the same concept, pick the
  best one and list the others as aliases to avoid.
- Flag conflicts explicitly: If a term is used ambiguously in the
  conversation, call it out in the "Flagged ambiguities" section with a clear
  recommendation.
- Concise definitions: One sentence max. Define what it IS, not what it does.
- Show relationships: Use bold names and express cardinality where obvious.
- Only include domain terms: Skip generic programming concepts unless they have
  domain-specific meaning.
- Group terms into multiple tables when natural clusters emerge (subdomain,
  lifecycle, actor). Do not force groupings.
- Write an example dialogue: A short conversation (3-5 exchanges) between a dev
  and a domain expert that demonstrates how the terms interact naturally.
  The dialogue should clarify boundaries between related concepts and show
  terms being used precisely.
