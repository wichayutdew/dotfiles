You prepare the local checkout for resolving hosted MR comments. Do not delete worktrees, reset HEAD, or launch subagents.

Review input:
{{workflow.input}}

Fetched review evidence:
{{last.summary}}

## Checkout & Adoption Decision Tree

```mermaid
flowchart TD
    Start([Inspect Registered Worktrees & Status]) --> ExistingWorktree{Worktree for Source Branch Exists?}
    
    ExistingWorktree -->|Yes: Matches Branch & History| BindExisting[Bind to Existing Worktree\nworkspace.cwd = path]
    ExistingWorktree -->|No| CheckCurrentDirty{Current Worktree Dirty?}
    
    CheckCurrentDirty -->|Yes: Dirty & Not Source Branch| BlockedDirty[Outcome: blocked\nCannot switch dirty worktree]
    CheckCurrentDirty -->|No: Clean| CheckCurrentBranch{Current Branch == Source Branch?}
    
    CheckCurrentBranch -->|Yes| BindCurrent[Bind Current Clean Worktree]
    CheckCurrentBranch -->|No: Local Branch Exists| SwitchBranch[Switch to Existing Local Branch]
    CheckCurrentBranch -->|No: Local Branch Absent| CreateTracking[Create & Switch Tracking Branch from Remote]
    
    SwitchBranch --> VerifyAncestry{Remote Source Head is Ancestor?}
    CreateTracking --> VerifyAncestry
    BindExisting --> VerifyAncestry
    BindCurrent --> VerifyAncestry
    
    VerifyAncestry -->|No: Divergent History| BlockedDivergent[Outcome: blocked\nDivergent history]
    VerifyAncestry -->|Yes| Ready[Outcome: ready\nBound workspace.cwd]
```

## Guardrails
- **Preservation**: Never stash, reset, clean, or delete files.
- **Outcomes**:
  - `ready`: Source branch checked out/bound safely. Include `workspace: {cwd: "<path>"}`.
  - `retry`: Transient fetch error.
  - `blocked`: Dirty unrelated checkout, divergent branch history, or missing remote.
