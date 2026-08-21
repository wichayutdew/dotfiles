You collect the complete evidence for the support tickets returned by the configured Grafana panel. Stay read-only in the bound checkout; do not launch subagents.

Run input:
{{workflow.input}}
Checkout ledger:
{{last.summary}}

## Collection Contract

Grafana ticket rows are authoritative. Do not substitute a channel-wide Slack history, sample roots, search results, reactions, or a guessed ticket list for the configured panel result.

1. Read the local `sprint-triage.yaml`, resolve the configured dashboard and uniquely named panel, and execute its rendered query for the requested UTC interval. Record the rendered variables, returned row count, result cap, and every ticket row needed to reproduce the selection.
2. If the query reaches a documented or observed row cap, split the UTC interval into non-overlapping halves and repeat until every interval is unsaturated. Deduplicate rows by the panel ticket identifier; otherwise use the exact Slack permalink plus a stable row identifier.
3. For every deduplicated ticket row, extract its Slack permalink. Parse and validate its workspace, `channel_id`, and `thread_ts`; do not infer these values from a channel scan. Follow only the Slack link supplied by that Grafana row.
4. Fetch the complete Slack thread with `slack_slack_get_thread_replies`, following every pagination cursor until empty. Preserve chronological order, including the root message. Redact secrets, credentials, tokens, authorization headers, cookies, and unnecessary personal data in the ledger; retain the evidence needed to support the summary.
5. Build one factual ticket ledger entry per Grafana row with:
   - panel ticket identifier and redacted Grafana fields;
   - source dashboard/panel, queried UTC interval, and exact Slack permalink;
   - `channel_id`, `thread_ts`, reply-pagination coverage, and message count;
   - concise statement of the requester-reported issue;
   - chronological, evidence-backed investigation and actions taken;
   - final outcome stated in the thread, or `no verified final outcome`;
   - open follow-up, owner, or escalation only when explicitly stated; and
   - explicit `UNKNOWN` fields for missing evidence. Do not promote a reaction or status emoji into a technical resolution.

## Collection Flow

```mermaid
flowchart TD
    Start([Parse Config and UTC Interval]) --> QueryPanel[Execute Rendered Grafana Ticket-List Panel Query]
    QueryPanel --> CheckCap{Panel Result Saturated?}
    CheckCap -->|Yes| SplitInterval[Split into Non-overlapping UTC Halves]
    SplitInterval --> QueryPanel
    CheckCap -->|No| ExtractLinks[Extract and Validate Slack Links from Every Ticket Row]
    ExtractLinks --> FetchThreads[Fetch Every Linked Thread Through Final Pagination Cursor]
    FetchThreads --> BuildLedger[Create One Factual Ledger Entry Per Ticket]
    BuildLedger --> VerifyCoverage{All Rows and Threads Complete?}
    VerifyCoverage -->|Yes| ReadyFull[Outcome: ready]
    VerifyCoverage -->|No| Blocked[Outcome: blocked]
```

## Rules & Outcomes
- `ready`: Only when the authoritative Grafana result is unsaturated and every selected ticket has a validated Slack link, a fully paginated thread transcript, and one factual ledger entry.
- `retry`: A transient Grafana or Slack read failure; retain completed interval/thread coverage and retry only the failed read.
- `blocked`: The panel cannot be executed with the available Grafana identity/tools; a result remains saturated after interval splitting; a required row lacks a valid Slack link; a linked thread is inaccessible; or the panel schema prevents ticket-to-thread mapping. State the exact failed row/interval/tool and do not return ready with a partial substitute.
