# Agent harness contract

The five skills form a gated artifact flow.

```text
request
  -> /discover -> unknowns-map.md
  -> /spec     -> plan.md + approval
  -> /craft    -> implementation + baseline/delta
  -> /vet      -> SHIP | HOLD
  -> /exercise -> PASS | FAIL
```

## Authority by gate

| Gate | May inspect | May write | Must not do |
|---|---|---|---|
| `/discover` | repository and relevant sources | `unknowns-map.md` | implement |
| `/spec` | map, repository, tests, docs | `plan.md` | implement |
| `/craft` | approved plan and implementation | code and evidence | self-approve or publish |
| `/vet` | neutral diff bundle and acceptance | review report | rewrite scope |
| `/exercise` | runnable product and public docs | behavioral evidence | infer behavior from source alone |

A builder cannot turn its own confidence into a `SHIP` verdict.

Quality gates are part of the contract, not extra skills: OWASP ASVS + CWE (security), ISO/IEC 25010 (simplicity), WCAG 2.2 AA (accessibility). `$spec` writes them, `$vet` judges them, `$exercise` only drives what a user can observe.

Artifacts live under `plans/<date>-<slug>/`. Paths must stay inside `plans/`.
