---
name: research
description: To research about given jira and understand required code context.
license: MIT
compatibility: opencode
user-invocable: true
---


# Research

User will invoke this command to initiate the AI flow to understand what needs to be done for this task.

## Input

$ARGUMENTS

## CRITICAL

- Step 3 is pattern matching only - identify which skill applies.
- Step 4 should happen in a Plan subagent that invokes matched skills via the Skill tool.

## Step 1: Parse input

- Jira ID is provided in $ARGUMENTS

## Step 2: Enrich Jira context

Delegate ALL JIRA fetching to the `jira-context-fetcher` agent using the Task tool:
- `subagent_type`: `jira-context-fetcher`
- Pass the JIRA ticket ID from Step 1
- The agent will return structured markdown with: description, acceptance criteria, parent/epic hierarchy, linked issues, and associated MRs
- Do NOT fetch JIRA data separately - the context fetcher is the single source for all JIRA context

Once the context fetcher returns:
- Summarize the ticket to the user
- Extract the **Epic ID** from the parent/epic hierarchy (if present)
- Extract component field:
  - Component is most likely the repository name
  - In some cases, it can be an abbreviation (e.g., NPC = non-property-content)
- Note any linked issue context relevant for implementation (especially "blocked by" or "depends on")
- Note associated MR links that may contain related code changes or implementation patterns
- **Epic context**: Check the `Epic Context` section in the agent's output. If present, tell the user epic context is loaded for the Epic ID and use it throughout codebase exploration. If it says no context was found, tell the user. If no Epic ID on ticket, skip silently.

## Step 3: Pre-determined steps for Jiras

| Jira Type | Detection Pattern | Skill to Use | Purpose |
|-----------|------------------|--------------|---------|
| A/B Experiment Integration | Title contains "Integrate ACT-XXXX" or "De-Integrate ACT-XXXX" | `experiment-integration-planner` | Plan integration or de-integration and identify code changes |
| Experiment Setup | Description mentions experiment setup | `add-experiment` | Use as initial step to set up experiment, then continue with story planning |

## Step 4: Codebase exploration

Launch a Plan subagent for this step. The Plan subagent must:

- If a skill was matched in step 3, invoke it using the Skill tool first. Do NOT summarize or paraphrase the skill content into the subagent prompt - the subagent must call the skill directly.
- Find relevant files and methods using LSP tool. If LSP is not available fallback to `Glob` and `Grep`.
- Read and understand current implementation
- Identify modification points with `file:line` references
- Flag cleanup items in files being modified (only if related to this task):
  - Mock data or stubs that this implementation should replace
  - Hardcoded values that conflict with new requirements
  - TODO/FIXME comments that this task addresses

## Step 5: Interview User

- Gather ALL clarifying questions from research before asking any
- Only ask questions that cannot be answered from context
- Use `AskUserQuestion` tool (max 4 questions per call)
- If an answer triggers need for more research, do that research in a subagent first, then batch any new questions together
- Wait for all answers before proceeding to Step 6

## Step 6: Verify Understanding

Before writing the plan, present a brief summary to user:
- Problem statement (2-3 sentences)
- Technical approach (1-2 sentences)
- Key files to modify (list)
- Dependencies or blockers (if any)

Ask user to confirm understanding is correct before proceeding.

## Step 7: Create Plan

**CRITICAL**: Only write plan when all questions answered AND understanding verified.

Ask user where to write the plan using `AskUserQuestion`:
1. Repository root: `<repo-root>/.claude/output/research/<jira-id>.md`
2. Current directory: `<cwd>/.claude/output/research/<jira-id>.md`
3. User specified path

Requirements:
- Must be self-contained with all context for another Claude session to implement
- Include code examples where needed for clarity
- Avoid unnecessary prose - focus on actionable details

**Output format**:

