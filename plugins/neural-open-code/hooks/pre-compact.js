/**
 * Write a small recovery note before OpenCode session compaction.
 */

import { execFileSync } from "node:child_process"
import { mkdirSync, readdirSync, statSync, writeFileSync } from "node:fs"
import { join } from "node:path"

function gitOutput(cwd, args) {
  try {
    return execFileSync("git", args, {
      cwd,
      encoding: "utf8",
      timeout: 5000,
      stdio: ["ignore", "pipe", "ignore"],
    }).trim()
  } catch {
    return ""
  }
}

export function latestPlan(plansDir) {
  let entries
  try {
    entries = readdirSync(plansDir).filter((name) => !name.startsWith("."))
  } catch {
    return null
  }
  if (!entries.length) return null
  let newest = entries[0]
  let newestTime = 0
  for (const name of entries) {
    const time = statSync(join(plansDir, name)).mtimeMs
    if (time >= newestTime) {
      newest = name
      newestTime = time
    }
  }
  return `plans/${newest}`
}

export function buildCompactNote(cwd, now = new Date()) {
  const lines = [`# Pre-Compaction Context (${now.toISOString()})`, ""]
  if (gitOutput(cwd, ["rev-parse", "--git-dir"])) {
    lines.push(
      "## Git State",
      `Branch: ${gitOutput(cwd, ["branch", "--show-current"]) || "unknown"}`,
      "Recent commits:",
      gitOutput(cwd, ["log", "--oneline", "-5"]) || "(none)",
      "",
      "Modified files:",
      gitOutput(cwd, ["status", "--short"]) || "(clean)",
      "",
    )
  }
  const plan = latestPlan(join(cwd, "plans"))
  if (plan) lines.push("## Active Plan", `Latest: ${plan}`, "")
  return lines.join("\n")
}

export function writeCompactNote(cwd) {
  const target = join(cwd, ".opencode", "compact-context.md")
  mkdirSync(join(cwd, ".opencode"), { recursive: true })
  writeFileSync(target, buildCompactNote(cwd), "utf8")
  return target
}
