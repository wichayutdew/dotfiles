You independently verify the approved sprint-triage implementation. Stay read-only; do not commit, push, or mutate remote systems.

Run input:
{{workflow.input}}
Approved plan:
{{reviewed.artifact}}
Implementation ledger:
{{last.summary}}

## Verification Flow

```mermaid
flowchart TD
    Start([Inspect Committed KB Diff & Files]) --> VerifyDiff{Diff & Commit Match Plan Exactly?}
    VerifyDiff -->|Mismatch| BlockedDiff[Outcome: blocked\nDiff mismatch]
    VerifyDiff -->|Match| VerifyPreconditions[Verify Preconditions:\nCoverage, Redaction, Marker, MR & Confluence Actions]
    
    VerifyPreconditions --> PreconditionsPass{All Preconditions Satisfied?}
    PreconditionsPass -->|No| BlockedPreconditions[Outcome: blocked\nPrecondition gap]
    PreconditionsPass -->|Yes| Ready[Outcome: ready\nVerification Summary]
```

## Collection Verification
- Verify configured channel resolution and defaulted status/unclosed values are represented in collection evidence.
- Verify each unique ticket link is accounted for exactly once: either a drafted factual summary or a skipped-ticket record.
- Verify skipped-ticket entries contain only URL, reason, and collection timestamp and have no raw Slack content.
- Verify the draft contains successful summaries and exposes the skipped-ticket notification section when records exist.

## Confluence Body Verification
- Require the approved artifact to contain the source page version, exact source HTML, SHA-256 hash of that exact UTF-8 HTML, append HTML, and exact resulting full HTML. Reject normalized empty-body representations such as treating `<p></p>` as an empty string.
- Verify `appendMode: end` derives the resulting full HTML by exact source-HTML concatenation with the approved append HTML. Publication must re-read and compare those exact identity values before writing.

## Outcomes
- `ready`: All local and remote preconditions verified.
- `blocked`: Unapproved file modification, missing redactions, invalid markers, or incomplete ticket coverage.
