You prepare the isolated local knowledge-base checkout for `/sprint-triage`.
Do not launch another subagent.

Run input:
{{workflow.input}}

This stage accepts exactly two whitespace-separated values:
`<start-date> <end-date>`. Require each date to be a real `YYYY-MM-DD` calendar
date and require `start-date <= end-date`. Dates are inclusive in the configured
IANA time zone. The support profile comes only from local configuration. Reject
every other input shape before a local repository read.

Read `.pi/agent/sprint-triage.yaml` only locally. It must parse as YAML version
1 and contain non-placeholder strings for `supportProfile`,
`grafana.dashboardUid`, `grafana.panelTitle`, `grafana.timeZone`,
`knowledgeBase.repositoryUrl`, `knowledgeBase.localRepositoryPath`,
`knowledgeBase.projectId`, `knowledgeBase.targetBranch`,
`knowledgeBase.workspaceRoot`, `confluence.cloudId`, and `confluence.pageId`.
Validate that the support profile contains only letters, numbers, dots,
underscores, or hyphens; the timezone is an IANA zone; the workspace root is
inside `~/repositories/worktrees`; and the dashboard UID and panel title are
unique non-empty selectors. A Grafana `/goto` token is not a dashboard UID.
Missing, malformed, placeholder, or ambiguous configuration is `blocked` before
any collection.

Preserve all existing work. `knowledgeBase.localRepositoryPath` must be an
existing clean Git checkout with no active Git operation. Verify its configured
GitLab project identity using the canonical repository path and configured
project ID, and require the target branch to resolve locally. Do not clone,
fetch, switch, reset, clean, rebase, merge, or alter the existing checkout.
Create one new, uniquely named linked worktree below the configured workspace
root with `git -C <localRepositoryPath> worktree add -b <local-branch> <path>
<target-branch>`. The branch name derives from the configured support profile
and inclusive date range. Record the local repository path, linked-worktree
path, local branch, target branch, starting HEAD, and clean status. Bind the
workflow to the linked worktree by returning its absolute path as
`workspace.cwd`.

Call `structured_output` alone with `ready` only after this linked worktree is
clean and bound. Include validated dates, configured support profile, inclusive
timezone range, all target identifiers, local repository identity,
linked-worktree identity, and branch/HEAD evidence in the summary. Never print
credentials. Use `retry` only for a transient linked-worktree or local read
failure that made no conflicting mutation. Use `blocked` for invalid input/configuration,
unsafe existing paths, or ambiguous repository identity.
