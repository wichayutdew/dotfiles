---
name: create-merge-request
description: Create and update GitLab merge requests. Use GitLab MCP for MR creation; bash for branch push and template fetch. Use when raising an MR or updating an MR description.
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

Use the GitLab MCP tool:

```
Tool: gitlab_create_merge_request
{
  "id": "<project-id-or-path>",
  "title": "<your title>",
  "source_branch": "<branch>",
  "target_branch": "master",
  "description": "<contents of /tmp/mr_description.txt>",
  "squash": true,
  "should_remove_source_branch": true
}
```

Always set `squash: true` and `should_remove_source_branch: true`.

---

## Updating an MR Description

```
Tool: gitlab_get_merge_request  (read current MR first)
{ "id": "<project-id-or-path>", "merge_request_iid": <MR_IID> }
```

Then update via GitLab MCP — use `gitlab_create_merge_request` with the same IID is not available for updates; use the GitLab REST API via bash if the MCP doesn't expose an update endpoint:

```bash
curl -X PUT "<gitlab-host>/api/v4/projects/<project-id>/merge_requests/<mr-iid>" \
  -H "Authorization: Bearer $GITLAB_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"description\": $(cat /tmp/mr_description.txt | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')}"
```

---

## What to Avoid

- **Don't use `grep -o | cut | sed` to extract the template** — silently truncates long values. Always use `python3 json.load`.
- **Don't modify anything outside `ai-only` markers** — `{{placeholders}}`, URLs, FAQ, and `/assign me` are boilerplate for the author; leave them exactly as-is.
- **Don't replace `{{sourceBranch}}` or other `{{placeholders}}`** outside the `ai-only` section — they are intentional template variables, not literal values to substitute.
- **Don't omit `squash: true` and `should_remove_source_branch: true`** — always set these on every MR.
- **Don't create the MR before pushing** — MR creation will fail or target the wrong commit if the branch isn't on remote yet.
