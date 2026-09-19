---
description: "Create a new agent for the project. Usage: /meta:agent <name> <purpose>"
allowed-tools: Read, Write, Glob, Grep
---

# Create Agent Command

Generate a new project-specific agent with the Agent Expert pattern.

## Arguments

- `$ARGUMENTS` - Agent name and purpose (e.g., "api-expert Handles API design and documentation")

## Process

### 1. Parse Arguments

Extract from $ARGUMENTS:
- **name**: kebab-case agent name (first word)
- **purpose**: Agent description (remaining words)

If no arguments provided, ask the user:
- What should the agent be called?
- What is its purpose?

### 2. Check for Existing Agent

Look for:
```
.opencode/agents/<name>.md
```

If exists, ask user to confirm overwrite or choose different name.

### 3. Create Agent Directory Structure

Ensure directories exist:
```
.opencode/agents/
.opencode/expertise/
```

### 4. Generate Agent File

Create `.opencode/agents/<name>.md`:

```markdown
---
name: {name}
description: {purpose}
mode: subagent
tools:
  read: true
  write: true
  edit: true
  glob: true
  grep: true
  bash: false
model: sonnet
---

# {Name} Agent

{purpose}

## Expertise File

Your mental model: `.opencode/expertise/{name}.yaml`

**ALWAYS read this first**, validate against reality, then act.

## The Agent Expert Pattern

1. **READ** → Load expertise file
2. **VALIDATE** → Verify information is current
3. **EXECUTE** → Perform task with expertise
4. **IMPROVE** → Update expertise with learnings

## Capabilities

### Primary Function
{purpose}

### Supporting Tasks
- Maintain expertise file with learnings
- Apply consistent patterns
- Identify improvements

## After Every Task

Update your expertise file with:
- New patterns discovered
- Successful approaches
- Edge cases encountered
- Lessons learned

## Usage

Invoke by asking Claude to use the {name} agent or by describing tasks matching: {purpose}
```

### 5. Generate Expertise File

Create `.opencode/expertise/<name>.yaml`:

```yaml
# {Name} Expertise
# Mental model - auto-updated by agent

domain: {domain from purpose}
version: 1
last_updated: {timestamp}

understanding:
  primary_purpose: "{purpose}"
  key_concepts: []
  related_files: []

patterns:
  successful: []
  failed: []

lessons_learned: []

open_questions:
  - "What are the common use cases?"
  - "What patterns work best?"
```

### 6. Update Project AGENTS.md

Add agent to the agents table if AGENTS.md exists.

### 7. Report Success

```markdown
## Agent Created

**Name**: {name}
**Location**: `.opencode/agents/{name}.md`
**Expertise**: `.opencode/expertise/{name}.yaml`

### Purpose
{purpose}

### Usage
Ask Claude to use the {name} agent, or describe tasks matching its purpose.

### Next Steps
1. The agent will learn as it works
2. Run `/meta:improve {name}` to sync expertise with reality
3. Check `.opencode/expertise/{name}.yaml` for learnings
```
