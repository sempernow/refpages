# [Claude Code Docs](https://code.claude.com/docs/en/overview) | [Cookbooks](https://github.com/anthropics/claude-cookbooks) | [Quickstarts](hhttps://github.com/anthropics/claude-quickstarts) | [Learn/Build](https://www.anthropic.com/learn/build-with-claude) | [Courses](https://github.com/anthropics/courses)

Two types of accounts:

## Consumer : "__Claude.ai__" Subscription

AKA __Claude Pro__ 

This is for both web and CLI interfaces (*platforms*), but not for developing an agentic system around the Anthropic/Claude API. So, all but API access.

- Access:
    - Web chat, mobile app, desktop app
        - URL: `claude.ai`
    - `claude` CLI app (Claude Code) - "__recommended__" account
        - Note the *recommended* accounts do *not* have API access.
- AuthN: Email link
- Cost: $20/mo or __$200/yr__

## Developer: "__Claude Developer Platform__" Pay Per Play

AKA "__Anthropic Console Account__" AKA "__API Plan__". 

This is for developing agentic systems that are clients of the Anthropic/Claude API.

- Access:
    - API
    - Claude Console (2 addresses; identical app)
        - URL: [`platform.claude.com`](https://platform.claude.com/dashboard)
        - URL: [`console.anthropic.com`](https://console.anthropic.com/dashboard)
    - `claude` CLI app (Claude Code) - alternative account
- AuthN: OAuth2
- Cost: Pay-per-use (based on tokens/API calls)

Reportedly, if API key is set (`ANTHROPIC_API_KEY`), 
then `claude` CLI app will use that.


## Install `claude` CLI 

@ Linux/WSL

```bash
# Install
curl -fsSL https://claude.ai/install.sh | bash

# On fail
npm uninstall -g @anthropic-ai/claude-code
rm -rf ~/.npm-global/lib/node_modules/@anthropic-ai/claude-code
rm -rf ~/.npm-global/lib/node_modules/@anthropic-ai
hash -d claude
nvm reinstall v24.1.0
curl -fsSL https://claude.ai/install.sh | bash

# Verify
claude --version
```


## Usage

### [Configuration](https://code.claude.com/docs/en/settings)

Claude documents __many types__ of context (Rule, Prompt, Task, Skill, Context file, etc.). They are semantical/conceptual/organizational aides only. All are consumed by Claude in the same way and for the same purpose; they all provide context. 

__Add context/prompts by markdown__ file(s):

### Context Scope

- __User__ (all projects): `~/.claude/rules`
- __Project__: At project root:
    - `CLAUDE.md`
    - `.claude/rules` 
- __Session__:
    - `claude @/path/to/context.md`


### System Prompt

```bash
claude --system-prompt "..."
claude --system-prompt-file /path/to/prompt/file
claude --append-system-prompt "..."
```

The default system prompt (embedded; not a file) has a good reputation. It's heavily tuned around Claude Code's own tools, and most people who replace it outright end up with an agent that edits files clumsily, misuses tools, or forgets conventions. Don't replace it; extend it.

For DevOps work, the gaps aren't in the default prompt. They're about your environment, which it can't know. The usual setup has three layers.

#### 1. `CLAUDE.md` for standing context 

This is where most of your value is. Put things the model would otherwise guess wrong:

@ `CLAUDE.md`

```markdown
# Environment
- Target hosts: RHEL 8/9, FIPS mode enabled, STIG-hardened. No non-FIPS crypto
  (no md5 for security purposes, no custom TLS ciphers outside the approved set).
- Kubernetes: k0s and kubeadm clusters. Assume air-gapped unless told otherwise;
  images come from the internal registry, never Docker Hub.
- CI: GitLab CI. Runners use the Kubernetes executor.

# Rules
- Never run kubectl/helm against a context unless I've named it this session.
  Always show `kubectl config current-context` first.
- Prefer `--dry-run=server`, `helm diff`, and `terraform plan` before any apply.
- Manifests and Ansible must be idempotent. No `curl | bash`.
- SELinux stays enforcing. Fix contexts; don't disable it.
- Don't touch firewalld, sshd_config, or auditd rules without asking.
```

#### 2. Permission rules for actual safety.

A prompt is only a request; permissions are enforced. In `.claude/settings.json`, use `deny` rules for things like `Bash(kubectl delete:*)`, `Bash(helm uninstall:*)`, and `Bash(terraform apply:*)`, and require approval for anything that touches a live cluster. For anything compliance-sensitive, rely on this layer rather than on wording in `CLAUDE.md`.

**3. Hooks for checks.** A PreToolUse hook can block commands that match a pattern, for example anything with `--context=prod`. A PostToolUse hook can run `yamllint`, `kubeconform`, `shellcheck`, or `ansible-lint` after edits. The output goes back to the model, so it fixes its own mistakes.

Use `--append-system-prompt` only for per-session tweaks, like "this session is read-only investigation." Replace the whole prompt only if you're building something that isn't really Claude Code, such as a narrow CI bot run with `-p`.

---

### [CLI Reference](https://code.claude.com/docs/en/cli-reference)

Agent SDK via CLI

Use at a configured project having `CLAUDE.md` and such,  
else ad-hoc: "[Programmatic AKA Headless Usage](https://code.claude.com/docs/en/headless)"

```bash
claude --help
claude update # to latest version

cd /project/root

# Start session with 
claude  
claude --model haiku # opus, sonnet, haiku (most to least expensive)

# System prompt : Is session-scoped : Overrides CLAUDE.md etal
# - Use markdown if complex, else plaintext.                  
claude --system-prompt "..."
claude --system-prompt-file /path/to/prompt/file
claude --append-system-prompt "..."

# Pre-approve tools
claude --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *)"

# Start session in planning mode
claude --permission-mode plan $name # acceptEdits, bypassPermissions, default, delegate, dontAsk, plan
# Print response and quit; headless, trusted, one-query mode.
claude --permission-mode plan -p "$query" --output-format text # --print, -p

# Resume from last session
claude -p "..." -c # --continue

# Add an MCP server
claude mcp add # Syntax per remote vs. local
# Use an MCP server
claude use $name
```

In-app commands
```ini
# Ask side question without interrupting current work
/btw
```

Examples

```bash
claude -p "Look at my staged changes and create an appropriate commit" \
    --allowedTools "Bash(git diff *),Bash(git log *),Bash(git status *),Bash(git commit *)"

gh pr diff "$1" |claude -p \
    --append-system-prompt "You are a security engineer. Review for vulnerabilities." \
    --output-format json

claude -p "Summarize this project" --output-format json

# Extract structured output
claude -p "Extract function names from auth.py" \
    --output-format json \
    --json-schema '{"type":"object","properties":{"functions":{"type":"array","items":{"type":"string"}}},"required":["functions"]}' \
    |jq '.structured_output'
```


__In-app Shortcuts__

```bash
> /
```
- __Dropdown menu__ select


### `coderabbit review --agent`


Prompt at a `claude` session:

```plaintext
> Make a full review of this project's latest changes using coderabbit review --agent and then take the feedback from coderabbit to implement solutions to the issues it found.
```
- Reference : [**`coderabbit.ai`**](https://www.coderabbit.ai/)

## [Models](https://platform.claude.com/docs/en/about-claude/models/overview)

__Declare a model__ at session start:

```bash
claude --model haiku # Most to least capable: opus, sonnet (default), haiku
```

__Change__ model or other __configuration__ during a session:

```bash
> /config
```

## [Prompt Generator](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompt-generator) | [Prompt Library](https://platform.claude.com/docs/en/resources/prompt-library/library)

__Prompt Engineering__

## Sub-agents

Claude automatically spawns specialized sub-agents when tasks match their capabilities:, as it needs them. 

| Agent Type        | I Use It When...                                      | Example Request                    |
|-------------------|-------------------------------------------------------|------------------------------------|
| Explore           | Broad codebase searches, understanding architecture   | "How does authentication work?"    |
| Plan              | Need to design implementation approach before coding  | "Add user authentication"          |
| claude-code-guide | You ask about Claude Code features or API             | "Can Claude Code use MCP servers?" |
| general-purpose   | Complex multi-step tasks requiring deep investigation | "Find and fix all memory leaks"    |

Subagents are stored as Markdown files with YAML frontmatter in two possible locations:

|Type             |Location            |Scope                        |Priority|
|-----------------|--------------------|-----------------------------|--------|
|Project subagents|`.claude/agents/`   |Available in current project |Highest|
|User subagents   |`~/.claude/agents/` |Available across all projects|Lower|

When subagent names conflict, project-level subagents take precedence over user-level subagents.

### Create 

```bash
claude 
> /agents
```
- Select "Create New Agent"

### Use

```bash
> Use the code-reviewer subagent to check my recent changes
```

### Customize

```bash
claude --agents '{
  "code-reviewer": {
    "description": "Expert code reviewer. Use proactively after code changes.",
    "prompt": "You are a senior code reviewer. Focus on code quality, security, and best practices.",
    "tools": ["Read", "Grep", "Glob", "Bash"],
    "model": "sonnet"
  }
}'
```

## [Add tools via MCP](https://code.claude.com/docs/en/mcp)

MCP Servers

```bash
claude mcp add ...
```

Scopes:

* `--scope user` (default) : Saved to `~/.claude.json` 
    — Persists across all your projects
* `--scope project` : Saved to `.mcp.json` in current __project root__ 
    — Persists for that specific project only

### [Context7](https://github.com/upstash/context7 "GitHub : upstash/context7") | [API Guide](https://context7.com/docs/api-guide)

__URLs__

- MCP: https://mcp.context7.com/mcp
- API: https://context7.com/api/v2

#### 1. 


```bash
# Get list of MCP keys : []{name, workspace, date, expiry, description, secret}
yq ~/.config/keys.yaml

# Set key
export CONTEXT7_API_KEY="$(yq '.[] | select(.name == "context7-key-01").secret' ~/.config/keys.yaml)"

# Remote
claude mcp add --transport http context7 https://mcp.context7.com/mcp --header "CONTEXT7_API_KEY: $CONTEXT7_API_KEY"

# Local
claude mcp add context7 -- npx -y @upstash/context7-mcp --api-key "$CONTEXT7_API_KEY"

# Use
claude use context7
```

### [Taskmaster MCP Server](https://github.com/eyaltoledano/claude-task-master)

A task management system AKA project manager for AI-driven development; handles the workflow of a PRD; works with any AI chat.

```bash
claude mcp add taskmaster-ai -- npx -y task-master-ai
```

Create a PRD:

.taskmaster/docs/prd.txt

### [GitHub MCP Server](https://github.com/github/github-mcp-server)

```bash
export GITHUB_PAT="$(yq '.[] | select(.name == "github-pat-01").secret' keys.yaml)"

# Remote
claude mcp add --transport http github https://api.githubcopilot.com/mcp -H "Authorization: Bearer $GITHUB_PAT"

# Local
claude mcp add github -e GITHUB_PERSONAL_ACCESS_TOKEN="$GITHUB_PAT" -- \
    docker run -i --rm -e GITHUB_PERSONAL_ACCESS_TOKEN ghcr.io/github/github-mcp-server
```

### [GitLab MCP Server](https://docs.gitlab.com/user/gitlab_duo/model_context_protocol/mcp_server/) | [Docker Hub](https://hub.docker.com/r/mcp/gitlab)

__Requires manual approval by in-browser popup__

```bash
claude mcp add --transport http GitLab https://gitlab.com/api/v4/mcp

```

## [Embeddings](https://platform.claude.com/docs/en/build-with-claude/embeddings)

## Plugins vs. Standalone

__Standalone__  
Best for personal workflows, __project-specific__ customizations, quick experiments

- Useage: `/hello`
- Location: `~/.claude/`	

__Plugins__  
Best for sharing with teammates, distributing to community, versioned releases, __reusable across projects__

- Usage: `/plugin-name:hello`
- Location: `.claude-plugin/plugin.json`

[Plugins Marketplace](https://code.claude.com/docs/en/discover-plugins)

```bash
> /plugin install plugin-name@claude-plugins-official
```
- Pay to use

## [Agent SDK : Build Autonomous Agents](https://platform.claude.com/docs/en/agent-sdk/quickstart)

## `claude` CLI AuthN

### Q: 

Since your API accounts are segregated from your claude CLI accounts, 
how does claude CLI authenticate against its backend knowing it does NOT use the API key?

### A:

...Based on the search results, here's how Claude Code authenticates when NOT using an API key:

#### Claude Code Authentication Method: OAuth 2.0

When you run `claude /login` and select option 2 ("Claude app" - for claude.ai subscriptions), 
Claude Code uses **OAuth 2.0 authentication**:

##### The Flow:

1. **You run** `claude /login` in the terminal
2. **CLI starts a local web server** on your machine (usually on localhost:8080 or similar)
3. **Browser opens** automatically to Anthropic's OAuth authorization page
4. **You authenticate** via the browser using your claude.ai credentials
5. **OAuth tokens are issued**:
   - Access token (e.g., `sk-ant-oat01-...`)
   - Refresh token (e.g., `sk-ant-ort01-...`)
   - Expiration timestamp
6. **Tokens are stored securely**:
   - **macOS**: In the encrypted macOS Keychain
   - **Linux**: In __`~/.claude/.credentials.json`__
   - **Windows**: In encrypted credential storage

##### Credentials File Structure:

```json
{
  "claudeAiOauth": {
    "accessToken": "sk-ant-oat01-...",
    "refreshToken": "sk-ant-ort01-...",
    "expiresAt": 1748658860401,
    "scopes": ["user:inference", "user:profile"]
  }
}
```

##### Key Points:

- **Completely separate from API keys** - OAuth tokens authenticate against your claude.ai subscription, not the console.anthropic.com API
- **Automatic token refresh** - The CLI automatically refreshes expired access tokens using the refresh token
- **Secure storage** - Uses OS-level credential storage (Keychain on macOS, etc.)
- **Session-based** - These tokens link your CLI session to your claude.ai account and subscription tier

This is why the two systems are segregated - API authentication uses API keys (`sk-ant-api03-...`), while subscription authentication uses OAuth tokens (`sk-ant-oat01-...`).



## Call API (`api.anthropic.com`) using `curl` : [`api-call.sh`](api-call.sh)

Fixed after signing up to the pay-per-use account at `console.anthropic.com` .
~~This is failing~~ because the API scheme requires a "console" account (pay-as-you-go), 
though their site has claude.ai account "recommended" instead.

```bash
export ANTHROPIC_API_KEY="$(yq '.[] |select(.name == "anthropic-key-01").secret' keys.yaml)"
curl -s https://api.anthropic.com/v1/messages ... 
```
- See [`api-call.sh`](api-call.sh)

```bash
bash api-call.sh
```
- Response: 
    - On fail: [`api-call.1.json`](api-call.1.json) :  "`Your credit balance is too low ...`"
    - On success: [`api-call.2.json`](api-call.2.json)


---

