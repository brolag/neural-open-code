# Verification

## 1. Structural tests

```bash
python3 -m pytest -q
./scripts/doc-lint.sh
node --check .opencode/plugin/neural-hooks.js
python3 -m json.tool opencode.json >/dev/null
```

This proves inventory and docs contracts, not that a feature works for a user.

## 2. Independent review

`/vet` verifies the approved plan against a neutral change bundle, including OWASP ASVS + CWE, ISO/IEC 25010, and WCAG 2.2 AA. Missing required evidence prevents `SHIP`.

## 3. Behavioral exercise

`/exercise` follows the documented workflow as a user. Source inspection alone cannot produce `PASS`.

## Release gate

A change is ready only when pytest and doc-lint pass, `/vet` returns `SHIP`, and `/exercise` returns `PASS`.
