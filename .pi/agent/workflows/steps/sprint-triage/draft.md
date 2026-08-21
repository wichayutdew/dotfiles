You draft redacted knowledge summaries from the complete OpsBot-selected support-ticket evidence. Stay read-only; do not commit, push, or publish.

Run input:
{{workflow.input}}
Collection ledger:
{{last.summary}}

## Preconditions

The collection output must identify every OpsBot ticket row as either a successful linked Slack-thread summary or a skipped-ticket record. Do not replace missing ticket knowledge with channel-history observations, generic support advice, a decision tree, or inferred procedures. Do not block for individual inaccessible threads; retain them in `skippedTickets`.

## Drafting Flow

```mermaid
flowchart TD
    Start([Validate OpsBot Ticket Evidence]) --> CheckCoverage{Every Ticket Summarized or Skipped?}
    CheckCoverage -->|No| Blocked[Outcome: blocked]
    CheckCoverage -->|Yes| Summarize[Write One Factual Summary Per Accessible Ticket]
    Summarize --> CrossCheck[Cross-check Every Claim Against Its Thread]
    CrossCheck --> Ready[Outcome: ready\nTicket-by-ticket draft ledger]
```

## Required Draft Artifact

Create two redaction-safe artifacts from each accessible ticket.

### Knowledge-base repository record

Each ticket record must contain exactly these evidence fields:

1. **Slack URL**
2. **Inquiry summary** — what the requester asked or observed, grounded in the thread.
3. **Action taken to mitigate the issue** — ordered actions and verified outcome; use `no verified mitigation` when absent.
4. **Knowledge gained from this support** — a reusable factual takeaway, or `case-specific; no reusable knowledge`.
5. **Unknown gap** — explicit `UNKNOWN` items; a reaction/status emoji alone is not a resolution.

### Confluence decision tree / step-by-step guide

The Confluence append under the configured marker contains only:

1. **Inquiry topic**
2. **Steps to take an action to resolve the inquiry**

Do not include Slack URLs, ticket identifiers, owners, timestamps, evidence gaps, metrics, raw thread content, or one-off ticket narratives in Confluence. Group only substantively equivalent inquiries into one topic; when no repeatable resolution exists, omit that ticket from Confluence and retain its repository record.

When `skippedTickets` is non-empty, keep their URL, reason, and timestamp in the repository report only. Do not infer their topic, resolution, or knowledge.

## Outcomes
- `ready`: A complete, ticket-by-ticket draft with every ticket either summarized from its collected Slack thread or reported in `Skipped ticket threads`.
- `blocked`: Missing, ambiguous, or untraceable dataset evidence; identify the exact ticket and evidence required.
