Collect every configured support ticket and its Slack thread. Read-only.

Input: `{{workflow.input}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. All selection values, dashboard identity, and time semantics come only from this configuration. Do not hardcode a profile, person, request topic, dashboard UID, panel ID, field name, or ticket example in this prompt. Do not call OpsBot HTTP directly.

## Required Grafana retrieval sequence

Use the configured Grafana dashboard and panel as the ticket-selection authority. Do not stop after reading its JSON definition.

1. Use `grafana_get_dashboard_by_uid` and `grafana_get_dashboard_property` to resolve the configured dashboard, its template variables, and the unique panel whose title equals `grafana.panelTitle`.
2. Use `grafana_get_dashboard_panel_queries` to confirm the resolved panel is the configured ticket source and identify its displayed row fields.
3. Derive the dashboard variable overrides from the resolved variable labels and query references. Bind only the values from `grafana.channel`, `grafana.supportProfile`, `grafana.ticketStatus`, `grafana.includeAllUnclosed`, the requested date interval, and `grafana.timeZone`.
4. Call `grafana_get_panel_image` for the resolved panel with those variable overrides and the requested time range. Request dimensions sufficient to capture the complete rendered table. If the panel paginates, capture every page before continuing.
5. Extract every rendered ticket row and its displayed source fields, including the ticket link, profile, status, configured activity-time field, creation time, requester, message, request topic, and assignee when present.

Do not conclude that row retrieval is unavailable merely because the panel datasource is not directly queryable through a Loki, Prometheus, or Elasticsearch tool. The rendered configured panel is the required row-retrieval path.

## Source selection

Retain a rendered panel row only when all configured conditions hold:

- its profile field equals `grafana.supportProfile`;
- its status field equals `grafana.ticketStatus`; and
- the row field named by `grafana.ticketActivityTimeField` falls within the requested inclusive interval in `grafana.timeZone`.

Do not substitute ticket creation time, request topic, assignee, requester, or any other field for a configured selection field. Creation time, requester, message text, and request topic may be used only to resolve a missing displayed ticket link.

## Ticket-link and thread retrieval

Deduplicate selected ticket links in rendered-panel order. Record the rendered source row count, retained row count, duplicate-link count, selected-link count, and every selected link. Return `blocked` when the rendered row set cannot be reconciled to a unique selected-link set, except for documented duplicate links.

If a selected rendered row has no accessible ticket link, call `slack_slack_search_messages` in the configured channel. Match the root message using the row's creation time, requester, and distinctive message text. Accept a generated link only after one unique match; otherwise return `blocked`.

For each selected ticket link, call `opsbot_get_slack_thread`. When that read is unavailable, call `slack_slack_get_thread_replies` for the same selected thread. Do not use `opsbot_ticket_search` or any broad OpsBot search to determine ticket membership.

Use `opsbot_get_channel_config` only to validate configured triage provenance. Use Grafana MCP only for dashboard, panel, and rendered-row retrieval; use OpsBot and Slack only after Grafana selects the ticket rows.

For each selected ticket, preserve the complete thread's source wording, identifiers, authors, timestamps, URLs, and supported formatting. For an unavailable selected thread, record only the factual retrieval failure or skip reason.

Handoff the configured selection metadata, rendered-row and deduplication counts, complete selected ticket records, and every retained Slack message in chronological source order. Do not summarize, title, classify, infer a resolution, explain a ticket, or reconcile results outside the configured selection. Return `blocked` rather than silently truncating required evidence when it cannot fit within the workflow handoff limit.

`ready`: complete unique configured-panel ticket records plus verbatim threads.
`retry`: transient MCP failure after the rendered-panel retrieval attempt.
`blocked`: bad dates, missing configuration, failed rendered-panel retrieval after the required sequence, incomplete panel-page coverage, unresolved or ambiguous selected ticket link, unreconciled selection counts, persistent thread retrieval failure, or required evidence exceeding the handoff limit.
