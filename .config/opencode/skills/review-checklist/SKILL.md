---
name: review-checklist
description: Code review dimensions, severity levels, and checklist. Load when reviewing code for quality and security.
---

# Code Review Reference

consult with `context7` and `agoda_skills` when you are unsure with some coding best practice

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

**Performance** 🟡
- [ ] No N+1 queries
- [ ] No unnecessary allocations in hot paths
- [ ] Appropriate caching

**Code Quality** 🟡
- [ ] Functions are small and focused
- [ ] Names are clear and consistent
- [ ] No dead code or commented-out blocks
- [ ] No duplication (DRY)

**Testability** 🔵
- [ ] Dependencies are injectable
- [ ] No hidden global state
- [ ] Pure functions where possible

## Output Format

```markdown
## Code Review

**Overall**: ✅ Looks Good | ⚠️ Needs Changes | ❌ Significant Issues
**Summary**: 🔴 N  🟠 N  🟡 N  🔵 N

### Issues

#### 🔴 [Title]
**File**: `path/to/file.ts:42`
**Problem**: [what's wrong and why]
**Fix**:
```lang
[corrected code]
```

### What's Good 💚
- [specific praise]

### Must fix: [list]
### Recommended: [list]
```
