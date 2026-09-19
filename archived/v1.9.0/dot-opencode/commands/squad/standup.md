---
description: Generate Neural Squad daily standup report with KPIs
allowed-tools: Bash, Read
---

# /squad-standup

Generate a daily standup report for Neural Squad with task summary, agent status, and KPIs.

## Usage

```bash
# Display standup in terminal
/squad-standup

# Send to Telegram
/squad-standup --telegram
```

## Execution

```bash
bash .opencode/scripts/squad/standup.sh
bash .opencode/scripts/squad/standup.sh --telegram
```

## Report Contents

1. **Task Summary**: Count by status (inbox, assigned, in-progress, review, done)
2. **Agent Status**: Each agent's current state and last heartbeat
3. **Today's KPIs**: Plan Velocity, Review Velocity, Autonomy Duration
4. **Compute Advantage**: Weekly average CA score
5. **Recent Activity**: Last 5 heartbeat events
6. **Completed Today**: Tasks finished today

## Output Format

```
╔══════════════════════════════════════════════════════════════╗
║              NEURAL SQUAD - DAILY STANDUP                    ║
║                     2026-02-03                               ║
╚══════════════════════════════════════════════════════════════╝

═══ TASK SUMMARY ═══

📥 Inbox:       2
📋 Assigned:    1
🔨 In Progress: 1
👀 Review:      0
✅ Done:        5

═══ AGENT STATUS ═══

  ● Architect: idle (last: 10:00:00)
  ● Dev: working (last: 10:02:00)
  ● Critic: idle (last: never)

═══ TODAY'S KPIs ═══

⚡ Plan Velocity:    8 min avg
⚡ Review Velocity:  3 min avg
🤖 Autonomy:         45 min total

═══ COMPUTE ADVANTAGE ═══

📊 Weekly Avg CA: 8.4x

═══ RECENT ACTIVITY ═══

  10:02:00 [dev] task_start: Starting task-001
  10:00:00 [architect] heartbeat: HEARTBEAT_OK

═══ COMPLETED TODAY ═══

  ✅ Implement hello world function
  ✅ Add user validation
```

## Telegram Message

When `--telegram` is used:

```
🤖 *Neural Squad Standup - 2026-02-03*

📊 *Task Queue*
• Inbox: 2
• In Progress: 1
• Review: 0
• Done today: 2

⚡ *KPIs*
• Plan Velocity: 8 min
• Review Velocity: 3 min
• Autonomy: 45 min

Use `/squad-status` for details.
```

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| No KPI data | First day using | Track with `/kpi` commands |
| Telegram failed | Not configured | Set up `.opencode/scripts/.telegram-config` |
| No activity | Fresh install | Run agents to generate activity |

**Fallback**: If KPI files missing, show "N/A" and continue with available data.
