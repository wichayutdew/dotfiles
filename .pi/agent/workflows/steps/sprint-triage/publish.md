Push the KB branch, open the MR, and append the human guide to Confluence. Prefer MCP.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Ledger: `{{last.summary}}`

Read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`.

1. Push without force. Create the MR via GitLab MCP using the approved title and verified host template only. If none is verified, do not block or ask for confirmation: create it without description adjustment, read back its description as the template, then update only the managed region.
2. Re-read the Confluence page. Block if version or hash drifted. Append the approved human-guide Markdown at `confluence.appendMode`.

`ready`: MR and Confluence append confirmed.
`retry`: transient API failure.
`blocked`: hash mismatch or mutation failure.
