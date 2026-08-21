You prepare the isolated local knowledge-base checkout for `/sprint-triage`. Do not launch subagents.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}

## Configuration Contract

Read settings from `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`.

## Checkout Rules

1. Parse `<start-date> <end-date>`. Must be `YYYY-MM-DD YYYY-MM-DD` with start <= end.
2. Validate that `knowledgeBase.localRepositoryPath` exists and is a valid Git repository.
3. Validate that `knowledgeBase.contentDirectory` and `knowledgeBase.indexFile` are safe relative paths.
4. **Empty or new repos are valid:** Never block because the content directory or index file does not exist yet.
5. Create and switch to a clean linked worktree in `knowledgeBase.workspaceRoot` on dedicated branch `docs/sprint-triage-<start-date>-to-<end-date>`.

## Outcomes
- `ready`: Bound `workspace: {cwd: "<worktree-path>"}`.
- `blocked`: Invalid dates, repository path missing, or unrecoverable git failure.
