# Backend adapters — how bee reads styles and writes notes

Every bee skill calls three abstract operations. The adapter for the configured backend decides how.

| Operation | Meaning |
|---|---|
| `read_style(register)` | Fetch the user's writing rules for a register (e.g. `friend-en`, `client`, `formal`, `aggressive`) |
| `write_note(kind, slug, body, frontmatter)` | Create a note. `kind` ∈ `moments` · `recall` · `style` · `setup` |
| `append_note(ref, line)` | Append to a note bee created earlier (moments log for the day) |

Load config first (see `config.md`). `backend.type` picks the adapter below. If the backend call fails twice, tell the user in one line and continue the job without persistence — never block a reply or a triage on a failed note write.

---

## 1. `github-vault` (default — obsidian-ai layout)

Tools: GitHub connector (`get_file_contents`, `create_or_update_file`). Config: `backend.github.{owner,repo,branch,layout}`.

**Session start (once):** read `layout.rules_file` (default `CORE/INSTRUCTIONS.md`) and obey it. Read `layout.heartbeat_file`; if `last_sync` is older than 2 h, say "relay looks stale (last sync <time>)" once and prefer the local fallback below if a vault folder is connected.

**read_style(register):**
1. Read each path in `layout.style_files`. Defaults: `TOPICS/writing-voice.md` (the user's own voice) and `CORE/preferences.md` (client / ghostwriting register, letter formats).
2. List `layout.write_dir` and read any file matching `layout.learned_style_glob` whose frontmatter `style:` equals `register` — these are registers bee learned that the vault's reconcile hasn't promoted yet.
3. If nothing matches the register → return `unknown` (the calling mode then asks the user — see `modes/reply.md`).

**write_note:** path = `{write_dir}{filename}` with `{agent}` from config, timestamp in `config.timezone`, slug = kind + short topic (`bee-moments-2026-09-11`, `bee-recall-sam-invoice`, `bee-style-formal`). Content:
```
[[AI]]
---
tags: [ai, bee-<kind>]
<extra frontmatter>
---
<body>
```
The first line must be exactly the layout's `first_line`. Never write outside `write_dir`. Never modify a file bee did not create.

**append_note:** `get_file_contents` for the SHA → `create_or_update_file` with SHA and the merged body. On 409 / SHA mismatch: re-read, merge, retry once; second failure → create a new note with `-conflict` suffix and say so.

**Local fallback:** if a connected folder matches `backend.local.folder` (or contains an `.obsidian/` directory), do the same reads/writes with `device_bash` under `$HOME/mnt/<folder>/`.

---

## 2. `local-vault` (Obsidian folder on the user's computer)

Tools: `device_list_dir`, `device_bash`, `device_commit_files`. Config: `backend.local.{folder,layout}`. Requires the folder to be connected in Cowork; if it is not, call `device_request_folder_access` once with `backend.local.folder`.

Same layout rules as `github-vault` (obsidian-ai layout by default). Reads with `cat`, writes with a heredoc via `device_bash` into `$HOME/mnt/<folder>/<write_dir>/…`. Appends with `>>` on files bee created. No SHA dance needed. If the computer is offline → say so once, continue without persistence.

---

## 3. `notion`

Tools: Notion connector (search, fetch page, create page, append blocks). Config: `backend.notion.{styles_page, notes_database}`.

**read_style:** fetch `styles_page`; registers are H2 sections whose heading equals the register name (`friend-en`, `client`, `formal` …). Unknown heading → `unknown`.

**write_note:** create a page in `notes_database` with properties `Name` (slug), `Kind` (select: moments/recall/style/setup), `Tags` (multi-select), `Date`, `Client` (text, moments only), `Reclassify` (checkbox). Body = the note body as paragraphs.

**append_note:** append a paragraph block to the page bee created today for that kind. New styles learned → append an H2 section to `styles_page` ONLY if the user explicitly says so; otherwise create a `style` page in the database and tell the user to merge it.

---

## 4. `notebooklm`

NotebookLM has no API. Tools: the built-in browser (`Claude_Browser__*`) or Claude in Chrome. Config: `backend.notebooklm.notebook_url`. Slower; prefer it only when the user chose it.

**read_style:** open the notebook, use the notebook's chat box with the question "Quote verbatim the writing style rules for register: <register>". Treat the answer as the style text; if it says nothing is found → `unknown`.

**write_note:** open the notebook → "Add source" → "Copied text" → paste the note (same `[[AI]]`/frontmatter format so it can be migrated later) → title = the filename bee would have used. Then confirm the source appears in the list.

**append_note:** NotebookLM sources are immutable — add a new source per append with a `-part2`, `-part3` suffix and mention it in the day's summary.

Before driving the browser, check the session actually has a browser tool; if not, say "NotebookLM backend needs the built-in browser or Claude in Chrome — skipping persistence this run".

---

## 5. `none`

No persistence. Triage, reply, remind work fully. **log**, **recall** and **report** modes say "no memory backend configured — run `/bee setup`" and stop.

---

## Both-sides rule (all backends)

When Anthropic memory tools (`memory_*`) exist in the session, every durable fact bee learns (a new register, a standing rule the user states) is ALSO written to Anthropic memory in the same turn. Moments and recalls are NOT mirrored to Anthropic memory — they belong to the backend only.
