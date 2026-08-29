Implement the approved plan in the bound worktree.

Request: `{{workflow.input}}`
Approved plan: `{{reviewed.artifact}}`
Feedback: `{{reviewed.feedback}}`
Ledger: `{{last.summary}}`

Stay in `repositories[0].cwd`. Run only `worker` commands. Use TDD only for tests listed with an assessable benefit. Do not add tests to justify extra code. Leave pre-existing dirty files alone. Do not push, open reviews, or mutate Jira.

Work in bounded checkpoints. At the start of each pass, inspect the bound worktree and the previous step handoff, then select one coherent remaining slice of the approved plan. Implement and test only that slice. Commit it before returning. Keep the handoff compact and name the completed commit, focused red/green evidence, and the exact remaining approved slices.

Call `structured_output` exactly once before reaching the tool-call allowance. When approved work remains after the committed slice, return `checkpoint`; do not attempt further slices. If the allowance is approaching before a coherent slice can be completed and committed, return `blocked` with the exact blocker rather than settling without completion.

`checkpoint`: red/green evidence and a commit for one coherent slice; remaining approved work is explicitly listed in the handoff.
`ready`: every approved implementation slice is complete, with red/green evidence and commits. Pass the JSON contract unchanged.
`retry`: transient tool failure.
`blocked`: missing authority, unrecoverable failure, or insufficient remaining tool calls to complete a coherent checkpoint.
