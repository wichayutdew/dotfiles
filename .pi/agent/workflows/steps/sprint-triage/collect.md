Collect every support ticket and Slack thread for the date range. Read-only.

Input: `{{workflow.input}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. Use that Grafana dashboard, channel, profile, and filters. OpsBot/Grafana MCP for ticket links. Slack MCP for each thread. Do not call OpsBot HTTP directly.

Handoff: UTC interval, channel, query vars, every unique ticket URL, full thread text or skip reason.

`ready`: complete ticket list plus threads.
`retry`: transient API failure.
`blocked`: bad dates, missing config, or persistent dataset failure.
