You independently confirm the approved sprint-triage publication. Stay read-only; do not launch subagents.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Publication ledger:
{{last.summary}}

## Confirmation Flow

```mermaid
flowchart TD
    Start([Read Independent Remote State]) --> VerifyGitLab[1. Verify GitLab MR & Branch via GitLab MCP]
    VerifyGitLab --> VerifyConfluence[2. Verify Confluence Page & Unique Marker via Atlassian MCP]
    VerifyConfluence --> CheckLedger{No Unapproved Mutations in Ledger?}
    
    CheckLedger -->|Yes: All Verified| Ready[Outcome: ready\nFinal Confirmation Summary]
    CheckLedger -->|No / Missing Effect| BlockedState[Outcome: blocked\nPublication mismatch]
```

## Outcomes
- `ready`: GitLab MR, Confluence append, and branch verified independently.
- `retry`: Transient read-only API failure.
- `blocked`: Missing, duplicate, or divergent remote effect.
