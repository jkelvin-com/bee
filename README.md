# Beeper Bee 🐝

> Plugin id: `bee` · display name: **Beeper Bee 🐝**

bee reads your Beeper inbox, replies **in your own voice**, finds old messages, sets follow-ups, and keeps a timestamped log of real-life moments (especially work you finished for clients) so you can build a report later.

Your writing style is **never stored in the plugin**. bee pulls it live from a memory backend you choose — a Google Drive vault (default), a GitHub vault (fallback relay), a local Obsidian folder, Notion, or NotebookLM — so it stays yours and keeps updating.

> **Install with your AI in one line:** paste this into Claude (Cowork) and it will do the rest —
> `Install the bee plugin from https://github.com/jkelvin-com/bee — follow INSTALL-FOR-AI.md`

---

## What you get

| Say | Mode | Does |
|---|---|---|
| `/bee` or "bee, what's new?" | **triage** *(default)* | Numbered digest of EVERY unread chat (muted and low-priority included), urgent first, a draft per reply |
| `/bee reply Sam …` | **reply** | Drafts in your register, shows every edit, sends paragraph-by-paragraph |
| `/bee recall invoice` | **recall** | Literal search + timeline + summary; can save as a recall note |
| `/bee remind Jamie tomorrow 9am` | **remind** | Native Beeper reminders; "who am I waiting on" |
| `/bee log quotation sent to Acme Co` | **log** | Timestamped moment, kept separate from chat recalls |
| `/bee report Acme Co this month` | **report** | Numbered deliverables list from the moments log |
| `/bee dispatch` | **dispatch** | Sends the replies you confirmed (queued in `Workings/bee-send/`), hourly routine |
| `/bee setup` | **setup** | Interview → picks backend, name, timezone; smoke test |
| `/bee help` | — | Prints the mode list |

One command, the mode is the first argument. Plain English still works, "who needs a reply?" goes to triage without you typing the mode. Aliases: `inbox`/`unread`/`catchup` → triage · `send`/`tell`/`fix` → reply · `find`/`search` → recall · `followup`/`waiting`/`snooze` → remind · `moment`/`done` → log · `config`/`switch` → setup.

Two streams, never mixed: **moments** (real life, `bee-moments`) vs **recall** (pulled out of Beeper, `bee-recall`). Each is its own note type/tag so you can search either alone.

---

## Prerequisites

1. **Claude Cowork** (desktop app) — bee is a Cowork plugin.
2. **Beeper Desktop** running on the same computer, with the **Desktop API / MCP** enabled (Beeper → Settings → Developer → *Beeper Desktop API* → enable, copy the access token). Then connect it in Cowork as a local MCP (it appears as *Beeper Desktop*). If Cowork already lists Beeper Desktop under your connectors, you're done.
3. **One memory backend** (pick during setup):
   - **Google Drive vault** (default) — an Oaa2B vault in Google Drive ([setup](https://github.com/jkelvin-com/Oaa2B)) + the **Google Drive connector** in Cowork.
   - **GitHub vault** (fallback) — a repo holding an Obsidian-style vault + the **GitHub connector** in Cowork. Empty repo is fine; setup bootstraps the layout.
   - **Local vault folder** — a folder on this Mac/PC; you'll be asked to grant folder access.
   - **Notion** — the **Notion connector** + a page for styles and a database for notes.
   - **NotebookLM** — a notebook URL; needs the built-in browser or Claude in Chrome. Slower, append-only.
   - **None** — triage/reply/remind still work; no log, recall notes, or reports.
4. Optional: **Anthropic memory** enabled in Claude settings — bee stores its config there so it follows you across devices. Without it, config lives in `~/.bee/config.json` on the linked computer.

---

## Install

**A. From a release (easiest)**
1. Download `bee.plugin` from the [latest release](https://github.com/jkelvin-com/bee/releases/latest).
2. In Cowork, drop the file into a chat (or open it) → **Install plugin**.
3. Say **"set up bee"** (or `/bee setup`) and answer the short interview.

**B. From source**
```bash
git clone https://github.com/jkelvin-com/bee
cd bee && bash scripts/package.sh      # → dist/bee.plugin
```
Then install `dist/bee.plugin` as above.

**C. Let your AI do it**
Send Claude the repo link with: *"Install the bee plugin from https://github.com/jkelvin-com/bee — follow INSTALL-FOR-AI.md."* The AI reads that file, checks prerequisites, packages the plugin, hands you the `.plugin` file to accept, and runs `/bee setup`.

---

## Configuration

Stored by `/bee setup`; see `config/bee.config.example.json`. Key fields:

```json
"backend": { "type": "drive-vault", "drive": { "root": "brain", "vault_folder": "Vault", "inbox_folder_id": "<0-inbox folder id>", "layout": "oaa2b" } }
```

**Oaa2B layout** (default for vault backends): AIs only create new files in `0-inbox`, titled `<slug>-<agent>-<surface>-YYYY-MM-DD-HHMM.md`, frontmatter on line 1, `↑ [[INBOX]]` as the first body line, never edit files they didn't create. Styles are read from the vault notes `me-talk-preferences` and `me-writing-voice`; registers bee learns before they are filed live in `0-inbox` as `bee-style-*` notes. (The older `obsidian-ai` layout, `AI/` folder with `[[AI]]`, is still supported for repos that have not moved.) Custom layouts: add a `layout_<name>` block and point `backend.<type>.layout` at it.

Switch backend any time: *"switch bee to Notion"*.

---

## How replies stay in your voice

1. bee picks a register from who you're writing to (`friend-en`, `client`, `formal`, …) and reads that register from your backend at run time.
2. Unknown register → bee asks you to describe it or paste a sample, saves it as a style note in your backend (and to Anthropic memory if enabled), then continues.
3. Every proposed edit is shown as `"original" → "proposed"` and waits for your ruling. Nothing is fixed silently.
4. Sending: one paragraph per message, 1–2 s apart (configurable); formatted/official text goes as one message.

---

## Privacy & safety

- No message content, style text, or tokens are stored in this repo or the plugin.
- bee never sends, archives, or sets reminders on a chat you didn't name in the conversation.
- OTPs / codes / card numbers seen in chats are never repeated back.
- The Beeper access token stays in your Cowork connector settings (`BEEPER_ACCESS_TOKEN`), never in config notes.

---

## Repo layout

```
.claude-plugin/plugin.json   manifest
.mcp.json                    connector declarations (Beeper Desktop, GitHub, Notion)
skills/bee/SKILL.md          the one skill — router + shared rules
skills/bee/references/       backends.md · config.md · sending.md · notes.md (shared)
skills/bee/references/modes/ triage · reply · recall · remind · log · report · setup
templates/                   vault bootstrap files for empty repos
config/                      example config
scripts/package.sh           builds dist/bee.plugin
.github/workflows            builds a release on every v* tag
INSTALL-FOR-AI.md            step list an AI follows to install bee for you
```

## Versioning & backup

Versions follow the 3-6-9 scheme starting at **v3.6.9.0** (next: v3.6.9.1, v3.6.9.2 …). Every release is a git tag + a `bee.plugin` asset. Your installed copy, this repo, and the release asset are three independent copies. Vault backends additionally get a `setup` note recording which bee version configured them.

MIT © 2026 富源承忠 jKelvin.com
