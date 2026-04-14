---
name: debugging-patterns
description: Common bug patterns and language-specific debugging techniques. Load when investigating a bug or error.
---

# Debugging Patterns

## Investigation Steps

1. **Read the stack trace** — bottom-up for cause, top-down for effect
2. **Find the error location** — exact file and line
3. **Trace data flow backward** — where did the bad value come from?
4. **Distinguish symptom from cause** — fix the root, not the surface
5. **Check recent changes** — `git log` near the failure point

## Common Bug Categories

| Category | Signs | Check |
|----------|-------|-------|
| Null/None | NPE, NoSuchElementException | Optional unwrap, nullable types |
| Concurrency | Intermittent, race condition | Shared mutable state, lock ordering |
| Stale state | Wrong value, works once | Cache TTL, missing invalidation |
| Type mismatch | ClassCastException, parse error | API contracts, deserialization |
| Resource leak | OOM, connection exhaustion | try-with-resources, close() calls |
| Edge case | Fails on empty/zero/max | Boundary values, empty collections |

## Language-Specific Patterns

### Kotlin
```kotlin
// ❌ Platform type NPE — Java interop
val name: String = javaService.getName()  // crashes if Java returns null
// ✅ Fix
val name: String? = javaService.getName()

// ❌ Missing coroutine cancellation handling
suspend fun fetch() = withContext(IO) { api.call() }
// ✅ Fix
suspend fun fetch() = coroutineScope { ensureActive(); withContext(IO) { api.call() } }
```

### Scala
```scala
// ❌ .get on None
val user = userOpt.get  // throws NoSuchElementException
// ✅ Fix
val user = userOpt.getOrElse(defaultUser)

// ❌ Non-exhaustive match (new subtype added to sealed trait)
result match { case Right(v) => handle(v) }  // missing Left case
// ✅ Fix: always handle all cases
```

### Java
```java
// ❌ Swallowed exception
try { conn.execute(q); } catch (SQLException e) { /* silent */ }
// ✅ Fix
try { conn.execute(q); } catch (SQLException e) { throw new DbException(q, e); }

// ❌ Resource leak
Connection c = ds.getConnection();  // leak if exception thrown after
// ✅ Fix
try (var c = ds.getConnection()) { ... }
```

### TypeScript / React
```typescript
// ❌ Stale closure in setTimeout/setInterval
setCount(count + 1);  // captures stale count
// ✅ Fix
setCount(prev => prev + 1);

// ❌ State update after unmount
useEffect(() => { fetch().then(d => setState(d)); }, []);
// ✅ Fix
useEffect(() => {
  let active = true;
  fetch().then(d => { if (active) setState(d); });
  return () => { active = false; };
}, []);

// ❌ Unsafe type assertion
const user = data as User;  // no runtime check
// ✅ Fix: validate at boundary
const user = UserSchema.parse(data);
```

## Output Format

```markdown
## Root Cause: `[description]`
**File**: `path/to/file.kt:42`
**Category**: [Null | Concurrency | State | Type | Resource | Edge case]

**Why it fails**: [trace the execution path]

**Fix**:
```lang
// Before
[broken code]
// After
[fixed code]
```

**Prevention**: [test to add / linting rule]
```
