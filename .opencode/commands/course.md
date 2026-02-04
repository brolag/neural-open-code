---
description: Interactive Agentic Coding Mastery Course - learn agentic coding with Neural OpenCode
allowed-tools: Read, Write, Edit, Glob
---

# Agentic Coding Course

Interactive terminal course for mastering autonomous AI-assisted development.

## Usage

```bash
# Show course menu and progress
/course

# Start from beginning
/course start

# Jump to specific lesson
/course lesson <number>

# Check progress
/course progress

# Quick reference
/course ref <topic>

# Practice exercises
/course practice <lesson-number>

# Reset progress
/course reset
```

## Execution

When user invokes `/course`:

1. **Read progress file** at `.opencode/memory/course/progress.json`
2. **Parse arguments** to determine action

### No arguments → Show Menu

Display course structure with progress indicators:

```
╔═══════════════════════════════════════════════════════════════════╗
║              AGENTIC CODING MASTERY                               ║
║              Interactive Terminal Course                          ║
╠═══════════════════════════════════════════════════════════════════╣
║                                                                   ║
║  Your Progress: [████░░░░░░░░░░░░░░░░] X/13 lessons              ║
║                                                                   ║
║  FUNDAMENTALS                                                     ║
║  [status] 1. The Reality Check                                   ║
║  [status] 2. Mental Models                                       ║
║  [status] 3. Your First Autonomous Task                          ║
║                                                                   ║
║  STRUCTURED PROMPTS                                               ║
║  [status] 4. CRAFT Framework                                     ║
║  [status] 5. 6 Core Areas                                        ║
║  [status] 6. 3-Tier Boundaries                                   ║
║                                                                   ║
║  AUTONOMOUS OPERATIONS                                            ║
║  [status] 7. Loop Fundamentals                                   ║
║  [status] 8. Circuit Breakers                                    ║
║  [status] 9. State Management                                    ║
║                                                                   ║
║  ADVANCED PATTERNS                                                ║
║  [status] 10. Multi-Agent Orchestration                          ║
║  [status] 11. Context Engineering                                ║
║  [status] 12. Compute Advantage                                  ║
║                                                                   ║
║  MASTERY                                                          ║
║  [status] 13. Building Your System                               ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════════╝
```

Status indicators:
- ✅ = completed
- ⏳ = current (next to do)
- ○ = pending
- 🔒 = locked (advanced lessons before prerequisites)

### `start` → Begin from Lesson 1

Read and display `.opencode/skills/agentic-course/lessons/01-reality-check.md`

### `lesson N` → Show Lesson N

Read and display `.opencode/skills/agentic-course/lessons/0N-*.md`

### `ref <topic>` → Quick Reference

Read and display `.opencode/skills/agentic-course/references/<topic>.md`

Available topics: craft, boundaries, loops, kpi

### `progress` → Show Detailed Progress

Display completion stats and next recommended lesson.

### `reset` → Clear Progress

Reset `.opencode/memory/course/progress.json` to initial state.

## Progress File Location

`.opencode/memory/course/progress.json`

## Lesson Files Location

`.opencode/skills/agentic-course/lessons/`

## Reference Cards Location

`.opencode/skills/agentic-course/references/`

## Output Format

When showing a lesson:
1. Clear header with lesson number and title
2. Lesson content in full
3. Navigation footer with next lesson command

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| Lesson not found | Invalid number | Show valid range 1-13 |
| Progress file missing | First time | Create default progress |
| Reference not found | Invalid topic | List available topics |

**Fallback**: If any file missing, offer to regenerate from course skill.

---
*Neural OpenCode - Learn by doing*
