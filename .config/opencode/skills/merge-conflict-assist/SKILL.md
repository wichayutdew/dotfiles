---
name: merge-conflict-assist
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

Extract MR IID from `$ARGUMENTS`:
- If URL (contains `merge_requests/`), parse the number after it
- If plain number, use directly

```
Tool: gitlab_get_merge_request
{ "id": "<project-id-or-path>", "merge_request_iid": <MR_IID> }
```

### 1.2 Extract JIRA ID from MR

From MR data, find JIRA ID (pattern `[A-Z]+-\d+`) in:
- MR title
- MR description
- Source branch name

## Step 2: What do you need help with?

Ask the user (multiSelect) what they need help with before proceeding:

- **Failed pipeline** — Investigate CI pipeline failures, read job logs, and help fix issues
- **Resolve conflicts** — Identify and help resolve merge conflicts with target branch
- **MR comments** — Answer reviewer questions and/or make code changes based on feedback

Only execute the steps below that correspond to the user's selections.

## Step 3: Failed Pipeline

> Only execute if user selected "Failed pipeline"

### 3.1 Get pipeline status

```
Tool: gitlab_get_merge_request_pipelines
{ "id": "<project-id-or-path>", "merge_request_iid": <MR_IID> }
```

Find the latest pipeline. Then get its jobs:

```
Tool: gitlab_get_pipeline_jobs
{ "id": "<project-id-or-path>", "pipeline_id": <PIPELINE_ID> }
```

### 3.2 Identify failed jobs

Find jobs with `failed` status from the pipeline jobs response.

### 3.3 Read job logs

For each failed job, fetch its log via:

```
Tool: gitlab_get_pipeline_jobs
{ "id": "<project-id-or-path>", "pipeline_id": <PIPELINE_ID> }
```

The job response includes a `web_url` — open it to read the trace, or look for a `log` / `trace` field.

### 3.4 Diagnose and fix

1. **Analyze logs** — identify root cause (compilation error, test failure, lint issue, timeout, etc.)
2. **Check code changes** — correlate failures with the MR diff
3. **Suggest fix** — propose specific code changes or configuration updates
4. **Apply fix** if user agrees using the Edit tool, then commit and push

## Step 4: Resolve Conflicts

> Only execute if user selected "Resolve conflicts"

### 4.1 Check for conflicts

From the MR data in Step 1, check `has_conflicts` and `merge_status` fields.

```bash
git fetch origin
```

### 4.2 List conflicting files

```bash
git merge origin/<target-branch> --no-commit --no-ff
git diff --name-only --diff-filter=U
```

### 4.3 Resolve conflicts

For each conflicting file:
1. **Read the file** to see conflict markers
2. **Understand both sides** — check the MR's intent vs incoming changes
3. **Confirm resolution** with user before applying
4. **Apply resolution** using Edit tool

### 4.4 Complete merge

```bash
git add <resolved-files>
git commit -m "fix: resolve merge conflicts with <target-branch>"
git push
```

## Step 5: MR Comments

> Only execute if user selected "MR comments"

### 5.1 Load context

#### MR diff

```
Tool: gitlab_get_merge_request_diffs
{ "id": "<project-id-or-path>", "merge_request_iid": <MR_IID> }
```

#### MR comments and discussions

```
Tool: gitlab_get_workitem_notes
{ "project_id": "<project-id-or-path>", "work_item_iid": <MR_IID> }
```

#### Research / implementation notes

If research or implementation notes exist in the repo (check `.claude/`, `docs/`, or project wiki), read them for context. Otherwise proceed from MR diff + Jira ticket.

### 5.2 Answer reviewer questions

When user shares a reviewer question:

1. **Search context** — MR diff, notes, any available docs
2. **Check code changes** — trace through the diff
3. **Formulate response** with `file_path:line_number` references

### 5.3 Make changes (when requested)

If user asks to address feedback:

1. **Confirm scope** with user
2. **Make edits** using Edit tool
3. **Commit and push**:
   ```bash
   git add <files>
   git commit -m "fix(<scope>): <description>"
   git push
   ```

### 5.4 Reply to MR (optional)

```
Tool: gitlab_create_workitem_note
{
  "project_id": "<project-id-or-path>",
  "work_item_iid": <MR_IID>,
  "body": "<response>"
}
```
