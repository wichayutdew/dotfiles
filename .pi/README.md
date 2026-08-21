# Workflow Specifications

This directory defines autonomous workflow specifications in `agent/workflows/` composed from stage prompts in `agent/workflows/steps/`.

---

## 1. `/work` — Local Work
Prepares a dedicated workspace, drafts a plan for Plannotator review, implements changes with TDD, and independently verifies.

```mermaid
flowchart TD
    Start([Start: /work]) --> Prep[prepare-workspace]
    Prep -->|ready| Plan[plan + Plannotator]
    Prep -->|retry| Prep
    Prep -->|blocked| Pause[$pause]

    Plan -->|approved| Imp[implement]
    Plan -->|changes-requested| Plan
    Plan -->|workspace-refresh| Prep
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|passed| Done([$done])
    Ver -->|failed| Imp
    Ver -->|retry / blocked| Ver
```

---

## 2. `/ticket` — Jira Ticket Work
Prepares an isolated worktree, reads Jira acceptance criteria, drafts a plan for Plannotator review, implements with TDD, and independently verifies.

```mermaid
flowchart TD
    Start([Start: /ticket]) --> Prep[prepare-workspace]
    Prep -->|ready| Plan[plan + Plannotator]
    Prep -->|retry| Prep
    Prep -->|blocked| Pause[$pause]

    Plan -->|approved| Imp[implement]
    Plan -->|changes-requested| Plan
    Plan -->|workspace-refresh| Prep
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|passed| Done([$done])
    Ver -->|failed| Imp
    Ver -->|retry / blocked| Ver
```

---

## 3. `/jira` — Epic & Story Creation
Normalizes input, verifies Jira issue types and field metadata, approves an Epic/Story creation plan in Plannotator, and creates the hierarchy.

```mermaid
flowchart TD
    Start([Start: /jira]) --> Draft[draft]
    Draft -->|ready| Plan[plan + Plannotator]
    Draft -->|retry| Draft
    Draft -->|blocked| Pause[$pause]

    Plan -->|approved| Create[create]
    Plan -->|changes-requested| Plan
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Create -->|ready| Done([$done])
    Create -->|retry| Create
    Create -->|blocked| Pause
```

---

## 4. `/investigate` — Evidence & Findings
Retrieves scope/Jira context, gates scope through Plannotator, investigates facts/root causes, and validates findings before writing report.

```mermaid
flowchart TD
    Start([Start: /investigate]) --> Ret[retrieve + Plannotator]
    Ret -->|approved| Inv[investigate]
    Ret -->|changes-requested| Ret
    Ret -->|retry| Ret
    Ret -->|blocked| Pause[$pause]

    Inv -->|ready| Val[validate]
    Inv -->|retry| Inv
    Inv -->|blocked| Pause

    Val -->|approved| Done([$done])
    Val -->|gaps| Inv
    Val -->|retry / blocked| Val
```

---

## 5. `/mr-review` — Hosted Code Review
Fetches MR/PR context and discussions, drafts an evidence-based review with proposed inline comments for Plannotator review, publishes comments, and verifies published state.

```mermaid
flowchart TD
    Start([Start: /mr-review]) --> Fetch[fetch]
    Fetch -->|fetched| Review[review + Plannotator]
    Fetch -->|blocked| Pause[$pause]

    Review -->|approved| Pub[publish]
    Review -->|changes-requested| Review
    Review -->|blocked| Pause

    Pub -->|published| Ver[verify]
    Pub -->|blocked| Pause

    Ver -->|verified| Done([$done])
    Ver -->|failed| Pub
    Ver -->|retry / blocked| Ver
```

---

## 6. `/mr-comment` — Review Comment Fixes
Fetches unresolved review discussions, checks out the branch, plans code fixes and discussion replies for Plannotator approval, implements fixes, verifies, and publishes commits + replies.

```mermaid
flowchart TD
    Start([Start: /mr-comment]) --> Fetch[fetch]
    Fetch -->|ready| Checkout[checkout-source]
    Fetch -->|retry| Fetch
    Fetch -->|blocked| Pause[$pause]

    Checkout -->|ready| Plan[plan + Plannotator]
    Checkout -->|retry| Checkout
    Checkout -->|blocked| Pause

    Plan -->|approved| Imp[implement]
    Plan -->|changes-requested| Plan
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|ready| Del[deliver]
    Ver -->|no-actions| Done([$done])
    Ver -->|failed| Imp
    Ver -->|retry / blocked| Ver

    Del -->|published / no-actions| Done
    Del -->|retry| Del
    Del -->|superseded / blocked| Pause
```

---

## 7. `/sprint-triage` — Support Ticket Triage & Knowledge Base
Collects OpsBot/Slack ticket threads in generic workspace, drafts redacted records and Confluence action trees, approves publication plan via Plannotator, checks out & binds KB repo, writes report + ledger + index, verifies, and publishes to GitLab & Confluence.

```mermaid
flowchart TD
    Start([Start: /sprint-triage]) --> Collect[collect]
    Collect -->|ready| Draft[draft]
    Collect -->|retry| Collect
    Collect -->|blocked| Pause[$pause]

    Draft -->|ready| Plan[plan + Plannotator]
    Draft -->|retry| Draft
    Draft -->|blocked| Pause

    Plan -->|approved| Checkout[checkout]
    Plan -->|changes-requested| Plan
    Plan -->|retry| Plan
    Plan -->|blocked| Pause

    Checkout -->|ready| Imp[implement]
    Checkout -->|retry| Checkout
    Checkout -->|blocked| Pause

    Imp -->|ready| Ver[verify]
    Imp -->|retry| Imp
    Imp -->|blocked| Pause

    Ver -->|ready| Pub[publish]
    Ver -->|failed| Imp
    Ver -->|retry| Ver
    Ver -->|blocked| Pause

    Pub -->|ready| Conf[confirm]
    Pub -->|retry| Pub
    Pub -->|blocked| Pause

    Conf -->|ready| Done([$done])
    Conf -->|retry| Conf
    Conf -->|blocked| Pause
```

