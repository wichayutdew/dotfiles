Collect every ticket selected by the configured Grafana Ticket list panel and its Slack thread. Read-only.

Input: `{{workflow.input}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. Do not call OpsBot HTTP directly.

## Grafana ticket manifest

`{{workflow.input}}` must contain a machine-readable `grafanaTicketManifest` from Grafana dashboard panel 8. A manifest contains panel metadata and one ticket row per panel result:

```json
{
  "grafanaTicketManifest": {
    "dashboardUid": "aeb8n5f4rrldsa",
    "panelId": 8,
    "timeZone": "Asia/Bangkok",
    "tickets": [
      {
        "ticketLink": "https://agoda.slack.com/archives/<channel>/p<timestamp>",
        "profileName": "activities_marketing_triage",
        "status": "done",
        "lastActivityTime": "2026-08-18T17:35:38.570029+07:00",
        "createdAt": "2026-08-17T12:05:08.034588+07:00",
        "requesterName": "Theodorus Hendra",
        "originalMessage": "Hi Marketing team, ...",
        "requestTopic": "activities_marketing_topic",
        "assignedToName": "Wichayut Phongphanpanya"
      }
    ]
  }
}
```

`ticketLink` may be absent only when the row has enough identity evidence for the Slack fallback. A missing manifest, malformed ticket row, or missing `profileName`, `status`, `lastActivityTime`, `requesterName`, or `originalMessage` is `blocked`.

## Selection rule

Use the manifest as the only ticket-selection authority. Retain a row only when:

- `profileName` exactly equals `grafana.supportProfile`;
- `status` exactly equals `grafana.ticketStatus`; and
- the field configured by `grafana.ticketActivityTimeField` is within the requested inclusive Asia/Bangkok date interval.

`createdAt`, `requestTopic`, `assignedToName`, and `requesterName` are evidence fields, not selection fields. Do not replace the manifest selection with an OpsBot topic, assignee, requester, or creation-time search.

Examples:

- Retain an `activities_marketing_triage` row with `requestTopic = supply_opt_topic`.
- Retain an `activities_marketing_triage` row with `requestTopic = activities_booking_topic`.
- Retain a ticket created before the requested interval when `lastActivityTime` is within it.
- Exclude a done ticket whose `lastActivityTime` is outside the interval, even when `requestTopic = activities_marketing_topic`.

Normalize and deduplicate retained rows by `ticketLink`, preserving manifest order. Record the manifest row count, retained row count, duplicate-link count, selected permalink count, and selected links. Return `blocked` if retained rows cannot be reconciled to deduplicated links, except for documented duplicate links.

## Permitted MCP calls

Grafana MCP calls are limited to:

```text
grafana_get_dashboard_by_uid
grafana_get_dashboard_property
grafana_get_dashboard_panel_queries
```

Use them only to validate the configured dashboard UID, panel 8, panel title, datasource provenance, variables, and expected row fields. The currently exposed Grafana MCP server cannot execute panel 8's Infinity datasource query, so these calls do not replace the supplied manifest.

OpsBot MCP calls are limited to:

```text
opsbot_get_channel_config
opsbot_get_slack_thread
```

Use `opsbot_get_channel_config` only to confirm triage-profile provenance. Use `opsbot_get_slack_thread` only for a selected ticket link. Do not use `opsbot_ticket_search` to determine ticket membership.

Slack MCP calls are limited to:

```text
slack_slack_search_messages
slack_slack_get_thread_replies
```

Use `slack_slack_search_messages` only when a selected manifest row lacks `ticketLink`. Search `#activities-support` using the requested date, requester, and distinctive original-message text. Accept a generated link only after a unique root-message match. Otherwise return `blocked`. Use `slack_slack_get_thread_replies` only when OpsBot cannot retrieve a known selected thread.

For each selected ticket, retrieve the complete thread and preserve source wording, identifiers, authors, timestamps, URLs, and supported formatting. For an unavailable selected thread, record only the factual retrieval failure or skip reason.

Handoff the manifest metadata, selection counts, complete selected ticket records, and every retained Slack message in chronological source order. Do not summarize, title, classify, infer a resolution, explain a ticket, or reconcile results outside the selected manifest. Return `blocked` rather than silently truncating required evidence when it cannot fit within the workflow handoff limit.

`ready`: complete unique manifest-selected ticket records plus verbatim threads.
`retry`: transient MCP failure after manifest validation.
`blocked`: bad dates, missing or malformed manifest, unresolved or ambiguous ticket link, unreconciled selection counts, persistent dataset failure, or required evidence exceeding the handoff limit.
