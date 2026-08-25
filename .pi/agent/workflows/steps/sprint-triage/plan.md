Summarize collected tickets for two audiences. Do not mutate Git or Confluence.

Input: `{{workflow.input}}`
Collection: `{{last.summary}}`
Rejected plan: `{{gate.artifact}}`
Feedback: `{{gate.feedback}}`

Re-read `~/.pi/agent/workflows/steps/sprint-triage/sprint-triage.yaml`. Fetch the Confluence page for append context.

Submit:

# Knowledge-base (LLM)
One record per summarized ticket:

# Slack URL
# Inquiry Summary
# Action taken to mitigate the issue
# Knowledge gained from this support
# Unknown gap

# Ledger
# the date period of all supports
# support channels
# number of tickets summarized
# number of tickets skipped due to any issue

# Human guide (Confluence)
Grouped useful knowledge only:

# Brief description
# Step to take an action to support inquirer
# Links/Urls to the useful guide that is related to this certain inquiry

## Publication contract
Final KB report, ledger, and index paths; complete index content; approved MR title and description from the host template; Confluence source version/hash; exact append Markdown.

`submit` when both products are complete.
`blocked`: missing evidence or unsafe redaction.
