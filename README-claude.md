# Claude Code config in these dotfiles

## The rule
**chezmoi never owns a file Claude Code writes to.**

`~/.claude/settings.json` is *both* declared config (hooks) and runtime state
(`model`, `theme`, `effortLevel`, `tui`, `voiceEnabled`, ...). Claude Code
rewrites it on every `/config` and `/model` change. Managing it as a whole file
made two machines clobber each other's UI state on every sync. It is now
managed with a chezmoi `modify_` script, which owns **specific keys** instead.

## What is synced

| Path | How | Why |
|---|---|---|
| `~/.claude/CLAUDE.md` | plain file | yours, app never writes it |
| `~/.claude/commands/*.md` | plain files | hand-written slash commands |
| `~/.claude/skills/knowledge-system/` | plain files | hand-written skill |
| `~/.claude/skills/chezmoi/` | `.chezmoiexternal.toml` | upstream git repo, track the source |
| `~/.claude/settings.json` | `dot_claude/modify_settings.json` | key-level merge, see below |
| `~/.agents/.skill-lock.json` | plain file | manifest for third-party skills |
| marketplaces + plugins | `run_onchange_after_10-claude-plugins.sh` | from `dot_claude/managed-plugins.json` |
| user-scope MCP servers | `run_onchange_after_20-claude-mcp.sh` | from `dot_claude/mcp-servers.json` |
| third-party skills | `run_onchange_after_30-claude-skills.sh` | `npx skills add` from the lock file |

## What is NOT synced (deliberately)
`~/.claude.json` (115KB of machine state: userID, statsig caches, per-project
history), and every runtime dir under `~/.claude` — see `.chezmoiignore`.
`~/.claude/plugins/` and `~/.agents/skills/` are caches; the scripts rebuild them.

## Changing shared settings
Edit the `MANAGED` JSON block in `dot_claude/modify_settings.json`.
Anything you put there is enforced on every machine. Anything you leave out is
per-machine and passes through untouched. Rule of thumb: **if it is toggleable
from `/config`, leave it out.**

## New machine
```sh
chezmoi init --apply git@github.com-personal:inspmoore/dotfiles.git
```
Requires `claude` on PATH and network for the bootstrap scripts. `jq` is used by
the merge script; macOS ships it at `/usr/bin/jq`. If it is ever missing the
script passes settings through unchanged rather than destroying them.

## Adding a plugin / MCP server / skill
Change it normally (`/plugin`, `claude mcp add -s user ...`, `npx skills add -g ...`),
then refresh the manifest so the other machine gets it:
```sh
# plugins
python3 - <<'PY'
import json,os
s=json.load(open(os.path.expanduser('~/.claude/settings.json')))
p=os.path.expanduser('~/.local/share/chezmoi/dot_claude/managed-plugins.json')
m=json.load(open(p)); m['plugins']=sorted(k for k,v in s.get('enabledPlugins',{}).items() if v)
json.dump(m,open(p,'w'),indent=2); open(p,'a').write('\n')
PY
# mcp
python3 -c "import json,os;d=json.load(open(os.path.expanduser('~/.claude.json')));json.dump(d.get('mcpServers',{}),open(os.path.expanduser('~/.local/share/chezmoi/dot_claude/mcp-servers.json'),'w'),indent=2)"
# skills
chezmoi add ~/.agents/.skill-lock.json
```
