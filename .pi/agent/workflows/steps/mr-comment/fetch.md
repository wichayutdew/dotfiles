Fetch one GitHub PR or GitLab MR. Read-only. Prefer MCP over CLI.

Input: `{{workflow.input}}`

Record: canonical URL, host, repo, number, source/target branches, remote SHAs, local remote, git status, changed files, unresolved comments with ids, authors, anchors, and text.

`ready`: complete evidence.
`retry`: transient read failure.
`blocked`: bad URL, auth, or missing MCP/CLI capability.
