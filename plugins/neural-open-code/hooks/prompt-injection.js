/**
 * Detect obvious instruction-injection text in executable tool inputs.
 * Documentation writes stay allowed so skills can discuss the patterns.
 */

const ROLE_OVERRIDE_PATTERNS = [
  "ignore previous instructions",
  "ignore all previous",
  "disregard previous",
  "forget your instructions",
  "you are now",
  "pretend you are",
  "new instructions:",
  "override:",
  "system prompt:",
]

const JAILBREAK_PATTERNS = [
  "do anything now",
  "developer mode",
  "jailbreak",
  "ignore safety",
  "bypass restrictions",
  "act as an unrestricted",
]

const TEXT_EXTENSIONS = new Set([".md", ".txt", ".yaml", ".yml"])
const EXECUTABLE_TOOLS = new Set(["bash", "write", "edit", "apply_patch"])

function extensionOf(filePath) {
  const name = String(filePath).split(/[/\\]/).pop() || ""
  const dot = name.lastIndexOf(".")
  return dot >= 0 ? name.slice(dot).toLowerCase() : ""
}

function contentFrom(tool, args = {}) {
  if (tool === "bash") return args.command || ""
  if (tool === "write") return args.content || ""
  if (tool === "edit") return `${args.oldString || ""}\n${args.newString || ""}`
  if (tool === "apply_patch") return args.patchText || args.command || ""
  return ""
}

function pathsFrom(tool, args = {}) {
  if (tool === "write" || tool === "edit") {
    return args.filePath ? [args.filePath] : []
  }
  if (tool === "apply_patch") {
    const prefixes = ["*** Add File: ", "*** Update File: ", "*** Delete File: "]
    return String(args.patchText || args.command || "")
      .split(/\r?\n/)
      .flatMap((line) => {
        for (const prefix of prefixes) {
          if (line.startsWith(prefix)) return [line.slice(prefix.length).trim()]
        }
        return []
      })
  }
  return []
}

/** @returns {string | null} block reason */
export function inspectPromptInjection(tool, args = {}) {
  if (!EXECUTABLE_TOOLS.has(tool)) return null
  const content = contentFrom(tool, args)
  if (!content) return null

  if (tool === "bash" && /^\s*git\s+(commit|log|tag)\b/.test(content)) return null

  const paths = pathsFrom(tool, args)
  if (paths.length && paths.every((path) => TEXT_EXTENSIONS.has(extensionOf(path)))) {
    return null
  }

  const lowered = content.toLowerCase()
  for (const pattern of [...ROLE_OVERRIDE_PATTERNS, ...JAILBREAK_PATTERNS]) {
    if (lowered.includes(pattern)) {
      return `BLOCKED: Prompt injection pattern detected: '${pattern}'`
    }
  }
  return null
}
