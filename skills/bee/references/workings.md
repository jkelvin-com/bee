# Workings · where routines leave their output (Drive)

`brain/Workings/` sits beside the vault, outside `Vault`. One folder per live routine. Any assistant (Cowork, voice, Grok) reads it to pick up the latest output and to leave amends or confirmed replies.

Config: `workings` block in `config/bee.config.example.json` (folder ids). Tools: Google Drive connector only (`search_files`, `read_file_content`, `create_file`, `update_file`).

## Naming law

1. A file named only by its timestamp has no prefix: `2026-10-02-0927.md`.
2. Every other file uses a plain name: `NOW.md`, `HOW.md`, `AMEND-2026-10-02-1012.md`, `SEND-2026-10-02-1015-sam.md`.
3. Timestamps are local time (config timezone), `YYYY-MM-DD-HHMM`.
4. The Drive connector cannot rewrite a file's content, only create a file and change its title or folder. So **the title is the status**: a run moves a file forward by renaming it, never by editing it. A file that is superseded (an old snapshot) is moved into its folder's `archive/`, so only the live file sits in view.
5. Create with `contentMimeType: text/markdown` and `disableConversionToGoogleType: true`. Never trash anything. Never touch the vault's `0-inbox` rules from here; Workings is not the vault.

## Folder `bee-triage/` (triage routine, every 3 hours)

**One live snapshot.** `NOW.md` is the only triage any assistant reads (Cowork, voice, Grok, Claude Code). It is a running board, not a one-off report: an item stays on it, with its latest draft, until the user has actually replied, and then it moves to the History section at the bottom. Old snapshots are moved out of sight into `archive/`, never left beside it and never trashed. Config: `workings.bee_triage_archive_folder_id`.

| File | Who creates it | Meaning |
|---|---|---|
| `NOW.md` | triage routine (or whoever republishes after an amend) | the one live snapshot |
| `archive/YYYY-MM-DD-HHMM.md` | the same writer, by renaming and moving the previous `NOW.md` | superseded snapshot, audit only, nobody reads it for current state |
| `AMEND-YYYY-MM-DD-HHMM.md` | an assistant on a call, or Cowork | a change the user asked for, pending |
| `AMEND-YYYY-MM-DD-HHMM-applied.md` | whoever folded it into `NOW.md` (rename) | amend applied |

### Reading rule (every AI, every time)
Read `NOW.md`, then every `AMEND-*.md` not ending `-applied.md`, oldest first, and overlay them. A pending amend always beats the snapshot. Never read `archive/` for current drafts.

