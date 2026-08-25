Pull Jira or normalize the brief. Do not create a branch or worktree.

Input: `{{workflow.input}}`
Restart workspace: `{{restart.workspace}}`

If the input has exactly one Jira key, fetch it with Atlassian MCP. Block if the key is malformed, inaccessible, ambiguous, or contradictory. Otherwise treat the input as a requirement plus any stated acceptance criteria.

Pick a Conventional Commit type and a short semantic summary. Do not guess.

Return `ready` with compact JSON: `mode` (`jira` or `requirement`), `jiraTicket`, `summary`, `branchType`, `acceptanceCriteria`, evidence. On restart, keep the existing branch identity. Block if new input contradicts a verified Jira key.

Never mutate Jira, Git, remotes, or worktrees.
