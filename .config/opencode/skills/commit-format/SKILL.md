---
name: commit-format
description: Conventional commits format, branch naming, and MR description template.
---

# Commit & Branch Conventions

## Commit Message Format

```
<type>(<scope>): <short description>

<body — what and why, bullet list>

<footer — JIRA ticket ID>
```

**Types**: `feat` | `fix` | `refactor` | `test` | `docs` | `chore`

**Example**:
```
feat(export): add CSV export for user list

- Add csvGenerator utility with escaping for commas/quotes
- Add GET /api/users/export endpoint
- Add Export button to UserList with loading state

PROJ-123
```

## Branch Naming

```
<type>/<ticket>
```

Examples:
- `feature/PROJ-123`
- `fix/PROJ-456`
- `refactor/PROJ-789`

## MR Description Template

```markdown
## Summary
[One paragraph — what this MR does]

## JIRA
[PROJ-123](https://jira.company.com/browse/PROJ-123)

## Changes
- [change 1]
- [change 2]

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing done

## Checklist
- [ ] Self-reviewed
- [ ] Tests pass locally
- [ ] Lint/format checks pass
```

## Git Commands for MR Workflow

```bash
git status && git diff          # review changes
git add .                       # stage
git commit -m "feat: ..."       # commit
git push -u origin branch-name  # push (first time)
git push                        # subsequent pushes

# GitLab
glab mr create --title "..." --description "..."

# GitHub
gh pr create --title "..." --body "..."

# Conflict resolution
git pull --rebase origin main
git push --force-with-lease
```
