# Workflow

Neural OpenCode exposes exactly five skills:

```text
/discover -> /spec -> approval -> /craft -> /vet + /exercise -> ship
```

## 1. Discover

Use `/discover` when the request hides architectural choices, unfamiliar code, security boundaries, or expensive assumptions.

```text
/discover inspect this repository before we replace authentication
```

It writes `unknowns-map.md` and stops. Skip it for obvious low-risk work.

## 2. Spec

Use `/spec` to turn evidence into a build contract.

```text
/spec plan the approved authentication migration
```

`plan.md` locks interfaces, quality gates, dependency-aware subtasks, and executable acceptance. Implementation waits for approval.

Quality gates, when the change touches them:

| Gate | Standard | `$spec` | `$vet` | `$exercise` |
|---|---|---|---|---|
| Security | OWASP ASVS + CWE | write invariants | judge the diff | auth/session flows only |
| Simplicity | ISO/IEC 25010 | reuse vs new; out of scope | over-engineering | n/a |
| Accessibility | WCAG 2.2 AA | keyboard / name-role-value / contrast, or `n/a` | UI diff | keyboard + axe/Lighthouse |

## 3. Craft

Use `/craft` after reviewing and approving the plan.

```text
/craft implement the plan we just approved
```

Craft captures a baseline, implements against locked signatures, verifies each subtask, and measures the delta. It does not silently commit, publish, deploy, or merge.

## 4. Vet

Use `/vet` as the independent pre-ship review.

```text
/vet --spec plans/2026-07-12-example/plan.md --scope working-tree
```

The reviewer receives a neutral bundle and returns exactly `SHIP` or `HOLD`.

## 5. Exercise

Use `/exercise` to verify the public workflow after automated checks.

```text
/exercise --spec plans/2026-07-12-example/plan.md
```

Exercise drives the appropriate browser, desktop, CLI, or docs surface and returns `PASS` or `FAIL`.

## Artifact lifecycle

```text
plans/<date>-<slug>/
├── unknowns-map.md
├── plan.md
├── baseline.md
├── delta.md
├── vet-report.md
└── exercise-report.md
```

Do not store credentials or unredacted secrets in artifacts.

## Choosing the smallest safe path

- Obvious edit: implement and test directly.
- Clear non-trivial change: `/spec -> /craft -> /vet -> /exercise`.
- Ambiguous or high-cost change: start with `/discover`.
