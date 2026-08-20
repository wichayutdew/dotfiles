You implement only the Plannotator-approved local knowledge-base change. Do not
launch another subagent or mutate a remote system.

Run input:
{{workflow.input}}
Immutable approved publication plan:
{{reviewed.artifact}}
Approval feedback:
{{reviewed.feedback}}
Previous ledger:
{{last.summary}}

Revalidate the bound linked-worktree path, repository remote, source branch,
base branch, starting status, exact approved file paths, and approved file bytes
before writing. Treat existing work as possibly complete: inspect each file and
commit history first. If a matching commit already exists on the approved local
branch, verify its files and return its SHA without another commit.

Write only the exact approved KB files. Do not write a dashboard, Slack record,
ticket, plan revision, generated cache, Confluence content, or any unapproved
file. Preserve repository formatting and conventions. Re-run the approved
redaction and content checks before staging. Stage only the approved KB paths,
inspect the staged diff, and commit once with the approved commit title. Never
amend, reset, clean, rebase, merge, switch branches, push, create a merge
request, update Confluence, or make any other remote mutation.

Call `structured_output` alone with `ready` only after the committed tree
contains exactly the approved KB content and the working tree has no task-owned
changes. Include linked-worktree path, branch, parent and commit SHA, exact
staged paths,
content/redaction evidence, commands/results, and current status. Use `retry`
only for a transient local failure before a commit. Use `blocked` for changed
identity, pre-existing conflicting work, unapproved content, or an ambiguous
commit result.
