You publish only the approved actions for sprint-triage. Do not launch subagents.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Verification ledger:
{{last.summary}}

## Publication Flow

```mermaid
flowchart TD
    Start([Check Remote Ref & Read Current Confluence Page]) --> PushBranch[1. Non-Force Push Committed Branch]
    PushBranch --> CreateMR[2. Create GitLab MR via API]
    CreateMR --> VerifyMR[3. Read Back & Confirm MR]
    VerifyMR --> BuildBody[4. Concatenate current HTML and approved guide]
    BuildBody --> UpdateConfluence[5. Replace page with complete resulting body]
    UpdateConfluence --> VerifyConfluence[6. Read Back Confluence Page]
    VerifyConfluence --> Ready[Outcome: ready\nComplete Publication Ledger]
```

## Guardrails
- Before Confluence mutation, read the current page in HTML and compare its version, exact source HTML, and SHA-256 hash with the approved artifact. Compute the hash from exact UTF-8 HTML returned by Atlassian MCP. Never normalize `<p></p>`, whitespace, or empty elements before comparison. If any identity value differs, block rather than overwrite concurrent edits.
- With `appendMode: end`, replace the page only with the complete approved resulting full HTML: exact approved source HTML followed by the approved decision-tree HTML. Never send a partial body.
- After updating, read back the page and verify the approved source HTML and new guide are present exactly once and the complete resulting full HTML matches exactly.
- Execute only the approved push, single MR creation, and complete Confluence body update. If an effect already exists, verify it and avoid duplication. Outcome `ready` on completion; `blocked` on ambiguity.
