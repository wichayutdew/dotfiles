---
name: testing-patterns
description: Test isolation standards, functional testing patterns, and best practices. Reference for writing effective, immutable tests with when/should/in structure across Kotlin, Scala, and TypeScript.
---

# Testing Patterns

## Test Isolation Standards

### Core Principle: Full Test Isolation

Every test case must be fully independent. Tests must not rely on:

- Execution order within a file or suite
- State, side effects, or mock configuration left by a previous test
- Shared mutable state that is not reset between tests

### Rules

1. **Always reset mocks/spies/stubs before each test.**
   After each test, any mock call history, configured return values, or spy state must be cleared before the next test begins. Use your framework's equivalent:

   - Jest: `beforeEach(() => jest.clearAllMocks())`
   - Vitest: `beforeEach(() => vi.clearAllMocks())`
   - Kotlin (MockK): `afterTest { clearMocks(repository) }`
   - Scala (Mockito): reset in `beforeEach` with `reset(mock)`
   - Python (unittest.mock): `patch` as context manager per test, or `mock.reset_mock()` in `setUp`
   - Go: re-initialize stubs/fakes in each `t.Run` or `TestXxx` function
   - General: reset in a `beforeEach` / `setUp` / `before_each` lifecycle hook

2. **Place the reset at the outermost test group.**
   One reset hook at the top-level `describe` / `suite` / `class` is sufficient and covers all nested groups. Do not rely on a nested group's position to avoid conflicts.

3. **Do not rely on test order for correctness.**
   Any single test must pass if run in isolation or in any arbitrary order. If a test only passes when run after another, it is a broken test.

4. **Scope mock setup to the test that needs it.**
   Configure specific return values or behaviors inside the individual test, not in a shared outer scope that bleeds into other tests.

5. **Prefer local variables over shared mutable state.**
   Declare test fixtures and mocks inside the test or in a `beforeEach` factory so each test gets a fresh instance.

### Why This Matters

- Tests that leak state produce **false positives** (tests that pass only due to prior setup) and **false negatives** (tests that fail only due to prior pollution).
- Test order may change due to parallelization, randomization, or file reorganization — isolation guarantees correctness regardless.

---

## Test Structure

### Hierarchy: when/should/in

```
"Feature" when {
  "action or context" should {
    "expected behavior" in {
      // given - immutable setup
      // when - pure function call
      // then - assertion
    }
  }
}
```

### Inside Each Test: given/when/then

```kotlin
"calculate total" should {
    "sum all item prices" in {
        // given - setup (immutable)
        val items = listOf(Item(price = 10), Item(price = 20))
        
        // when - action (pure function)
        val result = calculateTotal(items)
        
        // then - assertion
        result shouldBe 30
    }
}
```

## Immutable Test Fixtures

### Kotlin
```kotlin
class UserServiceTest : WordSpec({
    // Immutable fixtures - defined once, never mutated
    val testUser = User(id = 1, name = "John", email = "john@test.com")
    val testUsers = listOf(testUser, User(id = 2, name = "Jane"))

    "UserService" when {
        "getUser" should {
            "return user when found" {
                // Use copy for variations
                val activeUser = testUser.copy(active = true)
                // ...
            }
        }
    }
})
```

### Scala
```scala
class UserServiceSpec extends AnyWordSpec with Matchers {
  // Immutable fixtures
  val testUser = User(id = 1, name = "John", email = "john@test.com")
  val testUsers = Seq(testUser, User(id = 2, name = "Jane"))

  "UserService" when {
    "getUser" should {
      "return user when found" in {
        // Use copy for variations
        val activeUser = testUser.copy(active = true)
        // ...
      }
    }
  }
}
```

### TypeScript
```typescript
// Immutable fixtures with const assertion
const TEST_USER = { id: 1, name: 'John', email: 'john@test.com' } as const;
const TEST_USERS: readonly User[] = [TEST_USER, { id: 2, name: 'Jane' }] as const;

describe('UserService', () => {
  describe('when getUser', () => {
    it('should return user when found', () => {
      // Use spread for variations
      const activeUser = { ...TEST_USER, active: true };
      // ...
    });
  });
});
```

## Testing Pure Functions

Pure functions are easiest to test - same input always gives same output.

### Kotlin
```kotlin
"CsvGenerator" when {
    "escapeCsv" should {
        "escape commas" {
            escapeCsv("hello, world") shouldBe "\"hello, world\""
        }
        
        "escape quotes" {
            escapeCsv("say \"hello\"") shouldBe "\"say \"\"hello\"\"\""
        }
        
        "return unchanged when no special chars" {
            escapeCsv("simple") shouldBe "simple"
        }
    }
}
```

### Parameterized Tests (Table-Driven)

```kotlin
"escapeCsv" should {
    withData(
        nameFn = { "escape '${it.first}' to '${it.second}'" },
        "hello, world" to "\"hello, world\"",
        "say \"hi\"" to "\"say \"\"hi\"\"\"",
        "simple" to "simple",
        "" to ""
    ) { (input, expected) ->
        escapeCsv(input) shouldBe expected
    }
}
```

## Testing Result/Either Types

### Kotlin (Result)
```kotlin
"parseEmail" should {
    "return Success for valid email" {
        val result = parseEmail("user@test.com")
        
        result.shouldBeSuccess()
        result.getOrThrow().domain shouldBe "test.com"
    }
    
    "return Failure for invalid email" {
        val result = parseEmail("invalid")
        
        result.shouldBeFailure()
        result.exceptionOrNull() shouldBe instanceOf<ValidationError>()
    }
}
```

