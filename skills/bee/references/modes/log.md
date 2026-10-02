# 🐝 bee · log

Backend `none` → say "no memory backend — run `/bee setup`" and stop.

## What counts as a moment
Anything the user says is worth keeping: a deliverable sent, a client confirmation, a payment received, a call completed, a decision made, an agreement reached, a milestone, a personal event. If the user says "log this" without detail, take the last thing discussed in this conversation.

## Steps
1. **Build the row** — time (now, config timezone, unless the user gives one), client/context, what happened (past tense, one line, completed fact), evidence (Beeper deeplink from the current thread, file name, or `—`). Ask ONE question only if the client/context is missing and cannot be inferred.
2. **Show the row** in one line and wait only if anything was inferred; if everything came from the user, write immediately.
3. **Write** — `append_note` (stream A): a NEW `0-inbox` note with `kind: append`, `target: bee-moments-<YYYY-MM-DD>`, the table header plus the row. Notes cannot be edited, so never look for today's note to append to. Add `client:` frontmatter when the row is client work. Keep `reclassify: true` so the reconcile can file it into the right project later.
4. **Confirm** — one line: `📌 logged 14:32 · Acme Co · quotation Q-0912 sent · bee-moments-claude-cowork-2026-09-11-1432.md`.

## Rules
- Moments notes contain only rows the user asked to log — never triage output, never recall results.
- Never invent a timestamp; if the user says "earlier" and no time, ask.
- Batch: "log these 3" → 3 rows, one note (one create).
