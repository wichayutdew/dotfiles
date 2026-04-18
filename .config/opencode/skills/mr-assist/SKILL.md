---
name: mr-assist
description: Help MR owners with pipeline failures, merge conflicts, and reviewer feedback using research plan, implementation plan, and code changes.
license: MIT
compatibility: opencode
user-invocable: true
---


# MR Assist

Help MR owners with pipeline failures, merge conflicts, answering reviewer questions, and addressing feedback.

## Input

$ARGUMENTS

## Step 1: Get MR and Extract JIRA ID

### 1.1 Parse MR input

Extract MR IID from input `$ARGUMENTS`:
- If URL (contains `merge_requests/`), extract the number after it: `echo "$ARGUMENTS" | grep -oE 'merge_requests/[0-9]+' | grep -oE '[0-9]+'`
- If plain number, use directly

Store the extracted MR IID for subsequent commands.

```bash
# Get MR details using extracted IID
glab mr view <mr-iid> -F json
```

### 1.2 Extract JIRA ID from MR

From MR data, find JIRA ID (pattern `[A-Z]+-\d+`) in:
- MR title
- MR description
- Source branch name

## Step 2: What do you need help with?

Use `AskUserQuestion` with **multiSelect: true** to ask the user what they need help with. This is a hard gate - at least one option must be selected before proceeding.

Options:
- **Failed pipeline** - Investigate CI pipeline failures, read job logs, and help fix issues
- **Resolve conflicts** - Identify and help resolve merge conflicts with target branch
- **MR comments** - Answer reviewer questions and/or make code changes based on feedback

Only execute the steps below that correspond to the user's selections.

## Step 3: Failed Pipeline

> Only execute if user selected "Failed pipeline"

### 3.1 Get pipeline status

```bash
# List recent pipelines for the MR's source branch
glab ci list --branch <source-branch>

# Get the latest pipeline details
glab ci view <pipeline-id>
```

### 3.2 Identify failed jobs

```bash
# Get pipeline details as JSON to find failed jobs
glab ci view <pipeline-id> -F json
```

Find jobs with `failed` status.

### 3.3 Read job logs

```bash
# Get logs for each failed job
glab ci trace <job-id>
```

### 3.4 Diagnose and fix

1. **Analyze logs** - identify the root cause (compilation error, test failure, lint issue, timeout, etc.)
2. **Check code changes** - correlate failures with the MR diff
3. **Suggest fix** - propose specific code changes or configuration updates
4. **Apply fix** if user agrees:
   ```bash
   git add <files>
   git commit -m "fix(<scope>): <description>"
   git push
   ```

## Step 4: Resolve Conflicts

> Only execute if user selected "Resolve conflicts"

### 4.1 Check for conflicts

Check MR JSON for `has_conflicts: true` and `merge_status` field.

```bash
# Fetch latest remote state
git fetch origin
```

### 4.2 List conflicting files

```bash
# Attempt merge to surface conflicts (without committing)
git merge origin/<target-branch> --no-commit --no-ff
```

If conflicts exist, list them:

```bash
git diff --name-only --diff-filter=U
```

### 4.3 Resolve conflicts

For each conflicting file:
1. **Read the file** to see conflict markers
2. **Understand both sides** - check the MR's intent vs incoming changes
3. **Use research/implementation artifacts** if available to understand intent
4. **Confirm resolution** with user via `AskUserQuestion` before applying
5. **Apply resolution** using `Edit` tool

### 4.4 Complete merge

```bash
git add <resolved-files>
git commit -m "fix: resolve merge conflicts with <target-branch>"
git push
```

## Step 5: MR Comments

> Only execute if user selected "MR comments"

### 5.1 Load artifacts

#### Research plan

Read `.claude/output/research/<jira-id>.md`:
- Overview
- Current State Analysis
- Desired End State
- What We're NOT Doing
- Implementation Approach
- Success Criteria

#### Implementation plan

Read `.claude/output/implementation_progress/<jira-id>.md`:
- Phases completed
- Decisions made
- Any blockers noted

#### Code changes

```bash
# Get MR diff using extracted IID
glab mr diff <mr-iid>
```

#### MR comments and discussions

```bash
# Get flat comments
glab mr view <mr-iid> --comments -F json

# Get threaded discussions (for reviewer threads)
glab api projects/:id/merge_requests/<mr-iid>/discussions --paginate
```

### 5.2 Answer reviewer questions

When user shares a reviewer question:

1. **Search artifacts first** - research plan and implementation plan
2. **Check code changes** - trace through the diff
3. **Formulate response** with `file_path:line_number` references
4. **Quote relevant sections** from research/implementation plans

### 5.3 Make changes (when requested)

If user asks to address feedback:

1. **Confirm scope** with `AskUserQuestion`
2. **Make edits** using `Edit` tool
3. **Commit**:
   ```bash
   git add <files>
   git commit -m "fix(<scope>): <description>"
   ```
4. **Push**:
   ```bash
   git push
   ```

### 5.4 Reply to MR (optional)

```bash
# Reply using extracted IID
glab mr note <mr-iid> -m "<response>"
```
