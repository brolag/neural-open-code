import { mkdtempSync, mkdirSync, readFileSync, rmSync, writeFileSync } from "node:fs"
import { tmpdir } from "node:os"
import { join } from "node:path"
import { execSync } from "node:child_process"
import test from "node:test"
import assert from "node:assert/strict"

import { inspectBashCommand } from "../plugins/neural-open-code/hooks/dangerous-actions.js"
import { scanToolOutput } from "../plugins/neural-open-code/hooks/output-scanner.js"
import { writeCompactNote } from "../plugins/neural-open-code/hooks/pre-compact.js"
import { inspectPromptInjection } from "../plugins/neural-open-code/hooks/prompt-injection.js"
import { inspectSensitiveWrite } from "../plugins/neural-open-code/hooks/sensitive-files.js"
import { createHooks } from "../plugins/neural-open-code/index.js"

test("destructive root and home deletions are blocked", () => {
  const home = "/home/tester"
  for (const command of [
    "rm -rf /",
    "rm -fr ~",
    "rm -rf /*",
    "rm -rf $HOME/*",
    "rm --recursive --force /",
    'rm -rf "$HOME"',
    "sudo rm -R -f -- /",
    'bash -c "rm -rf /"',
    "sh -c 'rm -fr $HOME'",
    'env SAFE=1 bash -lc "rm -rf /"',
  ]) {
    const reason = inspectBashCommand(command, home)
    assert.match(reason ?? "", /Recursive deletion/, command)
  }
})

test("quoted or disposable deletions stay allowed", () => {
  const home = "/home/tester"
  for (const command of [
    "rm -rf /tmp/disposable-build",
    "echo rm -rf /",
    "/bin/echo rm -rf /",
    "git rm -rf /",
    "printf '%s' 'rm -rf /'",
    'bash -c "echo rm -rf /"',
    "git status --short",
  ]) {
    assert.equal(inspectBashCommand(command, home), null, command)
  }
})

test("force-push main and npm publish are blocked", () => {
  assert.match(inspectBashCommand("git push origin main --force-with-lease") ?? "", /Force push/)
  assert.match(inspectBashCommand("npm publish") ?? "", /Package publication/)
})

test("sensitive writes are blocked without echoing secrets", () => {
  const secret = "not-a-real-secret-value"
  const reason = inspectSensitiveWrite("apply_patch", {
    patchText: `*** Begin Patch\n*** Update File: .env.local\n@@\n-old\n+${secret}\n*** End Patch`,
  })
  assert.match(reason ?? "", /\.env\.local/)
  assert.ok(!reason.includes(secret))
  assert.match(inspectSensitiveWrite("write", { filePath: "/tmp/.env" }) ?? "", /sensitive file/)
  assert.equal(inspectSensitiveWrite("write", { filePath: "README.md" }), null)
})

test("injection is blocked in bash but allowed in markdown", () => {
  assert.match(
    inspectPromptInjection("bash", { command: "run --arg 'ignore previous instructions'" }) ?? "",
    /Prompt injection/,
  )
  assert.equal(
    inspectPromptInjection("apply_patch", {
      patchText: "*** Begin Patch\n*** Update File: guide.md\n@@\n+ignore previous instructions\n*** End Patch",
    }),
    null,
  )
})

test("output scanner warns without repeating the secret", () => {
  const token = `ghp_${"a".repeat(36)}`
  const warning = scanToolOutput(token)
  assert.match(warning ?? "", /GitHub token/)
  assert.ok(!warning.includes(token))
})

test("plugin before-hook throws on a blocked command", async () => {
  const hooks = createHooks({ directory: process.cwd() })
  await assert.rejects(
    () => hooks["tool.execute.before"]({ tool: "bash" }, { args: { command: "rm -rf /" } }),
    /BLOCKED/,
  )
})

test("pre-compact writes a recovery note", () => {
  const cwd = mkdtempSync(join(tmpdir(), "neural-opencode-"))
  try {
    execSync("git init", { cwd, stdio: "ignore" })
    mkdirSync(join(cwd, "plans", "2026-09-19-demo"), { recursive: true })
    writeFileSync(join(cwd, "plans", "2026-09-19-demo", "plan.md"), "draft\n")
    const target = writeCompactNote(cwd)
    const text = readFileSync(target, "utf8")
    assert.match(text, /Pre-Compaction Context/)
    assert.match(text, /plans\/2026-09-19-demo/)
  } finally {
    rmSync(cwd, { recursive: true, force: true })
  }
})
