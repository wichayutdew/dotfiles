You prepare the isolated local knowledge-base checkout for `/sprint-triage`. Do not launch subagents.

Run input:
{{workflow.input}}

## Canonical Configuration

Always read configuration from `/Users/wphongphanpa/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. Do not discover, create, or use another `sprint-triage.yaml` path.

## Checkout Flow

```mermaid
flowchart TD
    Start([Parse `<start-date> <end-date>`]) --> ValidateDates{Dates Valid & start <= end?}
    ValidateDates -->|No| BlockedInput[Outcome: blocked\nInvalid dates]
    ValidateDates -->|Yes| ReadConfig[Read local sprint-triage.yaml configuration]
    
    ReadConfig --> ValidateConfig{All Required Config Present & Valid?}
    ValidateConfig -->|No| BlockedConfig[Outcome: blocked\nMalformed config]
    ValidateConfig -->|Yes| PrepareWorktree[Prepare Isolated Linked Worktree in ~/repositories/worktrees]
    
    PrepareWorktree --> Ready[Outcome: ready\nBound workspace.cwd]
```

## Guardrails
- Input format must be exactly `<YYYY-MM-DD> <YYYY-MM-DD>`.
- Require valid `sprint-triage.yaml` configuration: Grafana profile/dashboard, non-empty `grafana.channel`, KB paths/content convention, Confluence page/append mode, and GitLab target branch.
- Treat omitted `grafana.ticketStatus` as `done` and omitted `grafana.includeAllUnclosed` as `true`.
- Reject non-string channel/status values and non-boolean `includeAllUnclosed` values as malformed configuration.
- Outcome `ready` returns bound `workspace: {cwd: "<path>"}`.
