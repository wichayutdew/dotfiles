---
name: git-commands
description: Common git commands and workflows. Quick reference for git operations during development.
---

# Git Commands Reference

Quick reference for common git operations in your workflow.

## Branch Operations

### Create Feature Branch
```bash
# From main/master
git checkout main
git pull
git checkout -b feature/PROJ-123-description
```

### Switch Branches
```bash
git checkout branch-name
git checkout -        # switch to previous branch
```

### List Branches
```bash
git branch            # local branches
git branch -r         # remote branches
git branch -a         # all branches
```

## Making Changes

### Stage Changes
```bash
git add .                    # stage all
git add file.ts              # stage specific file
git add src/                 # stage directory
git add -p                   # interactive staging
```

### Commit
```bash
git commit -m "feat: add feature"
git commit -am "fix: quick fix"  # add + commit tracked files
```

### Amend Last Commit
```bash
git commit --amend -m "new message"
git commit --amend --no-edit      # keep same message
```

## Syncing

### Pull Changes
```bash
git pull                     # pull current branch
git pull origin main         # pull specific branch
git pull --rebase           # pull with rebase
```

### Push Changes
```bash
git push
git push -u origin branch-name   # first push, set upstream
git push --force-with-lease      # force push safely
```

## Viewing History

### Status and Diff
```bash
git status
git diff                     # unstaged changes
git diff --staged           # staged changes
git diff main...HEAD        # changes vs main
```

### Log
```bash
git log --oneline -10       # last 10 commits, short
git log --graph --oneline   # visual branch graph
git log -p file.ts          # history of specific file
```

## Undoing Changes

### Discard Unstaged Changes
```bash
git checkout -- file.ts     # discard file changes
git checkout -- .           # discard all changes
```

### Unstage Files
```bash
git reset HEAD file.ts      # unstage file
git reset HEAD              # unstage all
```

### Undo Last Commit (keep changes)
```bash
git reset --soft HEAD~1
```

### Undo Last Commit (discard changes)
```bash
git reset --hard HEAD~1
```

## Stashing

### Save Work Temporarily
```bash
git stash                   # stash changes
git stash -m "message"      # stash with message
git stash -u                # include untracked files
```

### Restore Stashed Work
```bash
git stash pop               # apply and remove
git stash apply             # apply and keep
git stash list              # list stashes
git stash drop              # remove top stash
```

## Rebasing

### Rebase on Main
```bash
git checkout feature-branch
git rebase main
```

### Interactive Rebase (squash commits)
```bash
git rebase -i HEAD~3        # last 3 commits
# Change 'pick' to 'squash' or 's' for commits to squash
```

### Resolve Conflicts During Rebase
```bash
# Fix conflicts in files
git add .
git rebase --continue
# or
git rebase --abort          # cancel rebase
```

## Creating MR/PR

### GitLab (via GitLab MCP)

Use the `gitlab_create_merge_request` MCP tool — no CLI required.

| Parameter | Description |
|-----------|-------------|
| `id` | Project path, e.g. `myorg/myrepo` |
| `title` | MR title |
| `source_branch` | Your feature branch |
| `target_branch` | Usually `main` |
| `description` | MR body (markdown) — optional |
| `reviewer_ids` | Array of reviewer user IDs — optional |
| `labels` | Comma-separated label names — optional |

Other useful GitLab MCP tools:
- `gitlab_get_merge_request` — fetch MR details by IID
- `gitlab_get_merge_request_pipelines` — check pipeline status on an MR

### GitHub
```bash
gh pr create --title "Title" --body "Description"
gh pr create --fill          # auto-fill from commits
gh pr view                   # view current PR
```

## Common Workflows

### Start New Feature
```bash
git checkout main
git pull
git checkout -b feature/PROJ-123-description
# make changes
git add .
git commit -m "feat: description"
git push -u origin feature/PROJ-123-description
```

### Update Feature Branch from Main
```bash
git checkout main
git pull
git checkout feature-branch
git rebase main
git push --force-with-lease
```

### Squash Commits Before MR
```bash
git rebase -i main
# Mark commits to squash
git push --force-with-lease
```

## Commit Message Format

```
<type>(<scope>): <description>

<body>

<footer>
```

**Types**: feat, fix, refactor, test, docs, chore

**Example**:
```
feat(export): add CSV export for users

- Add CSV generator utility
- Add export API endpoint
- Add export button to UI

PROJ-123
```

## Useful Aliases

Add to `~/.gitconfig`:

```ini
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
  lg = log --oneline --graph -10
  undo = reset --soft HEAD~1
  amend = commit --amend --no-edit
```
