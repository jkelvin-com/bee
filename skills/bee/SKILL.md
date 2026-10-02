---
name: bee
description: "Beeper helper, ONE command, the mode is the first argument. Use on \"/bee\", \"bee\", \"hey bee\", or any request about the user's Beeper / WhatsApp / Instagram / Telegram / iMessage chats. Modes: triage (\"what's new\", \"who needs a reply\", \"unread\", \"catch me up\"), reply (\"reply to X\", \"tell X\", \"write back to X as me\", \"fix this before sending\"), recall (\"what did X say about\", \"search my chats\", \"did X mention\"), remind (\"follow up with X\", \"who am I waiting on\", \"what did I promise\"), log (\"log this\", \"done for [client]\", \"timestamp this\"), report (\"report for [client]\", \"what got done\"), dispatch (\"send the confirmed replies\", \"run the send routine\"), setup (\"set up bee\", \"switch bee to Notion / local vault / GitHub\")."
---

# 🐝 bee

One skill, one slash command. The **first argument is the mode**; everything after it is the payload.

```
/bee [mode] [rest of the request]
bee [mode] [rest]                  ← bare form, no slash, works the same
```

## Modes

| first arg (and its aliases) | mode | reference file |
|---|---|---|
| `triage` · `inbox` · `new` · `unread` · `catchup` · *(nothing)* | **triage** | `modes/triage.md` |
| `reply` · `send` · `tell` · `write` · `msg` · `fix` | **reply** | `modes/reply.md` |
| `recall` · `find` · `search` · `when` | **recall** | `modes/recall.md` |
| `remind` · `followup` · `waiting` · `promised` · `snooze` · `clear` | **remind** | `modes/remind.md` |
| `log` · `moment` · `done` · `record` | **log** | `modes/log.md` |
| `report` · `deliverables` · `summary` | **report** | `modes/report.md` |
| `dispatch` · `outbox` · `flush` · `autosend` | **dispatch** | `modes/dispatch.md` |
| `setup` · `config` · `backend` · `install` · `switch` | **setup** | `modes/setup.md` |
| `help` · `?` · `modes` | print the mode list in 3 lines, do nothing |

## Dispatch

1. Take the first token of the argument. Match it against the table (case-insensitive).
2. **No match, or no argument at all** — read the request in plain language and pick the mode from the trigger phrases in the description above. Still ambiguous → ask ONE short question, then dispatch. Bare `/bee` with nothing else → **triage**.
3. Read `${CLAUDE_PLUGIN_ROOT}/skills/bee/references/modes/[mode].md` and follow it verbatim. **Load only that one mode file** — never all of them.
4. Everything after the mode token is the payload: `/bee reply Sam say the invoice can wait` → reply mode, target `Sam`, brief `say the invoice can wait`.

## Shared rules — apply in EVERY mode

1. **Load config** first — `references/config.md`. Not set up → run **setup** mode, then continue.
2. **Backend** — read/write only through the adapter in `references/backends.md`. A failed write never blocks the job; say it in one line.
3. **Sending** — `references/sending.md`. Show, wait for go, paragraph-per-message, 1–2 s apart.
4. **Two streams never mix** — `references/notes.md`. Real-life moments → `bee-moments`; anything pulled from Beeper → `bee-recall`.
5. **Beeper tool names** vary by host: in Cowork desktop they are `mcp__remote-devices__Beeper_Desktop__*`; in a direct MCP connection `mcp__Beeper_Desktop__*` or `mcp__beeper__*`. If none is loaded, run ToolSearch for "Beeper" once; if still none, tell the user Beeper Desktop isn't connected (see README prerequisites) and stop.
6. **Beeper search is literal, not semantic** — single words, ALL words must match. Search participants for people, titles for groups.
7. **Address the user** by `config.user_name`. Replies to the user: short numbered lines, no preamble.
8. **Both sides** — any durable rule or register the user states → backend note AND Anthropic memory (if `memory_*` tools exist) in the same turn.
9. **Never** send, archive, or set reminders on a chat the user did not name in this conversation. One exception: **dispatch** sends a `SEND-` file from `Workings/bee-send/`, which is the user's confirmation written down.
10. **Workings** — scheduled routines write their output to `<workings.root>/<routine>/` (example `brain/Workings/`) per `references/workings.md`. Read it for routine runs only.
11. **Unattended runs** (scheduled routine, nobody to ask): never stop to ask a question; take the documented default, say what was assumed in one line, keep going.

## Chaining

Modes hand off to each other inside the same run — say which mode is taking over, do not ask the user to type a second command:
`triage → reply` · `triage → dispatch` (via `queue N`) · `remind → reply` · `reply → log` · `report → reply`.

## Routines (scheduled)
- Every 3 hours, 9:27 to 0:27 (config timezone): `/bee triage routine` → reconcile every unread message, drafts, save `NOW.md`.
- Hourly at :12, 9:12 to 0:12 (the 9:12, 12:12, 15:12, 18:12, 21:12 and 0:12 runs land 15 minutes before each triage): `/bee dispatch` → send the replies the user confirmed, then record each one in `Workings/bee-triage/decisions/`.
- Claude Code reconcile (outside this plugin): learns from `decisions/` into `me-reply-patterns`.
