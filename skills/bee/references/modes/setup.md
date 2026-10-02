# 🐝 bee · setup

Goal: one short interview → a saved config → a smoke test. Keep every question to one line. Use AskUserQuestion when available; otherwise ask in plain text. Skip any question the user already answered.

## 0. Prerequisite check (say what's missing, don't stop)
- Beeper Desktop connected? Run ToolSearch "Beeper" → any tool found = yes. If no: point to README → Prerequisites (enable Beeper Desktop API / MCP, then connect it in Cowork).
- Note which of these connectors exist: Google Drive, GitHub, Notion, a browser (built-in or Chrome), a linked computer (`device_*` tools), Anthropic memory (`memory_*`).

## 1. Interview (in this order)
1. **Your name** — how bee should address you. Default: first name from context.
2. **Memory backend** — options, in this order:
   - **Google Drive vault** (default) — "an Oaa2B vault in Google Drive (github.com/jkelvin-com/Oaa2B)". Needs the Google Drive connector. Find the `Vault/0-inbox` folder id once and save it. If the connector is missing, say so and offer the GitHub vault.
   - **GitHub vault** (fallback relay) — "an Obsidian-style vault in a GitHub repo, Oaa2B layout". Ask `owner/repo` and branch (default `main`). If the GitHub connector is missing, say so and offer the next option.
   - **Local vault folder** — a folder on this computer. Ask the path; request folder access.
   - **Notion** — ask for the styles page (title or URL) and the notes database (title or URL). Needs the Notion connector.
   - **NotebookLM** — ask for the notebook URL. Needs a browser tool. Warn it's slower and append-only.
   - **None** — bee works without memory (no recall log, no moments, no report).
3. **Layout** (vault backends only) — "Oaa2B layout" default: notes are created only in `0-inbox`, frontmatter on line 1, `↑ [[INBOX]]` as the first body line, filename `<slug>-<agent>-<surface>-YYYY-MM-DD-HHMM.md`, never edit a file bee did not create. (Older `obsidian-ai` layout: `AI/` folder, first line `[[AI]]`, for repos that have not moved.) Offer "custom" → ask write folder, filename pattern, first line, base tags.
4. **Agent name** — prefix for note filenames: `claude` (default) / `chatgpt` / `gemini` / `grok` / other.
5. **Timezone** — default from the session's timezone.
6. **Send cadence** — default one paragraph per message, 1–2 s apart. Ask only "keep default?".

## 2. Bootstrap the backend (vault backends)
- Drive vault: nothing to bootstrap, the vault already exists; just read `START-HERE.md` and `9-system/sys-law.md`. For an empty GitHub repo or folder that lacks `AI/` (older `obsidian-ai` layout only): create `AI/AI.md` hub note (`# AI` + one line) and, if missing, a minimal `CORE/INSTRUCTIONS.md` copied from `${CLAUDE_PLUGIN_ROOT}/templates/INSTRUCTIONS.template.md` (with the user's name substituted). Ask before creating anything in a non-empty repo.
- If the style notes (`me-talk-preferences`, `me-writing-voice`) are missing, tell the user: "bee reads your writing style from those vault notes — I'll create it the first time you show me a sample or describe a register."

## 3. Save
Per `references/config.md`: write `/areas/bee-config.md` to Anthropic memory (if present) and `~/.bee/config.json` on the linked computer (if present). Write a `setup` note to the backend (`notes.md` stream D). Never store tokens or secrets.

## 4. Smoke test
1. `get_accounts` → list the connected networks in one line.
2. Backend read: fetch the rules file (vault) / styles page (Notion) / open the notebook (NotebookLM) → "backend OK" or the error in one line.
3. Finish with a 3-line numbered summary: backend · agent name · what to try first (bare `/bee` = triage).

## Reconfigure
"switch bee to <backend>" → run only steps 1.2–1.3 for that backend, keep everything else, re-save, re-run the smoke test.
