/**
 * Block high-confidence destructive shell commands.
 * Port of neural-codex dangerous_actions_blocker.py for OpenCode `bash`.
 */

import {
  ASSIGNMENT_RE,
  commandSegments,
  normalizeTarget,
  shellTokens,
  skipOptions,
} from "./shell-parse.js"

const BLOCKED_SUBSTRINGS = [
  "dd if=",
  "mkfs",
  ":(){:|:&};:",
  "> /dev/sda",
  "chmod -R 777 /",
  "--no-preserve-root",
  "DROP DATABASE",
  "DROP TABLE",
]

const SHELL_EXECUTABLES = new Set(["bash", "dash", "ksh", "sh", "zsh"])
const SUDO_OPTIONS_WITH_VALUE = new Set([
  "-C", "-D", "-R", "-T", "-g", "-h", "-p", "-u",
  "--chdir", "--chroot", "--command-timeout", "--group",
  "--host", "--prompt", "--role", "--type", "--user",
])
const ENV_OPTIONS_WITH_VALUE = new Set([
  "-C", "-S", "-u", "--chdir", "--split-string", "--unset",
])

function isRecursiveOption(token) {
  if (token === "--recursive") return true
  return token.startsWith("-") && !token.startsWith("--") && /[rR]/.test(token.slice(1))
}

function executableIndex(tokens) {
  let index = 0
  while (index < tokens.length) {
    while (index < tokens.length && ASSIGNMENT_RE.test(tokens[index])) index += 1
    if (index >= tokens.length) return null
    const executable = tokens[index].split("/").pop()
    if (executable === "sudo") {
      index = skipOptions(tokens, index + 1, SUDO_OPTIONS_WITH_VALUE)
      continue
    }
    if (executable === "env") {
      index = skipOptions(tokens, index + 1, ENV_OPTIONS_WITH_VALUE)
      while (index < tokens.length && ASSIGNMENT_RE.test(tokens[index])) index += 1
      continue
    }
    if (executable === "command" || executable === "nohup") {
      index = skipOptions(tokens, index + 1, new Set())
      continue
    }
    return index
  }
  return null
}

function shellCommandArgument(arguments_) {
  for (let index = 0; index < arguments_.length; index += 1) {
    const argument = arguments_[index]
    if (argument === "--") continue
    if (argument === "--command" || (argument.startsWith("-") && !argument.startsWith("--") && argument.includes("c"))) {
      return arguments_[index + 1] ?? null
    }
  }
  return null
}

function hasMagic(target) {
  return /[*?[\]{}]/.test(target)
}

function destructiveRmArguments(arguments_, home) {
  let recursive = false
  const targets = []
  let optionsDone = false
  for (const argument of arguments_) {
    if (argument === "--") {
      optionsDone = true
      continue
    }
    if (!optionsDone && argument.startsWith("-")) {
      recursive = recursive || isRecursiveOption(argument)
      continue
    }
    targets.push(normalizeTarget(argument, home))
  }
  const protectedTargets = new Set(["/", normalizeTarget(home, home)])
  if (!recursive) return false
  return targets.some((target) => {
    if (protectedTargets.has(target)) return true
    const slash = target.lastIndexOf("/")
    const parent = slash <= 0 ? "/" : target.slice(0, slash)
    return hasMagic(target) && protectedTargets.has(parent)
  })
}

export { shellTokens }

export function containsDestructiveRm(command, home = process.env.HOME || "", depth = 0) {
  if (depth > 4) return false
  for (const segment of commandSegments(shellTokens(command))) {
    const index = executableIndex(segment)
    if (index === null) continue
    const executable = segment[index].split("/").pop()
    const arguments_ = segment.slice(index + 1)
    if (executable === "rm" && destructiveRmArguments(arguments_, home)) return true
    if (SHELL_EXECUTABLES.has(executable)) {
      const nested = shellCommandArgument(arguments_)
      if (nested && containsDestructiveRm(nested, home, depth + 1)) return true
    }
  }
  return false
}

/** @returns {string | null} block reason */
export function inspectBashCommand(command, home = process.env.HOME || "") {
  if (!command) return null
  if (containsDestructiveRm(command, home)) {
    return "BLOCKED: Recursive deletion of a root or home directory"
  }
  for (const pattern of BLOCKED_SUBSTRINGS) {
    if (command.includes(pattern)) {
      return `BLOCKED: Destructive command detected: '${pattern}'`
    }
  }
  if (/\bgit\s+push\b/.test(command) && /(?:\s-f\b|--force(?:-with-lease)?\b)/.test(command) && /\b(?:main|master)\b/.test(command)) {
    return "BLOCKED: Force push to main/master"
  }
  if (/(?:^|[;&|]\s*)(?:npm|pnpm|yarn)\s+publish\b/.test(command)) {
    return "BLOCKED: Package publication requires manual confirmation"
  }
  return null
}
