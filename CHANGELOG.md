# Changelog

All notable changes to Beeper Bee. Versions follow the 3-6-9 scheme: the first release is v3.6.9.0.

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
