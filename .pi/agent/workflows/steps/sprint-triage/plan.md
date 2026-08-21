You are the approval-planning stage for sprint-triage publication. Stay read-only; do not launch subagents.

Run input:
{{workflow.input}}
Draft ledger:
{{last.summary}}
Canonical configuration path:
`/Users/wphongphanpa/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`
Previously rejected artifact:
{{gate.artifact}}
Plannotator feedback:
{{gate.feedback}}

## Planning Flow

```mermaid
flowchart TD
    Start([Inspect draft ledger, redactions, and local sprint-triage.yaml]) --> CheckTargets{Configured targets valid?}
    CheckTargets -->|Missing / conflicting| BlockedState[Outcome: blocked]
    CheckTargets -->|Valid| DraftPlan[Draft publication plan artifact]
    DraftPlan --> PlannotatorSubmit[Outcome: submit via Plannotator]
```

## Publication Target Contract
- Re-read `/Users/wphongphanpa/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`; the draft ledger is not the source of publication targets.
- Read `SPRINT_TRIAGE_COLLECTION_LEDGER.md` from the bound worktree. Block unless it proves the configured `grafana.channel`, `ticketStatus`, and `includeAllUnclosed` values; dataset request variables and row count; every ordered unique ticket URL; and exactly one summarized/skipped disposition per URL. Include its full SHA-256 and a compact URL/disposition accounting table in the submitted artifact.
- Use Atlassian MCP `getConfluencePage` with `confluence.pageId` and HTML content immediately before drafting publication. Treat its returned body as exact UTF-8 HTML bytes: hash that exact string with SHA-256 and record the source HTML, page version, hash, retrieval timestamp, and zero append-marker occurrences in the submitted artifact. Never normalize `<p></p>`, whitespace, or empty elements to another representation. With `confluence.appendMode: end`, the approved Confluence body is the exact source HTML followed by the approved decision-tree HTML. Record the exact resulting full HTML. Block only when the page cannot be read or append mode is unsupported.
- Use `gitlab.targetBranch` as the MR target branch.
- When the configured knowledge-base repository has no convention or tracked files, create the AI-readable convention: one Markdown file per sprint at `<contentDirectory>/<start-date>_to_<end-date>.md`, plus `<indexFile>` linking each report in reverse chronological order. Each repository ticket record contains only Slack URL, inquiry summary, action taken to mitigate the issue, knowledge gained from this support, and unknown gap. Skipped records contain URL, skip reason, and collection timestamp only.
- The Confluence append contains only inquiry topic and steps to take an action to resolve the inquiry. Include useful verified guide/runbook/ticket links in those steps when explicitly mentioned in source evidence and they guide triage, mitigation, escalation, or content enhancement. Omit one-off/non-repeatable tickets from Confluence.
- The complete path, index update, source page version/source HTML/SHA-256 body hash, and exact resulting full HTML must appear in the submitted artifact.

## Plan Structure
1. `# Publish reviewed sprint triage knowledge`
2. `## Submitted evidence capture` (collection-ledger SHA-256, configured/resolved query values, row count, URL/disposition accounting, Confluence retrieval timestamp, version, exact HTML, SHA-256, and zero append-marker occurrences)
3. `## Evidence and coverage` (completeness and stated limitations)
4. `## Approved local content` (exact file paths and complete contents)
5. `## Approved GitLab action` (push ref, MR title, MR description)
6. `## Approved Confluence action` (page ID, append marker, exact append body)

## Outcomes
- `submit`: Plan submitted for Plannotator gate review only when the submitted artifact contains the complete `Submitted evidence capture`; unsupported FACT claims are `blocked`.
- `blocked`: Unsafe gaps, marker conflicts, or incomplete redactions.
