Push the KB branch, open the MR, and append the human guide to Confluence. Prefer MCP.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Ledger: `{{last.summary}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`.

1. Push without force. Create the MR via GitLab MCP using the approved title and the host description template only.
2. Re-read the Confluence page. Block if version or hash drifted. Append the approved human-guide Markdown at `confluence.appendMode`.

`ready`: MR and Confluence append confirmed.
`retry`: transient API failure.
`blocked`: hash mismatch or mutation failure.
