/**
 * Block writes to common secret-bearing files.
 * Covers OpenCode write, edit, and apply_patch tools.
 */

export const SENSITIVE_NAMES = new Set([
  ".env",
  ".env.local",
  ".env.production",
  ".env.staging",
  ".npmrc",
  ".pypirc",
  "credentials.json",
  "id_dsa",
  "id_ed25519",
  "id_rsa",
  "serviceAccountKey.json",
])

export function isSensitive(filePath) {
  if (!filePath) return false
  const name = String(filePath).split(/[/\\]/).pop() || ""
  return SENSITIVE_NAMES.has(name) || name.startsWith(".env.")
}

export function patchPaths(patch) {
  const prefixes = ["*** Add File: ", "*** Update File: ", "*** Delete File: "]
  const paths = []
  for (const line of String(patch).split(/\r?\n/)) {
    for (const prefix of prefixes) {
      if (line.startsWith(prefix)) {
        paths.push(line.slice(prefix.length).trim())
        break
      }
    }
  }
  return paths
}

/** @returns {string | null} block reason */
export function inspectSensitiveWrite(tool, args = {}) {
  if (tool === "write" || tool === "edit") {
    const filePath = args.filePath || args.path || ""
    if (isSensitive(filePath)) {
      const name = String(filePath).split(/[/\\]/).pop()
      return `BLOCKED: Writing to sensitive file '${name}'`
    }
    return null
  }
  if (tool === "apply_patch") {
    const patch = args.patchText || args.command || ""
    for (const filePath of patchPaths(patch)) {
      if (isSensitive(filePath)) {
        const name = filePath.split(/[/\\]/).pop()
        return `BLOCKED: Writing to sensitive file '${name}'`
      }
    }
  }
  return null
}
