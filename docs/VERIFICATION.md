# Verification

Neural OpenCode uses four complementary evidence lanes.

## 1. Structural validation

The package manifest and skill layout must match OpenCode 1.18.31 conventions.

```bash
python3 -m pytest -q tests/test_plugin_structure.py
```

This proves schema compatibility, not workflow correctness.

## 2. Semantic tests

```bash
python3 -m pytest -q
node --test tests/hooks.test.js
./scripts/doc-lint.sh
```

Tests assert the exact five-skill allowlist, plugin package shape, hook
behavior, trust documentation, path containment, stale-reference denial, and
GitHub Page links.

## 3. Independent review

`/vet` verifies the approved plan against a neutral change bundle. Every
required criterion must be `PASS`; missing required evidence prevents `SHIP`.

## 4. Behavioral exercise

`/exercise` follows the documented installation and workflow as a user, then
inspects the GitHub Page at desktop and mobile widths. Source inspection alone
cannot produce `PASS`.

## Release gate

A change is ready only when:

- plugin structure and skill contracts pass;
- pytest, hook tests, and documentation lint pass;
- no unsupported inventory or stale claim remains;
- `/vet` returns `SHIP`;
- `/exercise` returns `PASS`;
- required pull-request checks are green.

Publishing a GitHub release, npm package, or live Pages deploy is a separate
maintainer action and is not performed by this repository's default workflow.
