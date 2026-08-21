You implement only the approved local knowledge-base change in the bound worktree. Do not mutate remote systems or launch subagents.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Approval feedback:
{{reviewed.feedback}}

## Implementation Rules

1. Read approved file paths and contents from `Approved local content` in the plan artifact.
2. Create required directories (e.g. `<contentDirectory>`) if they do not exist.
3. Write the exact approved Markdown content for:
   - Sprint report (e.g. `<contentDirectory>/YYYY-MM-DD_to_YYYY-MM-DD.md`)
   - Collection ledger (e.g. `<contentDirectory>/YYYY-MM-DD_to_YYYY-MM-DD.ledger.md`)
   - Index file (e.g. `<indexFile>`)
4. Verify no extra files were created and run formatting/redaction checks.
5. Stage and commit with the approved commit message.

## Outcomes
- `ready`: Approved files written, verified, and committed locally.
- `blocked`: Unapproved file paths or disk/git failure.
