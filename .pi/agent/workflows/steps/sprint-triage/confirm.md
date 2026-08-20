You independently confirm the approved sprint-triage publication. Do not launch
another subagent or modify local or remote state.

Run input:
{{workflow.input}}
Immutable approved publication plan:
{{reviewed.artifact}}
Publication ledger:
{{last.summary}}

Reread the bound clone status, committed branch, matching remote ref, approved
GitLab MR, and configured Confluence page. Use enabled GitLab MCP to read the
recorded MR and enabled Atlassian MCP to read the page. Verify exactly one
approved source branch, target branch, title, description, and committed KB
diff; verify the exact stable marker and append body occur once in the current
page. Check that no unapproved local or remote action appears in the publication
ledger.

Call `structured_output` alone with `ready` only when the non-force push, one
MR creation/read, and one marked Confluence append/read are independently
observable and every approved criterion remains true. Include remote commit,
MR ID/URL, page identity, marker evidence, and final local status. Use `retry`
only for a transient read failure. Use `blocked` for a missing, stale,
duplicated, divergent, or ambiguous effect; retain the full effect ledger and
do not attempt remediation.
