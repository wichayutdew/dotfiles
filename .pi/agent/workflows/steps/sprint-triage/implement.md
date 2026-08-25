Write and commit only the approved knowledge-base files.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Feedback: `{{reviewed.feedback}}`

Write the LLM report, ledger, and index exactly as approved. No extra files. Commit with the approved message. Do not push.

`ready`: files committed.
`blocked`: path or hash mismatch.
