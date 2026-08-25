Collect every support ticket and Slack thread for the date range. Read-only.

Input: `{{workflow.input}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. Use that Grafana dashboard, channel, profile, and filters. OpsBot/Grafana MCP for ticket links. Slack MCP for each thread. Do not call OpsBot HTTP directly.

Retrieve every page of the MCP ticket result for the configured interval; do not stop at the first dashboard page or top-result limit. Treat a ticket as in scope only when the status returned by MCP is exactly `done`. Deduplicate in-scope tickets by permalink, then retrieve every retained Slack thread.

Handoff: UTC interval, channel, query vars, the complete raw result count, done-result count, every unique done-ticket URL, collected-thread count, full thread text or skip reason, and reconciliation for any count mismatch. Records returned with another status are excluded from the summarized-ticket count.

`ready`: the complete unique done-ticket list plus threads, with reconciled counts.
`retry`: transient API failure.
`blocked`: bad dates, missing config, or persistent dataset failure.
