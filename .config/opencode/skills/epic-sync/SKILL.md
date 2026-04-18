---
name: epic-sync
description: Sync shared Epic context from Confluence. Loads or bootstraps a context page for a Jira Epic ID (ACT-XXX), caches locally at ~/.claude/context/, and supports version-aware refresh. Use when starting work on an epic, refreshing context mid-sprint, or priming a session before /research or /implement.
license: MIT
compatibility: opencode
user-invocable: true
---


# Epic Sync

Load shared team context for an Epic from Confluence into the local cache.
Multiple contexts can coexist — `/research` auto-matches the right one from the Jira ticket's Epic ID via the `jira-context-fetcher` agent.

## Configuration

| Setting | Value |
|---|---|
| Confluence space | `ACV` (space ID: `165445635`) |
| Parent page | [EPIC Context - AI](https://agoda.atlassian.net/wiki/spaces/ACV/pages/2170552544) (page ID: `2170552544`) |
| Page title convention | `<epic-id> — <Feature Name>` (e.g., `ACT-5975 — Airport Transfer Filters`) |
| Local cache path | `~/.claude/context/<epic-id>.md` |

## Instructions

### 1. Parse Key

Read the key from $ARGUMENTS:

- Must match `ACT-\d+` — this skill only works with Jira Epic IDs.
- If no key provided, ask:

```
AskUserQuestion: "Enter the Epic ID (e.g., ACT-5975):"
```

### 2. Search Confluence

Search for an existing context page:

```
confluence_search_page(text: "<epic-id>", space: "ACV")
```

- Search by Epic ID only — do NOT include the feature name. The Epic ID is the reliable identifier; feature names may have typos.
- If results are found, match on the Epic ID prefix in the title (e.g., title starts with `ACT-5975`).

- **Page found** → go to **Step 3** (Load Existing Context)
- **No page found** → go to **Step 4** (Bootstrap New Context)

### 3. Load Existing Context

Fetch the full page content:

```
confluence_get_page(page_id: "<matched-page-id>")
```

- Save the content to `~/.claude/context/<epic-id>.md` with a version marker on the first line:
  ```
  <!-- confluence-version: N -->
  ```
  Where N is `version.number` from the Confluence response.

- Create the directory if needed:
  ```bash
  mkdir -p ~/.claude/context
  ```

- Display a summary to the user:
  - Epic ID, page title, Confluence version
  - Key sections found (Architecture, Key Files, Domain Model, etc.)
  - Stories completed count (if present)
- Confirm:

```
Context loaded: <epic-id> → ~/.claude/context/<epic-id>.md (Confluence version N)
/research will automatically use this context for stories belonging to this Epic.
```

Done — stop here.

### 4. Bootstrap New Context

Only reached if no Confluence page exists for this Epic.

#### 4a. Enrich from Jira

Call `mcp__plugin_agoda-skills_at__getJiraIssue`:
- `issueIdOrKey`: the epic ID
- Extract: `summary` (title), `description` (for one-liner)

#### 4b. Ask for description

```
AskUserQuestion: "No context exists for <epic-id> yet. Provide a one-line description of this Epic:"
```

Use the Jira summary as the title if available. Use the user's answer as the one-liner description.

#### 4c. Build and publish the context page

Create a Confluence page under the parent:

```
confluence_create_page(
  space_id: "165445635",
  title: "<epic-id> — <jira-summary or user-provided title>",
  parent_id: "2170552544",
  content: <template below>,
  content_format: "markdown"
)
```

Template content:

```markdown
# <epic-id>: <title>
> <one-liner description>

> Last updated: <today YYYY-MM-DD>

## Architecture & Key Decisions

_Nothing recorded yet._

## Key Files & Entry Points

_Nothing recorded yet._

## Domain Model

_Nothing recorded yet._

## Stories Completed

| Story | Summary | MR |
|-------|---------|-----|

## Open Questions

_None yet._

## Out of Scope

_Nothing explicitly deferred yet._
```

#### 4d. Cache locally

Save the same content to `~/.claude/context/<epic-id>.md` with the version marker:

```bash
mkdir -p ~/.claude/context
```

Write `<!-- confluence-version: 1 -->` as the first line, followed by the template content.

#### 4e. Confirm

```
Created context for <epic-id> → published to Confluence and cached locally.
/research will automatically use this context for stories belonging to this Epic.
```

---

## Updating Context After a Session (Reference)

After a research or implementation session, update the Confluence page with new findings:

1. Read the local cache: `~/.claude/context/<epic-id>.md`
2. Search Confluence for the page: `confluence_search_page(text: "<epic-id>", space: "ACV")`
3. Update the page:

```
confluence_update_page(
  page_id: "<page-id>",
  title: "<existing-title>",
  content: <updated content>,
  content_format: "markdown",
  version_comment: "update context from <ticket-id> session"
)
```

4. Update the local cache version marker to match the new version number.

This is intentionally a manual step — the engineer decides what findings are worth persisting.
