# 🐝 bee · report

Backend `none` → say "no memory backend — run `/bee setup`" and stop.

## Steps
1. **Scope** — client (match `client:` frontmatter and the Client/context column, case-insensitive) and window (default: this month; accept "this week", "last 30 days", explicit dates). Config timezone.
2. **Collect** — list the backend's write dir and read every `bee-moments` note whose `date` falls in the window (GitHub: list `AI/`, filter `-bee-moments-`; local: `ls`; Notion: query `Kind = moments` and Date range; NotebookLM: ask the notebook chat for the rows and verify by opening the sources). Keep only matching rows.
3. **Draft** — default format: numbered lines, chronological, `DD Mon · what happened · evidence`. Then one line `Total: N items, <first date> → <last date>`. Offer the formats "letter" (use the user's own letter template if the backend holds one, e.g. in `CORE/preferences.md`), "table", or "WhatsApp message" (then **reply** mode sends it as one formatted message).
4. **Gaps** — if a row lacks evidence, mark `(no evidence)` and list those rows at the end so the user can attach proof.
5. **Persist** — write the report as a `recall`-style note? No — reports are derived; write them as `AI/<agent>-<stamp>-bee-report-<client>-<window>.md` with `tags: [ai, bee-report]` only when the user says "save".

## Rules
- Only moments rows. Never pull Beeper messages into a report unless the user explicitly says "include chats".
- Never send a report to the client without the full **reply** show-and-approve flow.
