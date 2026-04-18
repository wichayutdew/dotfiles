---
name: generate-architecture-docs
description: Generate AGENTS.md and CLAUDE.md config files for a repository or directory. Scan the repo structure, detect tech stack and conventions, then write lean agent config files. Use when onboarding a new repo or generating AI agent context for a directory.
license: MIT
compatibility: opencode
---

# Generate Agent Config (AGENTS.md / CLAUDE.md)

Scan a directory → write lean, terse AGENTS.md and/or CLAUDE.md. Read first, write after.

**Never modify application code.** Only create or update config files.

## Step 1: Scan the Directory

Collect facts from the repo — do not guess:

- **Tech stack**: detect from `package.json`, `*.csproj`, `build.gradle`, `pom.xml`, `build.sbt`, `go.mod`, `Cargo.toml`, `pyproject.toml`
- **Languages**: dominant language(s) from source file extensions
- **Build / lint / test commands**: from `Makefile`, `package.json` scripts, `Taskfile`, CI config
- **CI/CD**: read `.gitlab-ci.yml`, `.github/workflows/`, `Jenkinsfile`
- **Entry points**: main files, routers, server setup
- **Existing docs**: read `README.md`, any `CLAUDE.md` or `AGENTS.md` already present
- **Key directories**: `src/`, `test/`, `infra/`, `docs/`, `scripts/`

## Step 2: Write CLAUDE.md

Put project-specific facts that any agent needs to be effective:

```markdown
# <Project Name>

## Stack
<language> / <framework> — <brief role>

## Commands
```bash
<build command>
<test command>
<lint command>
```

## Key Paths
- `<path>` — <what it contains>

## Conventions
- <naming convention, coding standard, or pattern>
- <anything non-obvious that differs from defaults>

## Notes
- <env vars, secrets approach, deployment notes>
```

Keep it under 60 lines. No filler. Agents read this every session.

## Step 3: Write AGENTS.md

Only if the repo has or needs agent workflows. Use the global format:

```markdown
# Agent Rules

## <Rule Group>
<concise rule>
```

Scope to what's specific to this repo. Don't repeat global rules already in the root AGENTS.md.

## Output Rules

- Terse. Load `commit-format` skill for style guide — apply same compression to generated files.
- Use `##` for top-level sections, not `###`.
- No bracketed placeholder text in final output — fill in real values or omit the section.
- Verify all commands actually exist in the repo before writing them.
- Mark inferred facts with `(inferred)` if not confirmed from source files.
