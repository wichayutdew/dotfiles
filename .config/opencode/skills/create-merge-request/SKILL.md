---
name: create-merge-request
description: Create and update GitLab merge requests using glab CLI. Use when raising an MR or updating an MR description.
license: MIT
compatibility: opencode
---



# GitLab Merge Request

## Creating an MR

### Step 1 - Push the branch
```bash
git push -u origin <branch-name>
```

### Step 2 - Fetch the project's MR template
```bash
glab api projects/:id --paginate=false | \
  python3 -c "import sys, json; d = json.load(sys.stdin); print(d.get('merge_requests_template', ''))" \
  > /tmp/mr_template.txt
```

**Always use `python3` for this - never `grep -o | cut | sed`.** `grep -o` silently truncates long JSON values; MR templates with FAQ sections and HTML will be cut off without any error.

If the output is `None`, the project has no template - write the description directly.

### Step 3 - Fill in the `ai-only` section

MR templates contain `<!-- ai-only-start -->` and `<!-- ai-only-end -->` markers:
- **Only modify content between these markers**
- **Preserve everything outside exactly as-is** - all `{{placeholders}}`, URLs, FAQ, `/assign me`

Use `python3` to replace the `ai-only` section:
```bash
python3 -c "
import re, sys
content = open('/tmp/mr_template.txt').read()
new_section = '''YOUR CONTENT HERE'''
result = re.sub(
    r'(?<=<!-- ai-only-start -->\n).*?(?=\n<!-- ai-only-end -->)',
    new_section,
    content,
    flags=re.DOTALL
)
print(result)
" > /tmp/mr_description.txt
```

Fill in: `JiraId`, `ExpId`, `FeatureName`, proposed changes summary, tested scenarios.
Leave for the author: screenshots, detailed test scenarios.

If no `ai-only` markers exist, keep all `{{placeholders}}` and `{variables}` intact - only fill in free-text sections.

### Step 4 - Create the MR
```bash
glab mr create \
  --title "your title" \
  --source-branch <branch> \
  --target-branch master \
  --description "$(cat /tmp/mr_description.txt)" \
  --squash-before-merge \
  --remove-source-branch \
  --yes
```

`--yes` skips interactive prompts. Always pass `--source-branch` and `--target-branch` explicitly when running from a worktree.

Always include `--squash-before-merge` and `--remove-source-branch`.

---

## Updating an MR Description

```bash
glab api projects/:id/merge_requests/<mr-iid> \
  -X PUT \
  -f "description=$(cat /tmp/mr_description.txt)"
```

---

## What to Avoid

- **Don't use `grep -o | cut | sed` to extract the template** - silently truncates long values. Always use `python3 json.load`.
- **Don't use `--fill`** - auto-fills description from commit messages, discarding the project template entirely.
- **Don't modify anything outside `ai-only` markers** - `{{placeholders}}`, URLs, FAQ, and `/assign me` are boilerplate for the author; leave them exactly as-is.
- **Don't replace `{{sourceBranch}}` or other `{{placeholders}}`** outside the `ai-only` section - they are intentional template variables, not literal values to substitute.
- **Don't omit `--squash-before-merge` and `--remove-source-branch`** - always set these on every MR.
- **Don't create the MR before pushing** - `glab mr create` will fail or target the wrong commit if the branch isn't on remote yet.
- **Don't omit `--source-branch` and `--target-branch`** when running from a worktree - `glab` may resolve the wrong branch from the detached worktree context.
