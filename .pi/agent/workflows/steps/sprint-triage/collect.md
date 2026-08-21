You collect complete sprint support evidence. Do not modify knowledge-base content or launch subagents. You may create only the immutable collection ledger required below in the bound checkout.

Run input:
{{workflow.input}}
Checkout ledger:
{{last.summary}}

## Canonical Configuration

Read all collection settings only from `/Users/wphongphanpa/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. Do not use another `sprint-triage.yaml` path or infer settings from dashboard defaults.

## Collection Contract

The OpsBot ticket-insight dataset is authoritative for this workflow because it is the source queried by the configured Grafana Ticket list panel. Do not require Grafana datasource execution. Use Grafana only to record dashboard/panel provenance.

1. Resolve `grafana.channel` through `https://opsbot.agodadev.io/api/ticket_insight/filter/channels`. A missing or non-unique exact channel-name match is `blocked`.
2. Query `https://opsbot.agodadev.io/api/ticket_insight/dataset` with the resolved channel ID, configured `grafana.supportProfile`, all users, no request-topic or assignee restriction, and the workflow UTC interval. Send `profile_id_list=<configured support profile>`, `ticket_status_list=done`, and `include_all_unclosed = config value or true`. Do not query all profiles. The selected ticket set is exactly the configured profile's done tickets in the provided UTC time range.
3. Extract non-empty `ticket_link` values and deduplicate them while preserving API order. Record the rendered request variables and returned row count.
4. Create `SPRINT_TRIAGE_COLLECTION_LEDGER.md` once in the bound worktree; do not edit it after creation. It must record the UTC collection interval; configured and rendered `supportProfile`, channel name and resolved channel ID, `ticketStatus`, and `includeAllUnclosed`; Grafana dashboard/panel provenance; dataset request variables and returned row count; every unique ticket URL in API order; and, for each URL, exactly one `summarized` or `skipped` disposition. Each skipped disposition must contain only URL, reason, and collection timestamp. Record the SHA-256 of the complete ledger in the step handoff.
5. Parse each Slack permalink as `/archives/<channel-id>/p<16-digit-timestamp>` and transform its timestamp into Slack `seconds.microseconds` form.
6. Fetch each parent and all replies through Slack MCP, following pagination until empty. Extract every URL explicitly present in the thread and retain only useful links that guide triage, mitigation, escalation, diagnostics, or content enhancement. For each retained link, record its URL, the message timestamp, and a short evidence-grounded purpose; do not validate, invent, or follow the URL during collection.
7. Build a factual discussion summary only from returned text and pass successful summaries plus the retained useful-link evidence directly to `draft`.
8. For a malformed link, unavailable parent, inaccessible thread, or Slack API failure, do not summarize. Continue collection and append `{ticketLink, reason, collectedAt}` to `skippedTickets` and the persistent ledger.

## Collection Flow

```mermaid
flowchart TD
    Start([Parse config and UTC interval]) --> ResolveChannel[Resolve configured OpsBot channel]
    ResolveChannel --> QueryTickets[Query OpsBot ticket-insight dataset]
    QueryTickets --> Deduplicate[Deduplicate ticket links]
    Deduplicate --> FetchThreads[Fetch parent and replies through Slack MCP]
    FetchThreads --> Summarize[Pass accessible factual summaries to draft]
    FetchThreads --> Skip[Record inaccessible tickets in skippedTickets]
    Summarize --> Ready[Outcome: ready]
    Skip --> Ready
```

## Rules & Outcomes
- `ready`: Every unique ticket link has either a direct summary for draft or one skipped-ticket record, and `SPRINT_TRIAGE_COLLECTION_LEDGER.md` proves the configured query values, row count, ordered URL set, and one disposition per URL.
- `retry`: Channel or dataset retrieval failed transiently before a complete ticket list was obtained.
- `blocked`: Invalid configuration, ambiguous/missing channel, or a non-transient dataset access failure.
- Per-ticket Slack failures are never `retry` or `blocked`; they are skipped tickets.