### Carry-forward (how a run builds the new snapshot)
1. **Start from the previous `NOW.md`** with pending amends overlaid. Every NEEDS REPLY item in it is an open item; its draft is the latest one (the user's edit if they amended it).
2. **Check each open item** with `list_messages` on its `chat`:
   - a `SENT-` file matches (same `chat`, same `reply_to`) → **resolved**, History `sent by bee` (dispatch already recorded the decision).
   - no `SENT-` match, but the user has sent a message in that chat after the item's `reply_to` → **they replied themselves**: History `replied by you`, and record it in `decisions/` as a `DECISION-` file with `source: by-hand` (format below). Final = the user's own messages after `reply_to`, up to the next message from them. Bee's draft = the item's latest draft (the user's edit if any). This is the strongest training signal: what the user wrote when they did not use the draft.
   - a `HELD-` file matches → keep it open, add the hold reason.
   - an amend said skip → History as `skipped by you`.
   - still unanswered and nothing new from them → **keep it exactly as it was**: same Original, same draft, same `edited:` mark. Read or unread in Beeper does not matter; only their reply closes an item.
   - still unanswered and they wrote again → keep their edited draft if there is one, add the new messages to Original, and add `- New since your edit: "<new text>"` with a fresh draft below it marked `(redraft)`. Never silently replace a draft the user edited.
3. **Add new items** from this run's unread scan (chats not already open), as usual.
4. **History** keeps resolved items for 7 days, newest first, one line each: `✅ 2 Oct 10:16 · Ivan Chai · sent by bee: "<first line of the final>"`. Older lines drop off the snapshot; they stay in `archive/` and in `decisions/`.
5. FYI is rebuilt fresh every run (it is not carried).

### Triage routine write sequence
1. List `bee-triage/`. Read `NOW.md` and every `AMEND-*.md` not ending `-applied.md`, oldest first. A rule meant to be permanent is also written as a vault `0-inbox` note.
2. Run triage (`modes/triage.md`) and carry forward as above.
3. **Create the new snapshot first**, titled `NOW-new.md`. Only after it exists: rename the old `NOW.md` to `<its run>.md` and move it into `archive/` (`update_file` with title and `parentId` in one call), then rename `NOW-new.md` to `NOW.md`. If any step fails, leave both and say so in one line; readers take the newest `NOW…` by created time.
4. Rename each amend folded in to `…-applied.md`.
5. Close the message to the user with one line: `📄 Saved: brain/Workings/bee-triage/NOW.md · confirmed replies go in Workings/bee-send/`.

### Republish after a change (every assistant, voice included)
When the user changes a draft, skips someone or adds a rule on a call or in chat, `NOW.md` must become the most current version at once, not at the next run. The voice assistant follows this exactly like Cowork:
1. Build the new snapshot from `NOW.md` with the change applied (that item's Draft replaced, marked `edited: <time> (voice|cowork|grok)`; a skip moves it to History as `skipped by you`).
2. Run write-sequence step 3 (create `NOW-new.md`, archive the old one, rename the new one to `NOW.md`). No Beeper scan; `run:` stays, add `republished: <time>`.
3. Also write the `AMEND-` file and rename it `…-applied.md` straight away: it is the audit record of what they said.
4. Only if the tool cannot rename or move Drive files: write the `AMEND-` file alone (pending). The reading rule makes every reader overlay it until someone who can republishes. Never skip the amend file.

### `NOW.md` format
```
---
run: 2026-10-02-0927
created: 2026-10-02T09:27:00+00:00
republished: <blank, or the time of the last amend republish>
counts: "🔴 2 · 💬 4 · 🟡 1 · ⚪ 9"
---
# 🐝 Bee triage · NOW · Fri 2 Oct 09:27

## 📥 NEEDS REPLY
1. 🔴 URGENT Name (Network) · 3 unread · 08:12 · open since 1 Oct
   - chat: <Beeper chatID>
   - reply_to: <last unread messageID>
   - category: <name>
   - Original: "…"
   - Draft: "…"
   - edited: <blank, or when they changed this draft>
…

## 🟡 WAITING ON THEM
…

## ⚪ FYI
…

## 🗃️ HISTORY (last 7 days)
- ✅ 2 Oct 10:16 · Name · sent by bee: "…"
- ✅ 2 Oct 08:40 · Name · replied by you
- ⏭️ 1 Oct 22:00 · Name · skipped by you
```
Every NEEDS REPLY item carries `chat:` and `reply_to:` so a confirmed reply can be queued without searching again; `chat:` is the item's identity across runs (item numbers change every run). `open since` is the date the item first appeared.

## Folder `bee-send/` (hourly send routine)

| File | Meaning |
|---|---|
| `HOW.md` | the queue format, for any assistant writing to it |
| `SEND-YYYY-MM-DD-HHMM-<slug>.md` | a reply the user confirmed, waiting to go |
| `SENDING-…` | claimed by a run (lock, prevents double sends) |
| `SENT-…` | sent, with the result in the run log |
| `HELD-…-<reason>.md` | not sent; shows up in the next triage |
| `YYYY-MM-DD-HHMM.md` | the send run's log, only created when something was sent or held |

### `SEND-…` format
```
---
chat: <Beeper chatID, copied from NOW.md>
to: Name (Network)
reply_to: <messageID or blank>
from_run: 2026-10-02-0927 item 3
confirmed: 2026-10-02T10:15:00+00:00
format: paragraphs        # or one-block for official or formatted text
category: <optional, the reply category if known, e.g. friend-zh>
---
First paragraph, sent as message 1.

Second paragraph, sent as message 2.
```
The body is the exact final text the user confirmed, with no `[brackets]` left.

## Folder `bee-triage/decisions/` (the decisions ledger)

Every reply that dispatch actually sends leaves one copy here. Two jobs: an audit trail of what the user decided, and the training set the Claude Code reconcile uses to learn how the user replies to each person and each category. Config: `workings.bee_decisions_folder_id`.

| File | Who creates or renames it | Meaning |
|---|---|---|
| `DECISION-YYYY-MM-DD-HHMM-<slug>.md` | dispatch, right after a send; or triage, when it finds they replied by hand | new, not learned yet |
| `DECISION-…-learned.md` | Claude Code reconcile (rename) | folded into `me-reply-patterns` |
| `DECISION-…-needs-category.md` | Claude Code reconcile (rename) | a new category was detected, waiting for the user to name it |

The stamp is the send time (local time (config timezone)). `<slug>` is the same slug as the `SEND-` file. Never edited after creation; status moves by renaming only. Never trashed: this is the audit record.

### `DECISION-…` format
```
---
kind: bee-decision
source: bee-send | by-hand
sent: 2026-10-02T10:16:00+00:00
chat: <Beeper chatID>
to: Name (Network)
reply_to: <messageID or blank>
from_run: 2026-10-02-0927 item 3
send_file: <SENT- title, blank for by-hand>
confirmed: <time they approved, blank for by-hand>
language: en | zh | ms | mixed
category: <from the SEND file, else Bee's best guess, else unknown>
category_source: send-file | guess | unknown
verdict: as-drafted | edited | rewritten | own-words
partial: false
---
## Context (the thread before the incoming)
- 2026-10-01 21:40 · them: "<text>"
- 2026-10-01 21:42 · me: "<text>"
- … up to 10 lines, oldest first, ending just before the incoming

## Incoming
"<the message(s) they were answering, verbatim, from the run item's Original>"

## Bee's draft
"<the Draft from the run item, verbatim, or `none` when there was no draft>"

## Final, as sent
<the exact text sent, one paragraph per message, as in the SEND body>

## What changed
1. "<draft wording>" → "<final wording>"
2. kept as is: "<wording>"
```
`verdict`: `as-drafted` when the final equals the draft apart from filled `[brackets]`; `edited` when wording changed but the draft's shape stayed; `rewritten` when little of the draft survived; `own-words` when there was no draft. `Context` holds the last 10 messages before the incoming (both sides, oldest first, local time (config timezone)), so the reconcile sees the mood, the running topic and how the user usually talks to this person; `me` lines are the user's own real messages and count as voice samples. Voice notes, images and stickers appear as `[voice note]`, `[image]`, `[sticker]`; OTPs, codes and account numbers as `[code]`. In a group chat keep only lines from the sender the user answered and from the user. `What changed` lists every difference (a filled bracket counts), the same way `modes/reply.md` step 4 shows changes; for `own-words` it says `no draft`.
