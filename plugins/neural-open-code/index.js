/**
 * Neural OpenCode plugin for OpenCode 1.18.31+.
 *
 * Registers guardrail hooks only. Does not mutate model, approval, MCP,
 * sandbox, or other user configuration.
 */

import { inspectBashCommand } from "./hooks/dangerous-actions.js"
import { scanToolOutput } from "./hooks/output-scanner.js"
import { writeCompactNote } from "./hooks/pre-compact.js"
import { inspectPromptInjection } from "./hooks/prompt-injection.js"
import { inspectSensitiveWrite } from "./hooks/sensitive-files.js"

export const id = "neural-open-code"

function inspectBefore(tool, args = {}) {
  if (tool === "bash") {
    return inspectBashCommand(args.command || "") || inspectPromptInjection(tool, args)
  }
  return inspectSensitiveWrite(tool, args) || inspectPromptInjection(tool, args)
}

export function createHooks(input = {}) {
  const directory = input.directory || input.worktree || process.cwd()
  return {
    "tool.execute.before": async (event, output) => {
      const reason = inspectBefore(event.tool, output.args || {})
      if (reason) throw new Error(reason)
    },
    "tool.execute.after": async (_event, output) => {
      const warning = scanToolOutput(output.output)
      if (warning) output.output = `${output.output || ""}\n\n${warning}`
    },
    "experimental.session.compacting": async (_event, output) => {
      try {
        const target = writeCompactNote(directory)
        output.context.push(`Read ${target} after compaction to recover git state and the latest plans/ artifact.`)
      } catch (error) {
        output.context.push(`Could not preserve compact context: ${error.message}`)
      }
    },
  }
}

export async function NeuralOpenCode(input) {
  return createHooks(input)
}

export default {
  id,
  async server(input) {
    return createHooks(input)
  },
}
