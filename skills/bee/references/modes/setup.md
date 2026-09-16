# 🐝 bee · setup

Goal: one short interview → a saved config → a smoke test. Keep every question to one line. Use AskUserQuestion when available; otherwise ask in plain text. Skip any question the user already answered.

## 0. Prerequisite check (say what's missing, don't stop)
- Beeper Desktop connected? Run ToolSearch "Beeper" → any tool found = yes. If no: point to README → Prerequisites (enable Beeper Desktop API / MCP, then connect it in Cowork).
- Note which of these connectors exist: GitHub, Notion, a browser (built-in or Chrome), a linked computer (`device_*` tools), Anthropic memory (`memory_*`).

## 1. Interview (in this order)
1. **Your name** — how bee should address you. Default: first name from context.
2. **Memory backend** — options, in this order:
   - **GitHub vault** (default) — "an Obsidian-style vault in a GitHub repo". Ask `owner/repo` and branch (default `main`). If the GitHub connector is missing, say so and offer the next option.
   - **Local vault folder** — a folder on this computer. Ask the path; request folder access.
   - **Notion** — ask for the styles page (title or URL) and the notes database (title or URL). Needs the Notion connector.
   - **NotebookLM** — ask for the notebook URL. Needs a browser tool. Warn it's slower and append-only.
   - **None** — bee works without memory (no recall log, no moments, no report).
3. **Layout** (vault backends only) — "obsidian-ai" default: notes go only in `AI/`, first line `[[AI]]`, filename `<agent>-YYYY-MM-DD-HHMM-slug.md`, `tags: [ai]`. Offer "custom" → ask write folder, filename pattern, first line, base tags.
4. **Agent name** — prefix for note filenames: `claude` (default) / `chatgpt` / `gemini` / `grok` / other.
5. **Timezone** — default from the session's timezone.
6. **Send cadence** — default one paragraph per message, 1–2 s apart. Ask only "keep default?".

## 2. Bootstrap the backend (vault backends, obsidian-ai layout)
- If the repo/folder is empty or lacks `AI/`: create `AI/AI.md` hub note (`# AI` + one line) and, if missing, a minimal `CORE/INSTRUCTIONS.md` copied from `${CLAUDE_PLUGIN_ROOT}/templates/INSTRUCTIONS.template.md` (with the user's name substituted). Ask before creating anything in a non-empty repo.
- If `TOPICS/writing-voice.md` is missing, tell the user: "bee reads your writing style from `TOPICS/writing-voice.md` — I'll create it the first time you show me a sample or describe a register."

## 3. Save
Per `references/config.md`: write `/areas/bee-config.md` to Anthropic memory (if present) and `~/.bee/config.json` on the linked computer (if present). Write a `setup` note to the backend (`notes.md` stream D). Never store tokens or secrets.

## 4. Smoke test
1. `get_accounts` → list the connected networks in one line.
2. Backend read: fetch the rules file (vault) / styles page (Notion) / open the notebook (NotebookLM) → "backend OK" or the error in one line.
3. Finish with a 3-line numbered summary: backend · agent name · what to try first (bare `/bee` = triage).

## Reconfigure
"switch bee to <backend>" → run only steps 1.2–1.3 for that backend, keep everything else, re-save, re-run the smoke test.
