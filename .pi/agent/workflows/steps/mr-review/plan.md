Turn reviewer findings into comments the user can approve.

Input: `{{workflow.input}}`
Findings: `{{last.summary}}`
Rejected plan: `{{gate.artifact}}`
Feedback: `{{gate.feedback}}`

Submit exactly:

# Review: <short verdict>
## Reviews

For each comment to publish:

### Suggestion
Human inline or summary comment, with path and line.
### Verdict
Why it is bad, and the topic: secret leak, architecture, style, bug, degradation, or maintainability.

Then:

## Publication contract
Fenced JSON `actions` for GitLab MCP or GitHub pending-review MCP (`create`, one comment each, `submit_pending` + `COMMENT`). CLI only with `mcpFallback`. No approve, merge, close, resolve, or delete.

`submit` when every intended comment has Suggestion and Verdict.
`retry`: transient read failure.
`blocked`: stale head.
