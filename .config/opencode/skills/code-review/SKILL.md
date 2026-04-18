---
name: code-review
description: Review code for quality, style, and best practices. Use when reviewing merge requests, code changes, or when the user asks for code review. Supports Scala, TypeScript, Python, and general code review.
license: MIT
compatibility: opencode
---


# Code Review

Perform comprehensive code reviews focusing on code quality, maintainability, security, and adherence to language-specific style guides.

## Instructions

### 1. Understand the Context

First, identify what needs to be reviewed:

- If reviewing an MR: Use `glab mr view <number>` to get changed files
- If reviewing specific files: Note the file paths provided by the user
- If reviewing current changes: Use `git diff` to see unstaged changes or `git diff --staged` for staged changes

### 2. Detect Primary Language

Identify the primary language being reviewed:

```bash
# For Scala
fd -e scala . | head -1

# For TypeScript/JavaScript
fd -e ts -e tsx . | head -1

# For Python
fd -e py . | head -1
```

### 3. Load Language-Specific Style Guide

Based on the detected language, read the appropriate style guide:

- **For Scala code**: Read `${SKILL_ROOT}/references/scala_code_style.md` for detailed Scala style rules, naming conventions, and best practices
- **For TypeScript/JavaScript**: Apply modern TypeScript standards (type safety, immutability, functional patterns)
- **For Python**: Apply PEP 8 standards and Python best practices

### 4. Review Checklist

Apply these review criteria across all languages:

#### Code Quality
- **Readability**: Are variable/function names meaningful and clear?
- **Complexity**: Are functions too long or doing too much? (Keep functions focused and under 80 lines)
- **DRY Principle**: Is there duplicated code that should be extracted?
- **Magic Numbers**: Are constants properly named and defined?
- **Comments**: Are complex sections properly documented? Every TODO should reference a ticket.

#### Design & Architecture
- **Separation of Concerns**: Is functionality properly separated?
- **Law of Demeter**: Does each class only know its direct dependencies?
- **Immutability**: Are values immutable where possible?
- **Error Handling**: Are errors handled appropriately? No catching `Throwable` or broad exceptions.

#### Security
- **Input Validation**: Is user input properly validated?
- **SQL Injection**: Are database queries using parameterized queries?
- **XSS Vulnerabilities**: Is output properly escaped?
- **Secrets**: Are there any exposed credentials, API keys, or secrets?
- **Authentication/Authorization**: Are auth checks in place where needed?

#### Performance
- **Algorithmic Complexity**: Are there obvious performance bottlenecks?
- **Resource Management**: Are resources (connections, files, streams) properly managed?
- **Memory Leaks**: Are there potential memory leaks?

#### Testing
- **Test Coverage**: Are critical paths tested?
- **Test Quality**: Are tests meaningful and not brittle?
- **Edge Cases**: Are edge cases covered?

### 5. Provide Structured Feedback

Format your review as follows:

```markdown
## Code Review Summary

**Language**: [Detected language]
**Files Reviewed**: [Count and primary files]

## Critical Issues

[List any blocking issues that must be fixed]

## Suggestions

[List improvements that would enhance code quality]

## Positive Feedback

[Highlight good practices observed]

## Language-Specific Observations

[Apply specific style guide rules for the detected language]
```

### 6. Reference Specific Lines

When providing feedback, always reference specific locations using the format:
- `file_path:line_number` (e.g., `src/services/UserService.scala:42`)

This allows DJ to navigate directly to the code.

## Best Practices

1. **Be constructive**: Focus on improving the code, not criticizing the author
2. **Provide context**: Explain WHY something should change, not just WHAT to change
3. **Prioritize**: Clearly distinguish between critical issues and nice-to-haves
4. **Be specific**: Point to exact lines and suggest concrete alternatives
5. **Stay objective**: Apply consistent standards based on the style guides
6. **Consider impact**: Focus on high-impact changes rather than nitpicking

## Example Review Comments

### Good Example
```
src/auth/UserValidator.scala:23 - Consider using pattern matching instead of chained if/else for type checks. This improves readability and aligns with Scala best practices (see scala_code_style.md #20).

Current:
if (user.role == "admin") { ... }
else if (user.role == "user") { ... }

Suggested:
user.role match {
  case "admin" => ...
  case "user" => ...
  case _ => ...
}
```

### Bad Example
```
This code is bad. Use pattern matching.
```

## Notes

- Focus on code that was actually changed, not the entire codebase
- For Scala code, strictly apply the rules from `scala_code_style.md`
- If unsure about a language-specific convention, research or ask DJ
- Don't review generated code, lock files, or vendored dependencies
