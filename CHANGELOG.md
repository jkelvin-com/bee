# Changelog

All notable changes to Beeper Bee. Versions follow the 3-6-9 scheme: the first release is v3.6.9.0.

## v3.7.0.1 (2026-10-02) , second public release

- Defaults to a Google Drive vault in the **Oaa2B layout** (github.com/jkelvin-com/Oaa2B): create-only into `0-inbox`, frontmatter on line 1, `↑ [[INBOX]]` first, stamped names the vault relay strips to the slug. GitHub becomes the fallback relay. The older `obsidian-ai` layout still works.
- New **dispatch** mode: sends replies you already confirmed (`Workings/bee-send/SEND-` files), with a lock-rename, and holds a send on gaps, a stale or missing chat, or a duplicate.
- New `references/workings.md`: routine output lives in a `Workings/` folder beside the vault, one folder per routine, and the file title is the status (the Drive connector cannot rewrite content).
- Routine triage (`/bee triage routine`) keeps one live board, `NOW.md`: every open item carries forward until you actually reply, your edited drafts are never overwritten (new messages get a separate redraft), and resolved items move to a 7-day History. Old boards move to `bee-triage/archive/`. Any assistant that can rename files republishes the board right after you change a draft.
- New decisions ledger `Workings/bee-triage/decisions/`: every reply that goes out, sent by dispatch or typed by hand, leaves a `DECISION-` file with the incoming message, up to 10 earlier messages of the thread, Bee's draft, the final text and a verdict (as-drafted, edited, rewritten, own-words). A reconcile job can learn from it how you reply per person and per category into `me-reply-patterns`.
- `read_style` and triage drafting read `me-reply-patterns` first: person, then category, then register.
- Triage reads every unread chat: primary and low-priority inboxes, muted included, no 20-chat cap, full paging. Adds `queue N`. Unattended runs never stop to ask.
- Example routine timings: triage every 3 hours 9:27 to 0:27, dispatch hourly at :12.
- Example config ships placeholder ids and names only.

## v3.6.9.2 (2026-09-15) , first public release

- Sanitised for public use: every example now uses generic names (Sam, Jamie, Acme Co) and the example config ships placeholder values.
- The default note layout is renamed from `chloe` to `obsidian-ai`. A config that still says `"layout": "chloe"` keeps working, no migration needed.
- Added `scripts/package.sh`, a tagged release workflow, and this changelog.

## v3.6.9.1 (2026-09-15) , one command

- The 8 skills (`bee` plus 7 `bee-*` sub-skills) collapse into a single `bee` skill. The mode is now the first argument: `/bee [mode] [rest]`.
- Modes live in `skills/bee/references/modes/` and are loaded one at a time, so a run reads the router plus one mode file instead of carrying 8 skill descriptions.
- Mode aliases added (`inbox`, `unread`, `catchup`, `send`, `tell`, `fix`, `find`, `search`, `followup`, `waiting`, `snooze`, `moment`, `done`, `config`, `switch`).
- Bare `/bee` still runs triage. `/bee help` lists the modes. Plain English still routes without a mode word.

## v3.6.9.0 (2026-09-11) , first build

- Skills: bee, bee-setup, bee-triage, bee-reply, bee-recall, bee-remind, bee-log, bee-report.
- Four memory backends: GitHub vault, local vault folder, Notion, NotebookLM, plus `none`.
- Two separate note streams: moments (real life) and recall (pulled from Beeper).
