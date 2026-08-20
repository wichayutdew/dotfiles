# Pi Coding Contract

Core execution protocol for Pi autonomous workflows and subagents.

## Workflow Lifecycle

```mermaid
stateDiagram-v2
    [*] --> WorkflowSelect: Route Command
    WorkflowSelect --> WorkspacePrep: /work, /ticket
    WorkflowSelect --> ReadOnlyPlan: /jira, /investigate, /mr-review, /mr-comment, /start-triage
    WorkspacePrep --> ReadOnlyPlan: Workspace Ready
    
    state ReadOnlyPlan {
        [*] --> EvidenceGathering
        EvidenceGathering --> PlanDrafting
        PlanDrafting --> PlannotatorGate
        PlannotatorGate --> PlanDrafting: Changes Requested
    }
    
    ReadOnlyPlan --> SingleWriter: Plan Approved (/work, /ticket, /mr-comment)
    ReadOnlyPlan --> ReadOnlyReport: Plan Approved (/investigate, /mr-review, /start-triage)
    
    state SingleWriter {
        [*] --> FailingTest
        FailingTest --> MinimalEdit
        MinimalEdit --> PassingTest
    }
    
    SingleWriter --> ReadOnlyVerification: Ready
    
    state ReadOnlyVerification {
        [*] --> RunChecks
        RunChecks --> InspectDiff
    }
    
    ReadOnlyVerification --> SingleWriter: Failed (Regression/Lint)
    ReadOnlyVerification --> UserAuthGate: Passed
    ReadOnlyReport --> UserAuthGate: Findings Verified
    
    UserAuthGate --> RemoteAction: Authorized (Push/Comment/Draft)
    UserAuthGate --> [*]: Denied / Local Only
    RemoteAction --> [*]: Done
```

## Mandatory Contract Rules

1. **Single Workflow**: Run exactly one workflow (`/work`, `/ticket`, `/jira`, `/investigate`, `/mr-review`, `/mr-comment`, `/start-triage`).
2. **Evidence Taxonomy**:
   - `FACT source`: Proven by explicit line/tool evidence.
   - `HYPOTHESIS confidence + falsifier`: Unproven assumption.
   - `UNKNOWN next check`: Gap to verify.
3. **Workspace Isolation**: Bound dedicated branch/worktree for mutating workflows. Never dirty or reset unrelated checkouts.
4. **Planning Is Read-Only**: Submit scoped plan to Plannotator. Never edit code before approval.
5. **Single Writer**: One implementation child per workspace using TDD (red -> green).
6. **Independent Verification**: Separate read-only reviewer executing full verification suite.
7. **Explicit User Authorization**: External pushes, merges, Jira mutations, or comments require user confirmation.
8. **Secrets & Versions**: Consult Context7 for versioned APIs. Never log secrets.
