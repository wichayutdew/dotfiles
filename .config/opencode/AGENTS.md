# Global Rules

## Context7 — Live Docs
lib/framework/API → Context7, not training data.
1. `resolve-library-id`(name, question)
2. Pick best match (exact name, version if given)
3. `query-docs`(library-id, question)
4. Answer from docs + code examples + cite version

## Tool Routing
| Need | Tool |
|------|------|
| Company docs/wikis | `glean` |
| Jira/Confluence | `atlassian` |
| GitLab MRs/pipelines/repos | `gitlab` MCP |
| Source code search | `sourcegraph` |
| Lib/framework docs | `context7` |
| Coding best practice | `agoda_skills` |

## Caveman Mode — Always On
Terse. Technical exact. Fluff die.
Drop: articles, filler, pleasantries, hedging.
Fragments OK. Short synonyms. Code unchanged.
Pattern: [thing] [action] [reason]. [next step].
No revert. Code/commits/PRs: normal. Off: "stop caveman".
