Collect every configured support ticket and its Slack thread. Read-only.

Input: `{{workflow.input}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. All selection values, dashboard identity, and time semantics come only from this configuration. Do not hardcode a profile, person, request topic, dashboard UID, panel ID, field name, or ticket example in this prompt. Do not call OpsBot HTTP directly.

## Permitted MCP calls

Use only the MCP calls allowed for this workflow step in `sprint-triage.workflow.yaml`. Do not discover, call, or infer additional MCP tools.

## Source selection

1. Use the permitted Grafana dashboard reads to resolve the configured dashboard, its template variables, and the unique panel whose title equals `grafana.panelTitle`.
2. Use the permitted Grafana panel-query read to validate the configured ticket source and its displayed row fields.
3. Use the permitted OpsBot configuration read only to validate the configured triage provenance.
4. Select tickets only from rows returned by the configured Grafana ticket source. Retain a row only when:
   - its profile field equals `grafana.supportProfile`;
   - its status field equals `grafana.ticketStatus`; and
   - the row field named by `grafana.ticketActivityTimeField` falls within the requested inclusive interval in `grafana.timeZone`.

Do not substitute ticket creation time, request topic, assignee, requester, or any other field for a configured selection field. Do not use a renderer, image, broad ticket search, or local reconstruction to determine ticket membership.

If the permitted Grafana calls do not return the configured ticket rows, return `blocked` with the exact permitted call attempted and its factual response. Do not request a pasted panel export, create a synthetic manifest, use an image-rendering tool, or guess a substitute data source.

## Ticket-link and thread retrieval

Deduplicate selected ticket links in source-row order. Record the source row count, retained row count, duplicate-link count, selected-link count, and every selected link. Return `blocked` when the source row set cannot be reconciled to a unique selected-link set, except for documented duplicate links.

If a selected source row has no accessible ticket link, use only the permitted Slack message search in the configured channel. Match the root message using the row's creation time, requester, and distinctive message text. Accept a generated link only after one unique match; otherwise return `blocked`.

For each selected ticket link, use only the permitted OpsBot thread read. When that read is unavailable, use only the permitted Slack thread-replies read for the same selected thread.

For each selected ticket, preserve the complete thread's source wording, identifiers, authors, timestamps, URLs, and supported formatting. For an unavailable selected thread, record only the factual retrieval failure or skip reason.

Handoff the configured selection metadata, source-row and deduplication counts, complete selected ticket records, and every retained Slack message in chronological source order. Do not summarize, title, classify, infer a resolution, explain a ticket, or reconcile results outside the configured selection. Return `blocked` rather than silently truncating required evidence when it cannot fit within the workflow handoff limit.

`ready`: complete unique configured-source ticket records plus verbatim threads.
`retry`: transient failure from a permitted MCP call after resolving the configured source.
`blocked`: bad dates, missing configuration, configured ticket rows unavailable through the permitted calls, unresolved or ambiguous selected ticket link, unreconciled selection counts, persistent thread retrieval failure, or required evidence exceeding the handoff limit.
