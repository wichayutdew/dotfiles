---
name: jira-workflow
description: Quick reference for JIRA task workflow — steps, commands, and example session for end-to-end task delivery.
---

# JIRA Task Workflow

Load this skill when starting work on a JIRA task.

## Workflow Steps

1. **Requirements** → clarify scope, ACs, edge cases
2. **Architecture** *(optional)* → design discussion for non-trivial tasks
3. **Debug** *(bug tickets)* → find root cause before implementing
4. **Implement** → write the code
5. **Refine** *(human step)* → review and adjust
6. **Test** → write tests, verify passing
7. **Code Review** *(optional)* → quality and security check
8. **Quality Check** → lint + all tests green
9. **Document** *(optional)* → API docs, ADR, changelog
10. **Create MR** → commit, push, open MR

## Quick Commands

| What you want | Say |
|---------------|-----|
| Start a task | "Here's my JIRA task: PROJ-123 — [paste description]" |
| Architecture discussion | "Before implementing PROJ-123, let's discuss the approach" |
| Investigate a bug | "PROJ-456 has a NullPointerException in UserService" |
| Implement | "Implement PROJ-123 based on the requirements above" |
| Write tests | "Write tests for this implementation" |
| Quality check | "Run lint and tests" |
| Create MR | "Create MR for PROJ-123" |
| Update docs | "Update API docs and changelog for PROJ-123" |

## Example Session

```
You: Here's my JIRA task: PROJ-123 - Add CSV export for users
AI:  [Clarifies requirements, acceptance criteria, checklist]

You: Go ahead and implement it
AI:  [Writes the code]

You: [Reviews, adjusts manually]
You: Write tests
AI:  [Creates tests, runs them — all passing]

You: Run lint and tests
AI:  [Quality check — all green]

You: Create the MR
AI:  [Pushes, creates MR with description]
```
