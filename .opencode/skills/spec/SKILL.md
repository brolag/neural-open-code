---
name: spec
description: Plan a non-trivial change before implementation. Use when work needs repository research, locked interfaces, security invariants, dependency-aware subtasks, executable acceptance criteria, and explicit approval. Consumes unknowns-map.md when available, writes plan.md, and stops without coding.
---

# Spec

Turn intent and repository evidence into an approvable implementation contract. Never write implementation code.

## 1. Right-size and research

Skip ceremony for an obvious change under roughly 25 lines with no new interface, ambiguity, or risk.

Otherwise:

1. Find the newest related `plans/**/unknowns-map.md` and read it first.
2. Read repository guidance, the relevant code, tests, documentation, and useful history.
3. Reuse established patterns before proposing new ones.
4. If discovery was skipped, record that fact and clarify only architecture-changing ambiguity.

Treat resolved discovery decisions as inputs. Preserve unresolved blockers instead of guessing around them.

## 2. Lock the contract

Declare every introduced or changed interface before implementation:

```text
name(parameters) -> result [new|adapt|reuse] -> path
```

Interfaces include functions, types, commands, files, routes, events, schemas, and durable artifact shapes. A new interface that duplicates an existing one is a planning defect.

### Quality gates

Lock only the gates the change actually touches. Cite the standard. Keep every item testable. A slogan is not an invariant.

**Security — [OWASP ASVS](https://owasp.org/www-project-application-security-verification-standard/) + CWE.** For every trust or data boundary, add an `@invariant` with ASVS requirement id, CWE, concrete mitigation, and `verify`. Cover path handling, secret exposure, command execution, authorization, destructive side effects, and validation integrity when applicable.

**Simplicity — [ISO/IEC 25010](https://iso25000.com/index.php/en/iso-25000-standards/iso-25010) maintainability.** Prefer `reuse` over `new`. A new interface that duplicates an existing one is a planning defect. Put extra frameworks, helpers, and speculative layers in Out of scope unless a locked signature requires them.

**Accessibility — [WCAG 2.2](https://www.w3.org/TR/WCAG22/) Level AA.** If the change adds or alters a user-visible surface (web, docs page, TUI), write `when/requires/ensures/verify` for keyboard operation, name/role/value, and contrast. If there is no UI, record `Accessibility: n/a` with the reason.

## 3. Decompose and route

Give every subtask a stable ID and a `[tier:]` model-routing tag:

- `cheap`: mechanical edits, boilerplate, and narrow tests;
- `mid`: normal implementation requiring local judgment;
- `hard`: architecture, security, ambiguity, or tricky debugging;
- `batch`: long-running multi-step or operational work.

Add `[needs: S1, S2]` only for real dependencies. No dependency tag means the work may execute independently. Validate that every referenced ID exists and that the graph is acyclic.

## 4. Make acceptance executable

Every subtask must include:

- `when`: the triggering state or behavior;
- `requires`: preconditions and boundaries;
- `ensures`: observable postconditions;
- `verify`: a safe command, test path, or deterministic assertion;
- `must_include` or `must_not_include` when text contracts matter.

State what each verification oracle proves and what it does not prove. A green unit test cannot substitute for behavioral or independent review when those gates are required.

## 5. Scan contradictions

Resolve incompatible requirements, unreachable states, naming collisions, and approval ambiguity. Validate the dependency graph. Record deliberate tradeoffs and residual questions rather than hiding them in implementation notes.

## 6. Write `plan.md` and stop

Normalize the task slug to lowercase letters, digits, and hyphens. Resolve the repository root and its `plans/` directory before creating anything. Resolve the candidate artifact path and require `os.path.commonpath([candidate, plans_root]) == plans_root`; reject symlinks or normalized paths that escape that boundary. Inputs such as `../../outside/plan.md`, `plans/../outside/plan.md`, and `/tmp/external-plan.md` are invalid.

Write `plans/<YYYY-MM-DD-task-slug>/plan.md` with this frontmatter:

```yaml
---
project: <repo>
created: YYYY-MM-DD
status: draft
modified: []
commits: []
agents: []
related:
  back: []
  forward: []
---
```

Include these sections:

1. Context and locked decisions
2. Signatures
3. Quality gates (security / simplicity / accessibility)
4. Subtasks with state legend, dependencies, tiers, and executable acceptance
5. Contradiction scan
6. Out of scope
7. Open questions
8. Notes
9. Amend log

`plan.md` is the source of truth. Do not generate HTML; accept `--no-html` as a compatibility no-op. Present the plan and STOP for approval. A later explicit `$craft` invocation that clearly refers to this reviewed draft counts as approval; otherwise require an explicit approval before changing its status.

## Usage Examples

- `$spec implement the approved unknowns map for account export`
- `$spec plan the hook migration --no-html`
- `$spec turn this issue into a dependency-aware build contract`

## Done when

The draft plan has locked signatures, OWASP ASVS/CWE security invariants, ISO/IEC 25010 simplicity constraints, WCAG 2.2 AA or an explicit `n/a`, executable acceptance, a valid dependency graph, explicit non-goals, and has been presented without implementation edits.
