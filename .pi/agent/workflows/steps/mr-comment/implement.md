Apply only approved comment verdicts.

Input: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Feedback: `{{reviewed.feedback}}`
Ledger: `{{last.summary}}`

Run only `workerCommands`. Reply-only plans: no commit. Do not push or reply here.

A parent recovery `handoff` is unconfirmed context, not proof that local work or a reply is complete. Reconcile the approved verdicts, plan, and ledger before returning a valid outcome; do not infer progress from it.

`ready`: local work done; pass the JSON contract.
`retry`: transient tool failure.
`blocked`: unapproved command required.
