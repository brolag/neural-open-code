/**
 * Warn when tool output resembles credentials without repeating the value.
 */

const SECRET_PATTERNS = [
  ["Anthropic API key", /sk-ant-[A-Za-z0-9_-]{20,}/],
  ["OpenAI API key", /sk-(?!ant-)[A-Za-z0-9_-]{20,}/],
  ["AWS access key", /AKIA[0-9A-Z]{16}/],
  ["GitHub token", /(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9]{36,}/],
  ["Stripe key", /(?:sk|pk)_(?:live|test)_[0-9A-Za-z]{24,}/],
  ["Slack token", /xox[baprs]-[0-9A-Za-z-]{10,}/],
  ["GitLab token", /glpat-[A-Za-z0-9_-]{20,}/],
  ["private key", /-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----/],
  ["database URL with password", /(?:postgres|mysql|mongodb):\/\/[^:\s]+:[^@\s]+@/],
]

export function stringifyOutput(value) {
  if (typeof value === "string") return value
  try {
    return JSON.stringify(value)
  } catch {
    return String(value)
  }
}

/** @returns {string | null} warning text that never echoes the secret */
export function scanToolOutput(value) {
  const output = stringifyOutput(value)
  const warnings = SECRET_PATTERNS.filter(([, pattern]) => pattern.test(output)).map(([name]) => name)
  if (!warnings.length) return null
  return `SECRET LEAK WARNING: Detected in tool output: ${warnings.join(", ")}. Do not commit or share it.`
}
