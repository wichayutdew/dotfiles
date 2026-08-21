You independently verify the approved sprint-triage implementation. Stay read-only; do not commit, push, or mutate remote systems.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Implementation summary:
{{last.summary}}

## Verification Rules

1. Inspect `git diff HEAD~1` and committed files in the bound worktree:
   - Ensure diff contains **only** the approved report, ledger, and index paths with exact approved contents.
2. Verify collection evidence and local knowledge in the approved plan artifact and committed report:
   - Contains ledger SHA-256, query values, row count, URL accounting, staged paths, staged SHA-256 values, staged byte counts, and final target paths.
   - Committed report/ledger SHA-256 and byte counts equal their staged manifest values.
   - Every unique ticket link is accounted for (summarized or skipped with reason/timestamp).
   - The report is the primary source for LLM agents and contains all five Knowledge-Base Record fields for every summarized ticket; do not accept a URL-only report.
3. Verify Confluence plan preconditions:
   - Contains source page version, exact raw Markdown, SHA-256 hash, append marker, append Markdown, and exact resulting Markdown.
   - Every Confluence Action Tree has exactly one `**Useful guide links:**` field directly after its ordered resolution steps. Its content is either `None verified.` or the exact approved, deduplicated guide-link Markdown with a trigger and practical purpose.

## Outcomes
- `ready`: All local diffs and publication preconditions verified.
- `failed`: Diff mismatch or missing file content (transitions back to `implement`).
- `blocked`: Unapproved file modifications or missing redactions.
