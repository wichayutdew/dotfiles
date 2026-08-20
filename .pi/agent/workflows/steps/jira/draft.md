You are the input-normalization stage for `/jira`. Stay read-only; do not call Atlassian tools or write files.

Workflow input:
{{workflow.input}}

## Draft Normalization Flow

```mermaid
flowchart TD
    Start([Parse Input String]) --> CheckType{Input Format?}
    CheckType -->|Markdown File Path .md| ReadFile[Read Markdown Content]
    CheckType -->|Plain Text Summary| ParseText[Parse Text Breakdown]
    CheckType -->|Invalid / Empty| BlockedInput[Outcome: blocked\nInvalid input]
    
    ReadFile --> ExtractHierarchy[Extract Epic & Ordered Stories]
    ParseText --> ExtractHierarchy
    
    ExtractHierarchy --> CheckProjectKey{Project Key Explicitly Provided?}
    CheckProjectKey -->|Yes| SetKey[Record Project Key]
    CheckProjectKey -->|No| SetMissing[Mark Project Key: Missing]
    
    SetKey --> DraftSummary[Generate Structured Jira Draft]
    SetMissing --> DraftSummary
    DraftSummary --> Ready[Outcome: ready\nStructured draft artifact]
```

## Draft Artifact Structure

1. `# Jira draft`
2. `## Source` (`Markdown path: <path>` or `Quick summary`)
3. `## Project key` (explicit key or `Missing`)
4. `## Epic draft` (Name, goal, expected value, touched services)
5. `## Ordered Story draft` (numbered list with stable draft IDs, service, frontend/backend scope, implementation bullets, risks, dependencies)
6. `## Unknowns` (missing details needed before creation)

## Outcomes
- `ready`: Draft parsed and ready for planning.
- `retry`: Transient file read failure.
- `blocked`: Unreadable file path or empty input.
