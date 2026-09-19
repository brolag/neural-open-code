---
description: Manage installed skills - enable, disable, update, uninstall
allowed-tools: Bash, Read
---

# Manage Skills Command

Interactive manager for installed skills. Control which skills are active without uninstalling them.

## Usage

```bash
# Interactive menu
/manage-skills

# Quick list
/manage-skills --list
```

## Features

### 1. List Installed Skills

Shows all skills with their status:
- ✓ Active (loaded by OpenCode)
- ○ Disabled (installed but not loaded)

Organized by location:
- **Project**: `./.opencode/skills/`
- **Global**: `~/.config/opencode/skills/`

### 2. Enable/Disable Skills

**Toggle any skill without uninstalling:**
- Disabled skills moved to `.opencode/skills/.disabled/`
- Enabled skills moved back to `.opencode/skills/`
- Preserves all skill files and references
- Takes effect immediately (no restart needed)

**Use cases:**
- Disable skills you rarely use
- Test skills individually
- Reduce memory usage
- Prevent skill conflicts

### 3. Update Skills

Pull latest versions from plugin repository:
- Updates project skills
- Updates global skills
- Updates all at once
- Preserves active/disabled status

### 4. Uninstall Skills

Permanently remove skills:
- Select location (project/global)
- Choose skill to remove
- Confirmation required
- Can uninstall active or disabled skills

### 5. Install New Skills

Launches `/install-skills` command to add more skills.

## How Enable/Disable Works

```
Active Skill:
.opencode/skills/debugging/
  ├── SKILL.md
  └── references/

↓ Disable

Disabled Skill:
.opencode/skills/.disabled/debugging/
  ├── SKILL.md
  └── references/

↓ Enable

Back to Active
```

**OpenCode only loads skills from `.opencode/skills/`**
- Disabled skills in `.disabled/` are ignored
- No configuration files needed
- Simple file-based system

## Example Workflow

```bash
# 1. See what's installed
/manage-skills --list

# Output:
# Project Skills (./.opencode/skills/)
#
# Active:
#   ✓ debugging
#   ✓ tdd
#   ✓ slop-scan
#
# Disabled:
#   ○ react-best-practices
#   ○ knowledge-management

# 2. Enable a disabled skill
/manage-skills
# → Select "Enable/Disable skills"
# → Select "Project"
# → Choose "react-best-practices" to enable

# 3. Update all skills to latest
/manage-skills
# → Select "Update skills from plugin"
# → Select "Update all"

# 4. Uninstall unused skill
/manage-skills
# → Select "Uninstall skills"
# → Select "Global"
# → Choose skill to remove
```

## Output Format

```markdown
## Installed Skills

**Project Skills** (./.opencode/skills/)

Active:
  ✓ debugging
  ✓ tdd
  ✓ slop-scan
  ✓ slop-fix
  ✓ overseer

Disabled:
  ○ react-best-practices (rarely used)
  ○ knowledge-management (testing)

**Global Skills** (~/.config/opencode/skills/)

Active:
  ✓ deep-research

Disabled:
  (none)

**Total**: 7 installed (6 active, 1 disabled)
```

## Common Tasks

### Disable a skill temporarily

```bash
/manage-skills
# → Enable/Disable skills → Project
# → Select skill number to disable
```

### Re-enable when needed

```bash
/manage-skills
# → Enable/Disable skills → Project
# → Select disabled skill number to enable
```

### Update all skills monthly

```bash
/manage-skills
# → Update skills from plugin → Update all
```

### Clean up unused skills

```bash
/manage-skills
# → Uninstall skills → Select location
# → Choose skills to remove
```

## Error Handling

| Error | Cause | Resolution |
|-------|-------|------------|
| Skill not found | Already uninstalled | Check with --list first |
| Permission denied | Can't write to directory | Check directory permissions |
| Plugin not found | OPENCODE_PLUGIN_ROOT not set | Set environment variable |

**Fallback**: Manually move directories:
```bash
# Disable manually
mv .opencode/skills/skill-name .opencode/skills/.disabled/

# Enable manually
mv .opencode/skills/.disabled/skill-name .opencode/skills/
```

## Performance Benefits

Disabling unused skills can:
- Reduce OpenCode startup time
- Lower memory usage
- Prevent skill trigger conflicts
- Simplify skill selection menus

**Example:**
- Before: 20 skills loaded = ~500ms startup
- After: 6 skills active = ~150ms startup

## Integration

Works with:
- `/install-skills` - Install new skills
- Plugin updates - `git pull` in plugin directory

Preserves:
- Skill files and references
- Custom modifications (if any)
- Active/disabled status across updates

---

**Version**: 1.0.0
**Created**: 2026-02-01
