---
name: bee
description: Beeper helper — ONE command, the mode is the first argument. Use on "/bee", "bee", "hey bee", or any request about the user's Beeper / WhatsApp / Instagram / Telegram / iMessage chats. Modes are triage ("what's new", "who needs a reply", "unread", "catch me up", "anything urgent"), reply ("reply to X", "tell X", "send X", "write back to X as me", "fix this before sending"), recall ("what did X say about", "find the message where", "search my chats", "when did we agree", "did X mention"), remind ("remind me about X", "follow up with X", "who am I waiting on", "who hasn't replied", "clear the reminder", "what did I promise"), log ("log this", "note that I", "moment", "done for [client]", "mark complete", "timestamp this"), report ("report for [client]", "what did we complete", "summarise this week's moments", "what got done"), setup ("set up bee", "install bee", "configure bee", "switch bee to Notion / local vault / NotebookLM / GitHub", "change my vault").
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
9. **Never** send, archive, or set reminders on a chat the user did not name in this conversation.

## Chaining

Modes hand off to each other inside the same run — say which mode is taking over, do not ask the user to type a second command:
`triage → reply` · `remind → reply` · `reply → log` · `report → reply`.
