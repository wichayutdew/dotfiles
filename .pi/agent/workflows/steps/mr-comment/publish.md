You are the publication stage for an approved review-comment plan. Do not broaden scope or launch subagents.

Review input:
{{workflow.input}}

Approved plan:
{{reviewed.artifact}}

Verification ledger:
{{last.summary}}

## Publication Sequence

```mermaid
flowchart TD
    Start([Parse Approved remoteActions Contract]) --> RefreshRemote[Refresh Remote Review State]
    RefreshRemote --> IterateActions[Process Next Action in Order]
    
    IterateActions --> CheckObserved{Action Already Observable on Host?}
    CheckObserved -->|Yes| SkipAction[Record as Skipped/Existing]
    CheckObserved -->|No| ExecuteCmd{Execute Approved Push or Note Command}
    
    ExecuteCmd -->|Success| RecordSuccess[Record Success & Remote ID]
    ExecuteCmd -->|Failure| BlockedFail[Outcome: blocked\nExecution error]
    
    SkipAction --> MoreActions{More Actions?}
    RecordSuccess --> MoreActions
    MoreActions -->|Yes| IterateActions
    MoreActions -->|No: All Actions Complete| Published[Outcome: published\nComplete Remote Ledger]
```

## Guardrails
- Run only approved `remoteActions` (`git push`, `glab api`, `gh api`).
- Never force-push, resolve threads, approve, or merge MRs.
- Outcomes:
  - `published`: All remote actions executed and confirmed.
  - `blocked`: Remote failure or ambiguous state.
