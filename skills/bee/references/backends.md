# Backend adapters — how bee reads styles and writes notes

Every bee skill calls three abstract operations. The adapter for the configured backend decides how.

| Operation | Meaning |
|---|---|
| `read_style(register)` | Fetch the user's writing rules for a register (e.g. `friend-en`, `client`, `formal`, `aggressive`) |
| `write_note(kind, slug, body, frontmatter)` | Create a note. `kind` ∈ `moments` · `recall` · `style` · `setup` |
| `append_note(ref, line)` | Append to a note bee created earlier (moments log for the day) |

Load config first (see `config.md`). `backend.type` picks the adapter below (`drive-vault` is the default). If the backend call fails twice, tell the user in one line and continue the job without persistence — never block a reply or a triage on a failed note write.

---

## 1. `drive-vault` (default, Oaa2B layout, Google Drive)

Tools: Google Drive connector (`search_files`, `read_file_content`, `create_file`). Config: `backend.drive.{root,vault_folder,inbox_folder_id,layout}`. Drive is the master copy. Vault law v2: **AIs only create new files in `0-inbox`**. Never edit, move, rename, trash or share a file bee did not create. Never rewrite anything in a `data/` folder. These vault rules do not cover `brain/Workings/`, which follows `workings.md` (rename-as-status).

**Session start (once):** `search_files` for title `START-HERE.md`, read it first (trust line, rules in short, live handoff). Read `9-system/state/HEARTBEAT.md` (title `HEARTBEAT.md`); if `last_sync` is older than 2 h, say "relay looks stale (last sync <time>)" once and treat vault reads as possibly stale. Full law: `9-system/sys-law.md` (search title `sys-law.md`). If `backend.drive.inbox_folder_id` is empty, find the `0-inbox` folder under the vault folder (`backend.drive.root`/`vault_folder`) once and save its id to config.

**read_style(register):**
1. `search_files` by title for each name in `layout.style_notes` (`me-talk-preferences`, `me-writing-voice`) and read them. If a title is not found, fall back to Anthropic memory `/topics/writing-style.md` and `/preferences.md`.
2. Read `me-reply-patterns` (title `me-reply-patterns.md`, kept by the Claude Code reconcile from the decisions ledger). Use the **person** section for this chat first (match by name or chat id), then the **category** section. Learned patterns refine the style notes; where they conflict, the newer and more specific one wins (person over category over register). Not found yet → skip silently.
3. Search `0-inbox` for `bee-style-<register>` notes (registers bee learned that the reconcile has not filed yet) and read the newest.
4. Nothing matches the register: return `unknown` (the calling mode then asks the user, see `modes/reply.md`).

**write_note(kind, slug, body, frontmatter):** `create_file` with `parentId` = the `0-inbox` folder id, `contentMimeType: text/markdown`, **`disableConversionToGoogleType: true`**, title `<slug>-<agent>-<surface>-YYYY-MM-DD-HHMM.md` (slug first, time last, local time (config timezone), surface `cowork`). Content:
```
---
agent: claude
surface: cowork
created: 2026-09-29T14:32:00+00:00
kind: note
op_id: claude-2026-09-29T14:32-<slug>
summary: <one line>
tags: [bee-<kind>]
---
↑ [[INBOX]]

<body>
```
Line 1 is the frontmatter. `↑ [[INBOX]]` is the first body line. Never retry a create that succeeded (Drive allows duplicate titles): on an error, `search_files` for the title first. Links form a tree: link only up to `INBOX`; name any other note as plain text in backticks.

**append_note(ref, line):** existing notes cannot be edited. Create a new note with `kind: append` and `target: <ref slug>`; the reconcile merges it into the target. For a moment, `target: bee-moments-<YYYY-MM-DD>`.

**Fallback:** Drive connector missing or failing twice: use the `github-vault` adapter below (it reaches Drive in about 36 seconds), and say so in one line.

---

## 2. `github-vault` (fallback relay, Oaa2B layout)

Tools: GitHub connector (`get_file_contents`, `create_or_update_file`). Config: `backend.github.{owner,repo,branch,layout}`. GitHub is a two-way relay of the Drive vault, not the master. Same create-only law as Drive.

**Session start (once):** read `START-HERE.md` from the repo root, then `9-system/HEARTBEAT.md`; stale rule as above.

**read_style / write_note:** same names and formats as `drive-vault`. `write_note` = `create_or_update_file` for a NEW path `0-inbox/<slug>-<agent>-<surface>-YYYY-MM-DD-HHMM.md` (no `sha`). Never touch an existing path. `append_note` = a new `kind: append` note, as in `drive-vault`.

**Local fallback:** if a connected folder holds the vault, do the same with `device_bash` under `$HOME/mnt/<folder>/0-inbox/`.

---

## 3. `local-vault` (Obsidian folder on the user's computer)

Tools: `device_list_dir`, `device_bash`, `device_commit_files`. Config: `backend.local.{folder,layout}`. Requires the folder to be connected in Cowork; if it is not, call `device_request_folder_access` once with `backend.local.folder`.

Same layout rules as `drive-vault` (Oaa2B layout by default). Reads with `cat`, writes with a heredoc via `device_bash` into `$HOME/mnt/<folder>/<write_dir>/…`. Appends with `>>` on files bee created. No SHA dance needed. If the computer is offline → say so once, continue without persistence.

---

## 4. `notion`

Tools: Notion connector (search, fetch page, create page, append blocks). Config: `backend.notion.{styles_page, notes_database}`.

**read_style:** fetch `styles_page`; registers are H2 sections whose heading equals the register name (`friend-en`, `client`, `formal` …). Unknown heading → `unknown`.

**write_note:** create a page in `notes_database` with properties `Name` (slug), `Kind` (select: moments/recall/style/setup), `Tags` (multi-select), `Date`, `Client` (text, moments only), `Reclassify` (checkbox). Body = the note body as paragraphs.

**append_note:** append a paragraph block to the page bee created today for that kind. New styles learned → append an H2 section to `styles_page` ONLY if the user explicitly says so; otherwise create a `style` page in the database and tell the user to merge it.

---

## 5. `notebooklm`

NotebookLM has no API. Tools: the built-in browser (`Claude_Browser__*`) or Claude in Chrome. Config: `backend.notebooklm.notebook_url`. Slower; prefer it only when the user chose it.

**read_style:** open the notebook, use the notebook's chat box with the question "Quote verbatim the writing style rules for register: <register>". Treat the answer as the style text; if it says nothing is found → `unknown`.

**write_note:** open the notebook → "Add source" → "Copied text" → paste the note (same `[[AI]]`/frontmatter format so it can be migrated later) → title = the filename bee would have used. Then confirm the source appears in the list.

**append_note:** NotebookLM sources are immutable — add a new source per append with a `-part2`, `-part3` suffix and mention it in the day's summary.

Before driving the browser, check the session actually has a browser tool; if not, say "NotebookLM backend needs the built-in browser or Claude in Chrome — skipping persistence this run".

---

## 6. `none`

No persistence. Triage, reply, remind work fully. **log**, **recall** and **report** modes say "no memory backend configured — run `/bee setup`" and stop.

---

## Both-sides rule (all backends)

When Anthropic memory tools (`memory_*`) exist in the session, every durable fact bee learns (a new register, a standing rule the user states) is ALSO written to Anthropic memory in the same turn. Moments and recalls are NOT mirrored to Anthropic memory — they belong to the backend only.
