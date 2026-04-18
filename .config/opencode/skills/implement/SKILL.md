---
name: implement
description: Pick up the implementation plan and start working on it
license: MIT
compatibility: opencode
user-invocable: true
---


# Implement

You start the implementation phase based on a implementation document.

## Input

$ARGUMENTS

## Load Skills

- `start-ticket`
- `create-merge-request`

## Steps to follow

### Step 1: Read the implementation plan

- Check the path: `.claude/output/research/[jira-id].md` file.
- If the file doesn't exist, ask user to research first using the `/research` command.
- Check and read path `.claude/output/implementation_progress/[jira-id].md` to check previous implementation progress.

### Step 2: Create ToDos

- Create tasks/tools using TaskCreate/ToolWrite tool for each phase of implementation.
- Phase 0 should be setting up the project for implementation. Use the `start-ticket` skill to implement phase 0.
- Write a file called `.claude/output/implementation_progress/[jira-id].md` to track the implementation progress.
- This file should include all the phases in a table with current status being updated by the agents which pickup the phase for implementation.

**CRITICAL**: Use Subagents to execute each Task.

### Step 3: How to execute phase

- Use the `full-stack-engineer` agent (subagent_type: `full-stack-engineer`) to do the implementation.
- Find relevant files and methods using LSP tool. If LSP is not available fallback to `Glob` and `Grep`.
- After each phase, claude should create commits and update the tests cases.
- Do not move to next phase if the tests from current phase fail. Let user know and work with user to fix.
- Do not remove the existing test cases just because they keep failing.

### Step 4: Create Merge Request

**Prerequisites:** All phases complete, tests passing, changes committed.

Follow the `create-merge-request` skill exactly. Return the MR URL to the user when done.


**CRITICAL**: If you find conflicting information between implementation plan and actual code, alert user and stop the implementation phase unless user provides permission. Work with user to clear this conflict before moving forward.

## Anti-Patterns to Avoid

- Moving to next phase when current phase tests are failing
- Removing existing test cases to make tests pass
- Generating MR description manually instead of using project's MR template
- Modifying MR template content outside `<!-- ai-only-start/end -->` markers
- Continuing implementation when plan conflicts with actual code without user confirmation
- Running all phases in a single context instead of using subagents
