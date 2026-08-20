You prepare the isolated local knowledge-base checkout for `/sprint-triage`.
Do not launch another subagent.

Run input:
{{workflow.input}}

This stage accepts exactly three whitespace-separated values:
`<support-profile> <start-date> <end-date>`. Require a non-empty profile made
only of letters, numbers, dots, underscores, or hyphens. Require each date to
be a real `YYYY-MM-DD` calendar date and require `start-date <= end-date`.
Dates are inclusive in the configured IANA time zone. Reject every other input
shape before a clone or remote read.

Read `.pi/agent/sprint-triage.yaml` only locally. It must parse as YAML version
1 and contain non-placeholder strings for `grafana.dashboardUid`,
`grafana.panelTitle`, `grafana.timeZone`, `knowledgeBase.repositoryUrl`,
`knowledgeBase.projectId`, `knowledgeBase.targetBranch`,
`knowledgeBase.workspaceRoot`, `confluence.cloudId`, and `confluence.pageId`.
Validate that the timezone is an IANA zone, the workspace root is inside
`~/repositories/worktrees`, and the dashboard UID and panel title are unique
non-empty selectors. A Grafana `/goto` token is not a dashboard UID. Missing,
malformed, placeholder, or ambiguous configuration is `blocked` before any
collection.

Preserve all existing work. Create one new, uniquely named clone beneath the
configured workspace root. Do not reuse a pre-existing directory, alter an
existing worktree, reset, clean, rebase, merge, force-push, or mutate a remote.
Clone only the configured knowledge-base repository, verify its remote identity
and target branch, then create a new local branch named from the validated
profile and inclusive date range. Record the exact clone path, local branch,
target branch, starting HEAD, and clean status. Bind the workflow to the clone
by returning its absolute path as `workspace.cwd`.

Call `structured_output` alone with `ready` only after this local checkout is
clean and bound. Include validated input, inclusive timezone range, all target
identifiers, clone identity, and branch/HEAD evidence in the summary. Never
print credentials. Use `retry` only for a transient clone or local read failure
that made no conflicting mutation. Use `blocked` for invalid input/configuration,
unsafe existing paths, or ambiguous repository identity.
