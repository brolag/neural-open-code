#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

REQUIRED_FILES=(
  "README.md"
  "AGENTS.md"
  "ARCHITECTURE.md"
  "opencode.json"
  ".opencode/plugin/neural-hooks.js"
  "docs/README.md"
  "docs/AGENT-HARNESS.md"
  "docs/CONFIGURATION.md"
  "docs/HOOKS.md"
  "docs/VERIFICATION.md"
  "docs/WORKFLOW.md"
)

CORE_SKILLS=(discover spec craft vet exercise)
DOCS_WITH_COMPLETE_FLOW=(
  "README.md"
  "docs/README.md"
  "docs/WORKFLOW.md"
)

GATE_DOCS=(
  "AGENTS.md"
  "ARCHITECTURE.md"
  "docs/WORKFLOW.md"
  "docs/AGENT-HARNESS.md"
)

GATE_TERMS=(
  "OWASP ASVS"
  "ISO/IEC 25010"
  "WCAG 2.2"
)

STALE_PATTERNS=(
  "OPENCODE_PLUGIN_ROOT"
  "settings.json"
  "allowed-tools"
  "install.sh"
  "neural-loop"
  "/meta:agent"
)

failures=()

contains_text() {
  local file="$1"
  local needle="$2"
  if command -v rg >/dev/null 2>&1; then
    rg -q --fixed-strings "$needle" "$file"
  else
    grep -qF "$needle" "$file"
  fi
}

for rel in "${REQUIRED_FILES[@]}"; do
  if [[ ! -s "${ROOT_DIR}/${rel}" ]]; then
    failures+=("Missing or empty required file: ${rel}")
  fi
done

for skill in "${CORE_SKILLS[@]}"; do
  skill_file=".opencode/skills/${skill}/SKILL.md"
  command_file=".opencode/commands/${skill}.md"
  if [[ ! -s "${ROOT_DIR}/${skill_file}" ]]; then
    failures+=("Missing skill: ${skill_file}")
  fi
  if [[ ! -s "${ROOT_DIR}/${command_file}" ]]; then
    failures+=("Missing command: ${command_file}")
  fi
  for rel in "${DOCS_WITH_COMPLETE_FLOW[@]}"; do
    if [[ -f "${ROOT_DIR}/${rel}" ]] && ! contains_text "${ROOT_DIR}/${rel}" "/${skill}"; then
      failures+=("${rel} does not name /${skill}")
    fi
  done
done

for rel in "${GATE_DOCS[@]}"; do
  for term in "${GATE_TERMS[@]}"; do
    if [[ -f "${ROOT_DIR}/${rel}" ]] && ! contains_text "${ROOT_DIR}/${rel}" "${term}"; then
      failures+=("${rel} does not name ${term}")
    fi
  done
done

for pattern in "${STALE_PATTERNS[@]}"; do
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    if contains_text "${ROOT_DIR}/${rel}" "$pattern"; then
      failures+=("Stale reference ${pattern} in ${rel}")
    fi
  done < <(printf '%s\n' README.md AGENTS.md ARCHITECTURE.md docs/*.md)
done

if [[ "${#failures[@]}" -gt 0 ]]; then
  printf '[FAIL] %s\n' "${failures[@]}"
  exit 1
fi

echo "[OK] Plugin documentation validated"
