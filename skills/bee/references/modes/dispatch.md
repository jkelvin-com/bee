# 🐝 bee · dispatch (send confirmed replies)

Sends replies the user already confirmed, from `Workings/bee-send/`. Built for the hourly send routine; also runs on demand (`/bee dispatch`). Read `references/workings.md` first.

A `SEND-…` file IS the user's go. It was written only after the user approved that exact text on a call or in chat, so `sending.md` step 2 (show before send) and shared rule 9 are already satisfied for that one chat and that one text. Nothing else may be sent.

## Steps
1. **Queue**, `search_files` with `parentId` = `workings.bee_send_folder_id`. Keep titles starting `SEND-`. None → stop silently (no message, no log file).
2. **Per file, oldest first:**
   1. **Claim**, rename `SEND-X` to `SENDING-X`. If the rename fails or the file is already gone, skip it (another run has it).
   2. **Read** it. Parse frontmatter and body.
   3. **Hold checks**, rename to `HELD-X-<reason>.md` and move on when:
      - `chat` is missing or `get_chat` cannot find it → `nochat`
      - the body still contains `[` … `]` → `gap`
      - `confirmed` is more than 24 h ago → `stale`
      - the body is empty → `empty`
      - a `SENT-` file in `bee-send/` already has the same `chat` and `reply_to` (and `reply_to` is not blank) → `dup`
   4. **Send**, per `sending.md` cadence: `format: paragraphs` → one `send_message` per paragraph, `sleep` 1 to 2 s between; `one-block` → one message. `replyToMessageID` = `reply_to` on the first chunk only. Text verbatim, never re-edited.
   5. **Mark**, rename `SENDING-X` to `SENT-X`. A send error part-way → rename to `HELD-X-partial.md` and record which chunks went.
   6. **Record the decision**, for every file that sent at least one message (`SENT-` or `HELD-…-partial`): create `DECISION-<send stamp>-<slug>.md` (`source: bee-send`) in `workings.bee_decisions_folder_id` (format in `workings.md`, `contentMimeType: text/markdown`, `disableConversionToGoogleType: true`).
      - **Incoming and draft**: the draft lives on the triage board. Read the live `NOW.md` and find the item with the same `chat:` (match by chat, never by item number, which changes every run). Not there any more → look in `workings.bee_triage_archive_folder_id`, newest first, for the snapshot that still has that `chat:` with `run:` = `from_run`'s run. Copy that item's `Original` and `Draft` verbatim (the user's edited draft, if they changed it). Run file or item not found → `Incoming: not found`, `Bee's draft: none`, `verdict: own-words`.
      - **Context**: `list_messages` on the chat (already open for the send) and take the 10 messages just before the incoming (`reply_to`, else the first unread message of the run item), both sides, oldest first, per the `Context` rules in `workings.md`. Read only. Beeper fails here → `Context: not captured`, never block the record.
      - **Final**: the `SEND` body exactly as sent (for a partial send, only the chunks that went, and `partial: true`).
      - **Verdict and changes**: compare draft with final as `workings.md` describes. Never judge or comment on the user's choice; just record it.
      - **Category**: `category:` from the `SEND` file when present (`category_source: send-file`); else the register triage drafted in (`guess`); else `unknown`.
      - A failed create never undoes or blocks a send. Retry once (search the title first, Drive allows duplicates); still failing → add `decision not recorded` to that line of the run log.
3. **Log**, if anything was sent or held, create `YYYY-MM-DD-HHMM.md` in `bee-send/`: one numbered line per file, `Sent 2 messages to Sam (WhatsApp) · deeplink` or `Held: Jamie, gap`.
4. **Tell the user**, one short numbered message with the same lines. Nothing sent and nothing held → no message.

## Rules
- Never send anything that is not in a `SEND-` file. Never change the text.
- Every sent reply gets exactly one `DECISION-` file. Never edit, rename or trash one after creating it; renaming belongs to the Claude Code reconcile.
- Never retry a `SENT-` or `HELD-` file. Held items appear in the next triage under 🔴 with the reason.
- Never mark read, archive or set reminders.
- Beeper or the computer unreachable → leave files as they are (rename any `SENDING-` back to `SEND-`), say so in one line, stop.
