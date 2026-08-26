Collect every configured support ticket and its Slack thread. Read-only.

Input: `{{workflow.input}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. All selection values, dashboard identity, and time semantics come only from this configuration. Do not hardcode a profile, person, request topic, dashboard UID, panel ID, field name, or ticket example in this prompt. Do not call OpsBot HTTP directly.

## Source selection

Use the configured Grafana dashboard and panel as the ticket-selection authority. First inspect the configured panel and resolve its available row fields and variable semantics through the permitted Grafana MCP reads.

Retain a panel row only when all configured conditions hold:

- its profile field equals `grafana.supportProfile`;
- its status field equals `grafana.ticketStatus`; and
- the row field named by `grafana.ticketActivityTimeField` falls within the requested inclusive interval in `grafana.timeZone`.

Do not substitute ticket creation time, request topic, assignee, requester, or any other field for a configured selection field. If the configured panel cannot return row data through the currently permitted MCP tools, return `blocked`; do not invent a manifest, ask the caller to copy panel rows, or reconstruct membership from a broad local search.

## Ticket retrieval

Deduplicate the selected ticket links in panel order. Record the source row count, retained row count, duplicate-link count, selected-link count, and every selected link. Return `blocked` when the row set cannot be reconciled to a unique selected-link set, except for documented duplicate links.

Use only the MCP servers allowed by the workflow:

- Use Grafana MCP only to resolve the configured panel and ticket-selection rows.
- Use OpsBot MCP only to validate configured triage provenance and retrieve an already selected ticket thread.
- Use Slack MCP only to retrieve an already selected ticket thread, or to resolve a missing selected link with a unique match against the row's configured-channel message identity.

Do not use an OpsBot topic, assignee, requester, creation-time, or broad ticket search to determine ticket membership.

For each selected ticket, retrieve the complete thread and preserve source wording, identifiers, authors, timestamps, URLs, and supported formatting. For an unavailable selected thread, record only the factual retrieval failure or skip reason.

Handoff the configured selection metadata, counts only for the selected row set, complete selected ticket records, and every retained Slack message in chronological source order. Do not summarize, title, classify, infer a resolution, explain a ticket, or reconcile results outside the configured selection. Return `blocked` rather than silently truncating required evidence when it cannot fit within the workflow handoff limit.

`ready`: complete unique configured-panel ticket records plus verbatim threads.
`retry`: transient MCP failure after resolving the configured panel.
`blocked`: bad dates, missing configuration, unavailable panel-row retrieval, unresolved or ambiguous selected ticket link, unreconciled selection counts, persistent dataset failure, or required evidence exceeding the handoff limit.
