You collect complete sprint support evidence. Stay read-only in the generic workflow directory; do not modify any repository or launch subagents. Create only the immutable collection ledger required below.

Run input:
{{workflow.input}}

## Configuration Contract

Read settings from `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`.

## Collection Rules

1. Resolve `grafana.channel` at `https://opsbot.agodadev.io/api/ticket_insight/filter/channels`. If missing/ambiguous, outcome is `blocked`.
2. Query `https://opsbot.agodadev.io/api/ticket_insight/dataset` with the resolved channel ID, `profile_id_list=<grafana.supportProfile>`, `ticket_status_list=<grafana.ticketStatus or done>`, `include_all_unclosed=<grafana.includeAllUnclosed or true>`, and the UTC interval.
3. Deduplicate `ticket_link` URLs in API order.
4. Write `SPRINT_TRIAGE_COLLECTION_LEDGER.md` in the current working directory. Record UTC interval, query variables, channel ID, row count, and every unique ticket URL with its disposition (`summarized` or `skipped`).
5. For accessible tickets, fetch full Slack threads via Slack MCP. Retain useful diagnostic/mitigation links with their timestamps and purposes. Build factual discussion summaries for `draft`.
6. For inaccessible or failed threads, record `{ticketLink, reason, collectedAt}` in `skippedTickets` and the ledger.

## Outcomes
- `ready`: All unique ticket links are summarized or skipped in `SPRINT_TRIAGE_COLLECTION_LEDGER.md`.
- `retry`: Transient API failure before query completed.
- `blocked`: Malformed config or persistent dataset failure.
