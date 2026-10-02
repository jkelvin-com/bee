# INSTALL-FOR-AI.md — instructions for an AI assistant installing bee on a user's behalf

You are an AI (Claude Cowork or similar) and the user sent you this repository link asking you to install **bee**. Follow these steps in order. Keep your messages to the user short and numbered.

## 1. Check prerequisites (report each in one line, don't stop on failures)
1. **Cowork plugin support** — can you deliver a `.plugin` file the user can accept (SendUserFile or equivalent)? If not, tell the user to open this in the Claude desktop app (Cowork) and stop.
2. **Beeper Desktop MCP** — search your tools for "Beeper" (`search_chats`, `send_message` …). If none: tell the user to enable *Beeper Desktop API* in Beeper (Settings → Developer) and connect it in Cowork, then continue anyway — bee can be installed now and used once Beeper is connected.
3. **Backend connectors** — note which exist: Google Drive, GitHub, Notion, a browser tool, a linked computer (`device_*`), Anthropic memory (`memory_*`).

## 2. Get the plugin
Prefer the release asset: fetch `https://github.com/jkelvin-com/bee/releases/latest` and download `bee.plugin`.
If no release exists or the download is blocked, build from source:
```bash
git clone --depth 1 https://github.com/jkelvin-com/bee /tmp/bee && cd /tmp/bee && bash scripts/package.sh /tmp/bee-dist
```
Result: `/tmp/bee-dist/bee.plugin`.

## 3. Validate before delivering
- `.claude-plugin/plugin.json` parses; `name` is `bee`.
- `skills/bee/SKILL.md` exists with `name: bee` + `description` frontmatter, and `skills/bee/references/modes/` holds all 8 mode files.
- `.mcp.json` parses.
Report "validated v<version>" or the exact failure.

## 4. Deliver
Send `bee.plugin` to the user with the caption: "Beeper Bee 🐝 v<version> — accept to install, then say **set up bee**."

## 5. Run setup
After the user confirms installation, run `/bee setup` (or, if the plugin isn't active yet in this session, read `skills/bee/references/modes/setup.md` from the clone and follow it verbatim). Default backend: Google Drive vault with the Oaa2B layout (`brain`, create-only into `0-inbox`); GitHub `owner/repo` is the fallback relay. Offer local folder / Notion / NotebookLM / none.

## 6. Finish
Three numbered lines: backend chosen · Beeper status · "try `/bee` for a triage, `/bee help` for the modes".

## Don'ts
- Don't store the Beeper token anywhere except the connector settings.
- Don't write into the user's vault outside the layout's write folder (`0-inbox` in Oaa2B layout, `AI/` in the older layout).
- Don't rename the plugin or the single `bee` skill, and don't split the modes back into separate skills.

## Validation gotchas (learned the hard way)
- Skill `description:` frontmatter must contain **no angle brackets** — Cowork reads `<client>` as an XML tag and rejects the plugin. Use `[client]`.
- Keep `name:` in each SKILL.md equal to its folder name.