```markdown
---
ticket: ACT-XXXX (omit if not present)
epic: ACT-YYYY (omit if not present)
repository: activities (omit if not present)
local-repo-path: ~/projects/activities (list of projects, omit if not present)
task-type: spike/implementation/integration
dependencies: ACT-ZZZZ, ACT-AAAA (tickets this blocks or is blocked by, omit if none)
author: Claude
---

# [Task name] Implementation Plan

## Overview

[Brief description of what we're implementing and why]

## Acceptance Criteria Mapping

| AC # | Criteria | Phase | Verification |
|------|----------|-------|--------------|
| AC1 | [Copy from Jira] | Phase 1 | [How to verify] |
| AC2 | [Copy from Jira] | Phase 2 | [How to verify] |

## Current State Analysis

[What exists now, what's missing, key constraints discovered]

### Key Discoveries
- [Important finding with file:line reference]
- [Pattern to follow]
- [Constraint to work within]

## Desired End State

[A specification of the desired end state after this plan is complete, and how to verify it]

## What We're NOT Doing

[Explicitly list out-of-scope items to prevent scope creep]

## Implementation Approach

[High-level strategy and reasoning]

---

## Phase 1: [Descriptive Name]

### Overview
[What this phase accomplishes and which ACs it addresses]

### Files to Create

| File | Purpose |
|------|---------|
| `path/to/new-file.ext` | [Why this file is needed] |

### Files to Modify

#### 1. `path/to/existing-file.ext`

**Purpose**: [What this file does currently]
**Changes**: [Summary of modifications]

**Before**:
```[language]
// Existing code that will be changed
```

**After**:
```[language]
// New code after modification
```

### Success Criteria

**Automated**:
- [ ] [Repo-specific build command]
- [ ] [Repo-specific test command]
- [ ] [Repo-specific lint command]

**Manual**:
- [ ] [Specific user action and expected result]
- [ ] [Edge case to verify]

**ACs Completed**: AC1, AC2

---

## Cleanup Checklist

Items in files touched by this implementation that should be cleaned:

- [ ] `path/to/file.ext:line` - [What needs cleanup and why it's related to this change]

> Only include items directly related to this task's requirements or in files being modified.

---

## Testing Strategy

### Unit Tests
- [ ] `path/to/test-file.test.ext` - [What it tests]
- [ ] [Key edge cases to cover]

### Integration Tests
- [ ] [End-to-end scenario]

### Manual Testing Steps
1. [Specific step with expected outcome]
2. [Another step with expected outcome]

## Performance Considerations

[Any performance implications or optimizations needed, or "None expected" if N/A]
```

## Step 8: Generate Testing Plan (Subagent)

After the research plan is saved, launch a subagent to generate a manual testing plan.

The subagent must:
- Invoke the `testing-plan` skill using the Skill tool
- Pass the JIRA ID so the skill can locate the research artifact created in Step 7
- Save the testing plan to `<same-root-as-step-7>/.claude/output/testing-plan/<jira-id>.md`

This runs as a subagent to isolate the testing plan generation context. Do NOT summarize or paraphrase the skill - the subagent must call it directly via `Skill`.

## Step 9: Gather Feedback

- Present plan summary and plan file path to user
- Ask user to verify the plan

## Anti-Patterns to Avoid

- Writing plan before all questions are answered
- Skipping the "Verify Understanding" step
- Not launching Plan subagent for Step 4.
- Not invoking skills that are mentioned in Step 3 in Step 4 subagent, for eg, for integration story, `experiment-integration-planner` didn't get invoked.
- Skipping Step 8 testing plan subagent - the testing plan must be generated after the research plan is saved.
- Inlining the testing plan logic instead of invoking the `testing-plan` skill via the Skill tool in the subagent.
- Fetching JIRA data directly instead of delegating to the `jira-context-fetcher` agent — all JIRA context must come from the agent, not from manual MCP tool calls.
- Mentioning "no epic context found" to the user when the ticket has no Epic (bugs, integrations, whitelabels) — this is expected, not an error. Skip silently.
