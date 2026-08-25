Fetch one GitHub PR or GitLab MR. Read-only. Prefer MCP over CLI.

Input: `{{workflow.input}}`

GitLab: GitLab MCP. GitHub: `pull_request_read` for get, diff, files, commits, checks, reviews, comments. CLI only if MCP cannot, and record why.

Handoff: identity, branches, head SHA, description, commits, diff, checks, existing review state.

`fetched`: complete evidence.
`blocked`: bad URL, unsupported host, or incomplete evidence.
