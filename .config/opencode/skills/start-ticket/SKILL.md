---
name: start-ticket
description: Start working on a JIRA ticket. Sets up the git branch, installs dependencies, and fetches ticket details.
license: MIT
compatibility: opencode
---



# Start Ticket

Setup git branch and environment for working on a JIRA ticket.

## Instructions

### 1. Get Ticket ID

If the user hasn't provided a JIRA Ticket ID (e.g., ACT-1234), ask for it.

### 2. Check Working Directory

```bash
git status --porcelain
```

If output is non-empty, **stop** and tell the user to commit or stash changes first.

### 3. Determine Base Branch

- Run `git symbolic-ref refs/remotes/origin/HEAD` and extract branch name
- If that fails, ask the user which branch to use as base

### 4. Setup Branch

```bash
# Switch to base branch if not already on it
git checkout <base_branch>

# Pull latest
git pull

# Check if ticket branch exists
git rev-parse --verify <TICKET_ID> 2>/dev/null

# If exists: checkout, else: create new branch
git checkout <TICKET_ID>        # existing branch
git checkout -b <TICKET_ID>     # new branch
```

### 5. Install Dependencies (New Branches Only)

If a **new branch was created**, detect project type and run install:

| File | Project Type | Install Command |
|------|--------------|-----------------|
| `pnpm-lock.yaml` | pnpm | `pnpm install` |
| `yarn.lock` | Yarn | `yarn install` |
| `package-lock.json` | npm | `npm install` |
| `package.json` (no lockfile) | npm | `npm install` |
| `build.sbt` | Scala/sbt | `sbt update` |
| `build.gradle` | Gradle | `./gradlew build --refresh-dependencies` |
| `requirements.txt` | Python | `pip install -r requirements.txt` |
| `pyproject.toml` | Python | `pip install -e .` |
| `go.mod` | Go | `go mod download` |

Use `Glob` to check which files exist, then run the appropriate command.

### 6. Fetch Ticket Details

Call `mcp__atlassian__jira_get_issue` with:
- `key`: The JIRA ticket ID
- `fields`: `*all`

### 7. Present to User

- Show Ticket Title and Acceptance Criteria
- Confirm branch `<TICKET_ID>` is ready
- Ask how they'd like to proceed with implementation

## Examples

**User**: "Start working on ACT-1234"

1. Check `git status --porcelain` → clean
2. Read `CLAUDE.md` → `Main Branch: develop`
3. Run `git checkout develop && git pull`
4. Run `git checkout -b ACT-1234` (new branch)
5. Found `pnpm-lock.yaml` → run `pnpm install`
6. Call `mcp__atlassian__jira_get_issue` with key=ACT-1234
7. Present: "Branch `ACT-1234` ready. Here are the requirements..."

**User**: "I want to fix ACT-999" (branch already exists)

1. Check working directory → clean
2. Detect base branch → `main`
3. Run `git checkout main && git pull`
4. Run `git checkout ACT-999` (existing branch, skip install)
5. Fetch ticket details
6. Present requirements
