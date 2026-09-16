# SNAPSHOT , Beeper Bee 🐝 as at 15 September 2026

State of the project at the moment it was handed over for publishing. Version **3.6.9.2**.

## What bee is

A Claude Cowork plugin that works your Beeper inbox: triage what needs a reply, draft and send replies in your own voice, search and recall old messages, set native Beeper reminders, and keep a timestamped log of real-life moments you can turn into a client report later.

The thing that makes it different from a prompt: **your writing style is never stored in the plugin**. bee reads your registers from a memory backend you choose at setup, so the style stays yours and keeps updating as you teach it.

## Shape of the thing

One skill. The mode is the first argument, the same grammar as a CLI.

```
/bee [mode] [rest of the request]
bee [mode] [rest]            ← bare form works too
```

| mode | aliases | what it does |
|---|---|---|
| `triage` | `inbox` `new` `unread` `catchup` , and bare `/bee` | numbered digest of unread chats, urgent first, counts at the end |
| `reply` | `send` `tell` `write` `msg` `fix` | picks the register, drafts or fixes, shows every edit, sends paragraph by paragraph |
| `recall` | `find` `search` `when` | literal search across chats, numbered timeline, summary, optional saved note |
| `remind` | `followup` `waiting` `promised` `snooze` `clear` | native Beeper chat reminders, plus "who am I waiting on" |
| `log` | `moment` `done` `record` | one timestamped row into the day's moments note |
| `report` | `deliverables` `summary` | reads only moments rows, drafts a client or period report |
| `setup` | `config` `backend` `install` `switch` | one short interview, saves config, smoke test |
| `help` | `?` `modes` | prints the mode list |

Plain English still routes without a mode word. "Who needs a reply?" goes to triage, "reply to Sam" goes to reply.

## How a run loads

`SKILL.md` (about 4 KB: router, grammar, the 9 shared rules, the chaining map) plus exactly one mode file (1 to 3 KB). Nothing else. That is the reason for the single-skill shape: the host used to carry 8 skill descriptions in every session and load a whole sub-skill per call.

## File map

```
.claude-plugin/plugin.json        manifest, v3.6.9.2
.mcp.json                         Beeper Desktop (localhost + env token), GitHub, Notion
skills/bee/SKILL.md               the one skill
skills/bee/references/
  config.md                       where settings live, schema, loading and saving
  backends.md                     the 4 backend adapters + none
  sending.md                      find chat, show before send, cadence, reply threading
  notes.md                        the 4 note streams and their exact formats
  modes/                          triage reply recall remind log report setup
config/bee.config.example.json    placeholder values only
templates/INSTRUCTIONS.template.md  vault bootstrap for an empty repo
scripts/package.sh                builds dist/bee.plugin
.github/workflows/release.yml     validate, build, attach to a tagged release
README.md INSTALL-FOR-AI.md CHANGELOG.md LICENSE HANDOFF.md SNAPSHOT.md
```

## Standing design decisions

1. **Two streams never mix.** Moments (real life, `bee-moments`) and recall (pulled out of Beeper, `bee-recall`) are separate note kinds with separate tags, so a report can read one without dragging in the other.
2. **Style is read, never stored.** `read_style(register)` hits the backend at run time. An unknown register stops the run and asks, then saves what the user says as a style note and mirrors it to platform memory.
3. **Nothing sends silently.** Every proposed edit is shown as `"original" → "proposed"` and waits for a ruling. Sending is one paragraph per message with a 1 to 2 second gap, except formatted or official text, which goes as one message.
4. **Backend is pluggable.** GitHub vault (default), local vault folder, Notion, NotebookLM, or none. A failed backend write never blocks a reply or a triage, it gets one line and the job continues.
5. **Both sides.** When platform memory tools exist, a durable fact the user states goes to the backend and to memory in the same turn. Moments and recalls stay in the backend only.
6. **Never act on an unnamed chat.** No sending, archiving or reminding on a chat the user did not name in the conversation.
7. **Versioning.** The 3-6-9 scheme, first release v3.6.9.0.

## What changed on the way here

- **v3.6.9.0** (11 Sep): first build, 8 skills.
- **v3.6.9.1** (15 Sep): the 7 sub-skills became mode files, one `/bee` command with the mode as the first argument.
- **v3.6.9.2** (15 Sep): sanitised for public release, layout key renamed, packaging and release workflow added.

## Sanitisation log (what was stripped for the public build)

| Was | Now |
|---|---|
| example config with a real name, timezone, GitHub owner and repo, local vault path | `Alex`, `UTC`, `your-github-username`, `your-vault-repo`, `~/Documents/vault` |
| layout key `chloe` / `layout_chloe` | `obsidian-ai` / `layout_obsidian_ai`, with a one-line backward-compatibility rule so existing configs keep working |
| vault root marker named after a private vault | a folder that matches `backend.local.folder` or contains `.obsidian/` |
| real contact names in every example (triage, recall, remind, notes) | `Sam`, `Jamie` |
| real client and brand names in examples, a real invoice label | `Acme Co`, `Quote Q-1042`, `the March invoice` |
| a private handoff file from the first build | deleted, replaced by `HANDOFF.md` |

Deliberately kept, because it is publisher identity rather than private data: the author block in the manifest, the homepage and repository URLs, and the MIT copyright line.

Never present in the first place: tokens, chat content, style text, contact lists. The Beeper token is an environment variable in `.mcp.json`, and settings live in the user's own memory, not in the plugin.

## Known gaps, worth a future version

1. No eval suite. Mode routing is prose rules, not tested behaviour.
2. NotebookLM backend is append-only and browser-driven, so it is slow and cannot update a note in place.
3. `report` reads moments notes by listing the write directory and filtering on filename, which will get slow on a large vault.
4. The reply register list (`friend-en`, `client`, `formal`, and so on) is a convention, not a schema. Two users could name the same register differently and nothing checks.
5. Beeper search is literal, not semantic, so recall depends on guessing the right single words. The mode tries 2 to 3 synonyms and says so when it finds nothing.
