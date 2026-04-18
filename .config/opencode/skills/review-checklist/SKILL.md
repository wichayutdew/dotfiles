---
name: review-checklist
description: Code review checklist, severity levels, and language-specific patterns. Load when reviewing code for quality and security.
---

# Code Review Reference

Consult `context7` and `agoda_skills` when unsure about best practice.

## Before Reviewing

1. Fetch MR diff via `gitlab_get_merge_request_diffs` MCP (or `git diff` / `git diff --staged` locally)
2. Detect language: look for `*.scala`, `*.kt`, `*.ts`, `*.py`
3. For Scala: apply scala-specific rules (pattern match over if/else, sealed types, for-comprehensions)
4. Focus only on changed code — not the entire file

## Severity Levels

| Symbol | Level | Action |
|--------|-------|--------|
| 🔴 | Critical — security or crash risk | Must fix before merge |
| 🟠 | Major — bug or significant issue | Should fix |
| 🟡 | Minor — code smell or style | Consider fixing |
| 🔵 | Suggestion — enhancement | Optional |
| 💚 | Praise — good code | None needed |

## Review Checklist

**Security** 🔴
- [ ] No hardcoded secrets or credentials
- [ ] Input validated before use
- [ ] No SQL/command injection risk
- [ ] Auth checks in place
- [ ] Errors don't leak internals

**Correctness** 🟠
- [ ] Edge cases handled (empty, null, 0, max)
- [ ] Async/concurrent code is safe
- [ ] Error paths handled completely
- [ ] No logic inversions
- [ ] No catching broad exceptions (`Throwable`, bare `catch`)

**Design** 🟡
- [ ] Functions small and focused (< 80 lines)
- [ ] No duplication — DRY
- [ ] No magic numbers — named constants
- [ ] Separation of concerns respected
- [ ] Immutability used where possible

**Code Quality** 🟡
- [ ] Names clear and consistent with codebase
- [ ] No dead code or commented-out blocks
- [ ] TODOs reference a ticket
- [ ] No unnecessary whitespace changes on unrelated lines

**Performance** 🟡
- [ ] No N+1 queries
- [ ] Resources (connections, streams) properly closed
- [ ] No unnecessary allocations in hot paths

**Testability** 🔵
- [ ] Dependencies injectable
- [ ] No hidden global state
- [ ] Critical paths have tests

## Output Format

```markdown
## Code Review

**Overall**: ✅ Looks Good | ⚠️ Needs Changes | ❌ Significant Issues
**Summary**: 🔴 N  🟠 N  🟡 N  🔵 N

### Issues

#### 🔴 [Title]
**File**: `path/to/file.ts:42`
**Problem**: [what's wrong and why it matters]
**Fix**: [corrected code]

### What's Good 💚
- [specific praise]

### Must fix: [list]
### Recommended: [list]
```
