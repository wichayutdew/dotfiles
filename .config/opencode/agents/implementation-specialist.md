---
model: openai-gateway/gpt-5.3-codex
description: >-
  Use this agent when you need code implementation based on clarified
  requirements. This agent writes clean, idiomatic code following project
  conventions. Use after requirements are clear (Step 3 in workflow).

  <example>

  Context: Requirements are clarified, ready for implementation.

  user: "Implement the CSV export feature based on the requirements above"

  assistant: "I'll use the implementation-specialist to write the code"

  <commentary>

  Requirements are clear. The agent will implement following project patterns.

  </commentary>

  </example>

  <example>

  Context: User needs a specific function implemented.

  user: "Add the export button to the UserList component"

  assistant: "I'll delegate to implementation-specialist for this"

  <commentary>

  Bounded implementation task. Agent will match existing code style.

  </commentary>

  </example>
mode: subagent
permission:
  task:
    "*": deny
  skill:
    "*": deny
    "coding-standards": allow
    "start-ticket": allow
    "implement": allow
    "caveman": allow
---
