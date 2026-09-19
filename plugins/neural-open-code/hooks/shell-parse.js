/**
 * Minimal POSIX-ish tokenization for dangerous-action inspection.
 */

export const SHELL_OPERATORS = new Set([";", "&&", "||", "|", "&"])
export const ASSIGNMENT_RE = /^[A-Za-z_][A-Za-z0-9_]*=/

export function shellTokens(command) {
  const tokens = []
  let current = ""
  let quote = ""
  for (let i = 0; i < command.length; i += 1) {
    const char = command[i]
    if (quote) {
      if (char === "\\" && quote === '"') {
        current += command[i + 1] ?? ""
        i += 1
        continue
      }
      if (char === quote) {
        quote = ""
        continue
      }
      current += char
      continue
    }
    if (char === "'" || char === '"') {
      quote = char
      continue
    }
    if (/\s/.test(char)) {
      if (current) tokens.push(current)
      current = ""
      continue
    }
    if (char === "&" || char === "|" || char === ";") {
      if (current) tokens.push(current)
      current = ""
      const pair = command[i + 1]
      if ((char === "&" || char === "|") && pair === char) {
        tokens.push(char + char)
        i += 1
      } else {
        tokens.push(char)
      }
      continue
    }
    current += char
  }
  if (current) tokens.push(current)
  return tokens
}

export function commandSegments(tokens) {
  const segments = []
  let current = []
  for (const token of tokens) {
    if (SHELL_OPERATORS.has(token)) {
      if (current.length) segments.push(current)
      current = []
      continue
    }
    current.push(token)
  }
  if (current.length) segments.push(current)
  return segments
}

export function skipOptions(tokens, index, optionsWithValue) {
  let i = index
  while (i < tokens.length) {
    const token = tokens[i]
    if (token === "--") return i + 1
    const optionName = token.split("=", 1)[0]
    if (optionsWithValue.has(optionName) && !token.includes("=")) {
      i += 2
      continue
    }
    if (token.startsWith("-")) {
      i += 1
      continue
    }
    break
  }
  return i
}

export function normalizeTarget(token, home) {
  let value = token
  for (const prefix of ["${HOME}", "$HOME"]) {
    if (value === prefix || value.startsWith(`${prefix}/`)) {
      value = home + value.slice(prefix.length)
      break
    }
  }
  if (value === "~" || value.startsWith("~/")) {
    value = home + value.slice(1)
  }
  const collapsed = value.replace(/\/+/g, "/")
  if (collapsed === "/") return "/"
  return collapsed.replace(/\/\.$/, "").replace(/\/$/, "") || "/"
}
