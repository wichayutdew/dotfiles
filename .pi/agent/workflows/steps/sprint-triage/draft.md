You draft redacted knowledge summaries from collected OpsBot support tickets. Do not modify repositories, commit, push, or publish. Create only a temporary staged knowledge-base bundle as required below; it is machine-validated content, not a human review artifact.

Run input:
{{workflow.input}}
Collection summary:
{{last.summary}}

## Required Artifacts per Ticket

1. **Knowledge-Base Record (5 fields):** Use these exact bold labels once per summarized ticket:
   - **Slack URL:**
   - **Inquiry summary:** what was asked/observed, grounded in thread.
   - **Action taken to mitigate the issue:** ordered actions, verified outcome, and useful links; or `no verified mitigation`.
   - **Knowledge gained from this support:** reusable takeaway with verified references; or `case-specific; no reusable knowledge`.
   - **Unknown gap:** explicit `UNKNOWN` gaps.

2. **Confluence Action Tree (2 fields):** Use these exact bold labels once per human guide:
   - **Inquiry topic:**
   - **Steps to take an action to resolve the inquiry:** ordered resolution steps.
   *(Omit Slack URLs, ticket IDs, metrics, or one-off narratives from Confluence. Group equivalent inquiries; omit tickets with no repeatable mitigation).*

When `skippedTickets` exists, include their URL, reason, and timestamp in the repository report only.

The local knowledge-base report is the primary source for LLM agents and must contain every summarized ticket's complete five-field Knowledge-Base Record. Confluence is the human triage location; its grouped action trees are supplemental and must not replace local Knowledge-Base Records.

## Staged Knowledge-Base Bundle

1. Create one private directory with `mktemp -d /tmp/sprint-triage.XXXXXX`.
2. Write final UTF-8/LF `report.md` containing scope and every complete five-field Knowledge-Base Record; write final UTF-8/LF `ledger.md` containing the verbatim Collection Ledger.
3. Compute SHA-256 and byte count for both files. Do not modify or delete the directory after producing the handoff.
4. The bundle is the canonical LLM knowledge source. It is not embedded in the Plannotator artifact.

## Required Ready Handoff

Return only:

1. `## Collection Ledger` — reproduce the collection ledger from `{{last.summary}}` verbatim.
2. `## Staged Knowledge-Base Manifest` — directory, report/ledger absolute paths, SHA-256, byte counts, and summarized-ticket count.
3. `## Draft Summaries` — complete Confluence Action Trees only, using the exact two bold labels above. Do not repeat Knowledge-Base Records.

## Artifact limit
Keep the handoff concise and at most 20,000 characters. Preserve all Confluence guide fields and manifest values; remove repeated process narrative before removing evidence.

## Outcomes
- `ready`: Complete ledger, hash-verified staged bundle, and complete Confluence Action Trees.
- `blocked`: Missing, ambiguous, or untraceable dataset evidence.
