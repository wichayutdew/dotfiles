You are the approval-planning stage for sprint-triage publication. Stay read-only; do not launch subagents.

Run input:
{{workflow.input}}
Draft summary:
{{last.summary}}
Previously rejected artifact:
{{gate.artifact}}
Plannotator feedback:
{{gate.feedback}}

## Planning Contract

1. Re-read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`.
2. Read `## Collection Ledger` and `## Draft Summaries` from `{{last.summary}}`. Require the Collection Ledger to be reproduced verbatim from collection. Verify it proves the configured `grafana.channel`, `ticketStatus`, `includeAllUnclosed`, query variables, row count, and URL dispositions. Calculate its SHA-256 from the exact handoff text. Do not read or create `SPRINT_TRIAGE_COLLECTION_LEDGER.md`, `SPRINT_TRIAGE_DRAFT.md`, or any other local draft artifact.
3. Call Atlassian MCP `getConfluencePage` (`confluence.pageId`, HTML format). Treat returned body as exact UTF-8 HTML bytes; compute its SHA-256 hash. Record source HTML, page version, hash, retrieval timestamp, and verify zero occurrences of the append marker. Never normalize `<p></p>` or whitespace.
4. Construct the complete full resulting HTML by concatenating the exact source HTML with the approved append HTML.
5. For empty or convention-free KB repositories, specify the standard files:
   - Report: `<contentDirectory>/<start-date>_to_<end-date>.md`
   - Ledger: `<contentDirectory>/<start-date>_to_<end-date>.ledger.md`
   - Index: `<indexFile>` (reverse-chronological links)
6. **Plan Draft & Artifact Submission:** Save the plan draft to `~/.plannotator/plans/` (or current directory `PLAN.md`). When completing the step with outcome `submit`, **pass the complete Markdown text content of the plan directly in the `artifact` parameter**. Do not pass a file path as the artifact.

## Plan Structure
1. `# Publish reviewed sprint triage knowledge`
2. `## Collection Ledger` (complete verbatim handoff ledger)
3. `## Draft Summaries` (complete redacted handoff draft)
4. `## Submitted evidence capture` (ledger SHA-256, query values, row count, URL accounting, Confluence retrieval time, version, exact raw HTML, SHA-256, marker count)
5. `## Evidence and coverage` (completeness and limitations)
6. `## Approved local content` (exact repository file paths and complete contents for report, ledger, and index; the only local content that may enter the worktree after approval)
7. `## Approved GitLab action` (push ref, MR title, MR description)
8. `## Approved Confluence action` (page ID, append marker, exact append body, exact resulting full HTML)

## Outcomes
- `submit`: Complete plan artifact passed in the `artifact` parameter for Plannotator gate review.
- `blocked`: Unsafe gaps, missing evidence, or incomplete redactions.
