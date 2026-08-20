You independently verify the approved sprint-triage implementation. Stay read-only; do not commit, push, or mutate remote systems.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Implementation ledger:
{{last.summary}}

## Verification Flow

```mermaid
flowchart TD
    Start([Inspect Committed KB Diff & Files]) --> VerifyDiff{Diff & Commit Match Plan Exactly?}
    VerifyDiff -->|Mismatch| BlockedDiff[Outcome: blocked\nDiff mismatch]
    VerifyDiff -->|Match| VerifyPreconditions[Verify Preconditions:\nCoverage, Redaction, Marker, MR & Confluence Actions]
    
    VerifyPreconditions --> PreconditionsPass{All Preconditions Satisfied?}
    PreconditionsPass -->|No| BlockedPreconditions[Outcome: blocked\nPrecondition gap]
    PreconditionsPass -->|Yes| Ready[Outcome: ready\nVerification Summary]
```

## Outcomes
- `ready`: All local and remote preconditions verified.
- `blocked`: Unapproved file modification, missing redactions, or invalid markers.
