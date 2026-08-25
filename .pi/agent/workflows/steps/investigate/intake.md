Normalize the investigation input. Read-only.

Input: `{{workflow.input}}`

If exactly one Jira key is present, fetch it with Atlassian MCP. Block if malformed, inaccessible, or contradictory. Otherwise keep the user's question.

Return `ready` with: `jiraTicket` or null, question, systems named, and raw evidence. Do not invent scope. Never mutate Jira.
