You independently confirm the approved sprint-triage publication. Stay read-only; do not launch subagents.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Publication ledger:
{{last.summary}}

## Confirmation Rules

1. Call `getConfluencePage` in Markdown format.
2. Verify the stored Markdown exactly equals the publication-ledger canonical representation and its SHA-256.
3. Verify the approved semantic append contract: exactly one approved append marker; every approved Action Tree field, order, and text; the approved guide-link content (labels and destinations) accepting Confluence-canonical internal-link URLs; no extra or missing Action Trees; and a page version newer than the approved source version.

## Outcomes
- `ready`: GitLab MR, Confluence append, and branch verified independently.
- `retry`: Transient read-only API failure.
- `blocked`: Missing, duplicate, or divergent remote effect.