### Scala (Either)
```scala
"parseEmail" should {
  "return Right for valid email" in {
    val result = parseEmail("user@test.com")
    
    result.isRight shouldBe true
    result.value.domain shouldBe "test.com"
  }
  
  "return Left for invalid email" in {
    val result = parseEmail("invalid")
    
    result.isLeft shouldBe true
    result.left.value shouldBe a[ValidationError]
  }
}
```

### TypeScript (Discriminated Union)
```typescript
describe('parseEmail', () => {
  it('should return success for valid email', () => {
    const result = parseEmail('user@test.com');
    
    expect(result.type).toBe('success');
    if (result.type === 'success') {
      expect(result.data.domain).toBe('test.com');
    }
  });
  
  it('should return failure for invalid email', () => {
    const result = parseEmail('invalid');
    
    expect(result.type).toBe('failure');
  });
});
```

## Mocking for FP

### Mock at Boundaries Only

```kotlin
// ✅ DO: Mock external dependencies (repositories, APIs)
val userRepository = mockk<UserRepository>()
every { userRepository.findAll() } returns testUsers

// ❌ DON'T: Mock pure functions
// They're deterministic - just call them!
```

### Kotlin (MockK)
```kotlin
val repository = mockk<UserRepository>()

// Setup
coEvery { repository.findById(1) } returns testUser
coEvery { repository.findById(999) } returns null

// Verify
coVerify { repository.findById(1) }
coVerify(exactly = 0) { repository.save(any()) }

// Clear between tests
afterTest { clearMocks(repository) }
```

### Scala (Mockito)
```scala
val repository = mock[UserRepository]

// Setup
when(repository.findById(1)).thenReturn(Future.successful(Some(testUser)))
when(repository.findById(999)).thenReturn(Future.successful(None))

// Verify
verify(repository).findById(1)
verify(repository, never).save(any[User])
```

### TypeScript (Jest)
```typescript
const mockRepository = {
  findById: jest.fn(),
  findAll: jest.fn(),
} as const;

beforeEach(() => jest.clearAllMocks());

// Setup
mockRepository.findById.mockResolvedValue(TEST_USER);

// Verify
expect(mockRepository.findById).toHaveBeenCalledWith(1);
```

## Testing Async/Effects

### Kotlin Coroutines
```kotlin
"fetchUser" should {
    "return user from API" {
        coEvery { api.getUser(1) } returns testUser
        
        val result = runBlocking { service.fetchUser(1) }
        
        result shouldBe testUser
    }
}
```

### Scala Future
```scala
"fetchUser" should {
  "return user from API" in {
    when(api.getUser(1)).thenReturn(Future.successful(testUser))
    
    val result = service.fetchUser(1).futureValue
    
    result shouldBe testUser
  }
}
```

### TypeScript Async
```typescript
describe('fetchUser', () => {
  it('should return user from API', async () => {
    mockApi.getUser.mockResolvedValue(TEST_USER);
    
    const result = await service.fetchUser(1);
    
    expect(result).toEqual(TEST_USER);
  });
});
```

## React Testing (Functional Components)

```typescript
describe('UserList', () => {
  // Immutable test data
  const users: readonly User[] = [
    { id: 1, name: 'John' },
    { id: 2, name: 'Jane' },
  ] as const;

  describe('when rendering', () => {
    it('should display all users', async () => {
      // given
      mockUseUsers.mockReturnValue({ users, loading: false });

      // when
      render(<UserList />);

      // then
      expect(screen.getByText('John')).toBeInTheDocument();
      expect(screen.getByText('Jane')).toBeInTheDocument();
    });
  });

  describe('when user clicks delete', () => {
    it('should call onDelete with user id', async () => {
      // given
      const onDelete = jest.fn();
      const user = userEvent.setup();
      render(<UserItem user={users[0]} onDelete={onDelete} />);

      // when
      await user.click(screen.getByRole('button', { name: /delete/i }));

      // then
      expect(onDelete).toHaveBeenCalledWith(1);
    });
  });
});
```

## Test Organization

```
src/test/
├── kotlin/com/example/
│   ├── domain/           # Pure function tests
│   │   └── CsvGeneratorTest.kt
│   ├── service/          # Service tests (with mocks)
│   │   └── UserServiceTest.kt
│   └── integration/      # Full integration tests
│       └── UserApiTest.kt
```

## Checklist

```
Isolation:
□ Mocks reset before each test (beforeEach / afterTest)
□ No shared mutable state between tests
□ Each test passes in isolation and any order
□ Mock setup scoped to the test that needs it

Structure:
□ when/should/in hierarchy
□ given/when/then in each test
□ Descriptive test names

Immutability:
□ Test fixtures are val/const
□ No shared mutable state
□ Use copy/spread for variations

Functional:
□ Pure functions tested directly
□ Mocks only at boundaries
□ Result/Either types tested for both cases
```

## Run Commands

```bash
# Kotlin/Java (Gradle)
./gradlew test
./gradlew test --tests "UserServiceTest"

# Scala (SBT)
sbt test
sbt "testOnly *UserServiceSpec"

# TypeScript
npm test
npm test -- --testPathPattern="UserService"
```
