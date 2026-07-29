---
name: present-technical-findings
description: Turn technical exploration, repository findings, architecture decisions, incident analysis, or project research into a clear meeting-ready artifact. Use when the user needs to explain findings to a manager or team, prepare speaking notes, create an executive one-pager, decision brief, status update, architecture summary, anticipated Q&A, or presentation outline, especially when the raw thinking is detailed, nonlinear, or needs concise professional English.
---

# Present Technical Findings

Convert raw technical material into an artifact the user can present confidently. Preserve the user's technical judgment while removing conversational round trips and unnecessary implementation detail.

## Workflow

1. Determine the audience, meeting purpose, available speaking time, and requested artifact. Infer reasonable defaults instead of blocking when these are missing.
2. Gather evidence from the current conversation and any files, repositories, links, or notes in scope. Inspect sources when claims need verification.
3. Classify the material internally as:
   - verified finding;
   - inference;
   - recommendation;
   - unresolved question.
4. Identify the single conclusion the audience should remember.
5. Select the smallest artifact that serves the meeting.
6. Draft in natural spoken language, then verify that every material claim is supported and every uncertainty is labeled.

Default to a meeting brief for a manager, designed for a 60-second explanation, when the user does not specify an audience, duration, or format.

## Choose the Artifact

- **Meeting brief:** Default for an imminent meeting or a request to explain findings.
- **Speaking notes:** Use when the user wants help presenting verbally.
- **Executive one-pager:** Use for asynchronous review or a durable summary.
- **Decision brief:** Use when approval or a choice is required.
- **Architecture summary:** Use when ownership boundaries, components, or request flow are central.
- **Q&A sheet:** Use when the audience is likely to challenge feasibility, security, cost, ownership, or deployment.
- **Slide deck or document:** Create only when explicitly requested. Use the available presentation or document skill and follow its artifact-validation workflow.

Do not create a slide deck merely because the content has several points.

## Default Meeting Brief

Produce these sections:

1. **Headline:** One sentence containing the conclusion.
2. **What we found:** Up to three evidence-backed findings.
3. **What we recommend:** One proposed direction and why.
4. **Responsibility boundary:** State who or what owns each major part.
5. **What remains open:** Up to three questions requiring confirmation or a decision.
6. **Suggested script:** A natural 45–75 second spoken explanation.
7. **Likely questions:** Three concise answers to the most probable audience questions.

If the meeting is already happening, put the suggested script first and keep the entire response immediately scannable.

## Communication Rules

- Lead with the conclusion, not the investigation history.
- Use one idea per sentence and short paragraphs.
- Prefer concrete ownership language: "Our service owns scheduling; the platform owns reasoning."
- Distinguish current scope from future direction.
- Present one recommendation before discussing alternatives.
- Preserve necessary technical terms, but define unfamiliar acronyms once.
- Avoid filler, defensive language, and apologies about fluency.
- Make the script sound spoken rather than like formal documentation.
- Preserve the user's voice; improve grammar without making the language unnaturally ornate.
- Never invent certainty. Say "we found," "we recommend," or "we still need to confirm" according to the evidence.
- Include implementation detail only when it supports a decision or answers a likely objection.

## Evidence and Accuracy

Link to source files or authoritative references when useful in a written artifact. Do not clutter a spoken script with paths or citations. Move detailed evidence beneath the main brief or into an appendix.

When repository evidence conflicts with an intended design, state both clearly. When authorization, production support, ownership, or security behavior is not proven, treat it as an open question rather than an assumption.

## Useful User Requests

- "Use $present-technical-findings to prepare a one-minute update for my boss."
- "Turn what we found in this repository into a meeting brief and likely Q&A."
- "Create a decision memo comparing the scheduled-job and chatbot approaches."
- "Make speaking notes from these findings. Keep my voice, but improve the English."
- "Create a five-slide executive deck from this architecture review."
