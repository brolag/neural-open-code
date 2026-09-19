const DENY_BASH = [
  /\brm\s+-[a-zA-Z]*rf\b/,
  /\brm\s+-[a-zA-Z]*fr\b/,
  /\bgit\s+push\s+(-f|--force)\b/,
  /\bgit\s+reset\s+--hard\b/,
  /\bsudo\s+/,
  /\bchmod\s+777\b/,
  /\bcurl\b.*\|\s*(ba)?sh\b/,
  /\bwget\b.*\|\s*(ba)?sh\b/,
]

function isEnvFile(path) {
  if (!path) return false
  const base = path.split(/[\\/]/).pop() || ""
  if (base === ".env.example") return false
  return base === ".env" || base.startsWith(".env.")
}

export const NeuralHooks = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (input.tool === "bash") {
        const command = String(output.args?.command ?? "")
        if (DENY_BASH.some((re) => re.test(command))) {
          throw new Error("blocked dangerous shell command")
        }
      }
      if (input.tool === "edit" || input.tool === "write") {
        const path = String(output.args?.filePath ?? output.args?.path ?? "")
        if (isEnvFile(path)) {
          throw new Error("blocked write to secret-bearing file")
        }
      }
    },
    "experimental.session.compacting": async (_input, output) => {
      output.context.push(
        "Preserve: current task, key decisions, files modified, and blockers.",
      )
    },
  }
}

export default NeuralHooks
