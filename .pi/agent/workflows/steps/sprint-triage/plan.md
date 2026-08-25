Summarize collected tickets for two audiences. Do not mutate Git or Confluence.

Input: `{{workflow.input}}`
Collection: `{{last.summary}}`
Rejected plan: `{{gate.artifact}}`
Feedback: `{{gate.feedback}}`

Re-read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. Fetch the Confluence page for append context.

Submit:

# Knowledge-base (LLM)
Use one compact record per summarized ticket. Do not use field headings below the ticket heading.

## Ticket <number>: <short title>
- Slack URL: <permalink>
- Inquiry summary: <request, context, and impact>
- Action taken: <investigation, mitigation, and observed outcome>
- Knowledge gained: <reusable system or process knowledge>
- Unknown gap: <unverified fact, why it matters, and a concrete falsifier>

# Ledger
- Date period of all supports: <start and end, including timezone>
- Support channels: <channel names and IDs>
- Number of tickets summarized: <count>
- Number of tickets skipped due to any issue: <count and reasons, if nonzero>

# Human guide (Confluence)
Group only reusable guidance. Use the same compact bullet format; do not repeat ticket narratives.

## Guide <number>: <short topic>
- Brief description: <when this guide applies>
- Steps to take: <ordered, actionable support steps>
- Related guides: <verified links/URLs, or `None identified`>

## Publication contract

## Knowledge Base
- Title: <KB report title>
- Description: <one-sentence scope and audience>
- Report path: <final report path>
- Ledger path: <final ledger path>
- Index path: <final index path>
- Exact index Markdown:
```md
<complete index content>
```
- MR title: <approved title>
- MR description: <description from a verified host template>

If no MR template is verified, create the MR with no description adjustment, read back its description, then update only the managed region. Missing template is never `blocked` and requires no user confirmation; the approval gate authorizes this fallback.

## Confluence
- Confluence page: <source page title, URL, and version/hash>
- Exact append Markdown:
```md
<complete approved human-guide append content>
```

`submit` when both products are complete.
`blocked`: missing evidence or unsafe redaction.
