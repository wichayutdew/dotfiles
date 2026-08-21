You publish only the approved actions for sprint-triage. Do not launch subagents.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Verification summary:
{{last.summary}}

## Publication Rules

1. **GitLab Push & MR:**
   - Push the committed local branch to GitLab without force.
   - Create the single approved MR via GitLab MCP with approved title/description against `gitlab.targetBranch`.
2. **Confluence Append:**
   - Before mutating, call `getConfluencePage` (HTML format). Compute SHA-256 of the raw UTF-8 HTML.
   - Verify page version, exact HTML string, SHA-256 hash, and zero append markers match the approved artifact. If different, block immediately (never overwrite concurrent edits).
   - Update page with the exact approved resulting full HTML (`confluence.appendMode: end`).
   - Read back the page to confirm the append succeeded with exactly one marker instance and updated version.

## Outcomes
- `ready`: GitLab branch/MR and Confluence update completed and verified.
- `blocked`: Precondition hash mismatch, marker conflict, or API failure.
