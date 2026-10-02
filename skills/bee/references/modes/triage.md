# 🐝 bee · triage

## Steps
1. **Scope: every unread chat, nothing filtered out.** Run `search_chats` with `unreadOnly: true`, `includeMuted: true`, `limit: 200` twice: once with `inbox: "primary"`, once with `inbox: "low-priority"`. Page through with `cursor` until no more results. Muted and low-priority chats are in scope too. If the user gives a window ("since yesterday", "last 3 hours") add `lastActivityAfter` in config timezone converted to ISO. If they name a network, filter with `accountIDs` from `get_accounts`. Also list `Workings/bee-send/` for `HELD-` files (routine runs) and add each as a 🔴 item with its reason.
2. **Peek** — for EVERY unread chat (no cap), `list_messages` and read the unread tail (stop at the last message sent by `me`; at most the last 30 messages of a busy group). Do not read whole histories. Tag each chat `muted` / `low-priority` when it came from there.
3. **Classify** each chat:
   - 🔴 **needs reply** — a direct question, request, or a message addressed to the user that has waited > 2 h.
   - 💬 **casual, keep connected** — a real person chatting (friend, family, talent, contact) with nothing urgent. These people matter, so they get a reply too.
   - 🟡 **waiting on them** — the user's last message is unanswered; nothing to do.
   - ⚪ **FYI** — group chatter, broadcasts, promos, bots, receipts, OTPs. Only these get no draft.
   Muted and low-priority chats are classified on the same rules; they usually land in ⚪, but a direct question or @mention to the user still makes them 🔴 or 💬.
   Mark 🔴 as **URGENT** when it contains time words (today, now, ASAP, deadline, by <time>), money, a client name found in the backend's identity/context notes, or a missed call.
4. **Digest** — two sections, section titles are one emoji plus bold ALL CAPS, numbers run on across the whole reply.
   **📥 NEEDS REPLY** holds every 🔴 (URGENT first) then every 💬. **⚪ FYI** holds the rest, one line each, no draft.
   Every item under NEEDS REPLY has exactly this shape, and is never shortened, casual chats included:
   ```
   1. 🔴 URGENT Name (Network) · 3 unread · time
      - Original: "<the unread message(s), verbatim, in the sender's language; last 1 to 3 messages max>"
      - Draft: "<reply proposal as the user>"
   ```
   Tag the header with `· muted` or `· low-priority` when relevant. In routine runs, every NEEDS REPLY item also carries `chat:` and `reply_to:` lines (see `references/workings.md`).
   Then one counts line: `🔴 2 · 💬 4 · 🟡 1 · ⚪ 9`.
5. **Drafting rules** (the user's own voice, never generic)
   - Pick the register per chat as in `modes/reply.md` step 2 and call `read_style(register)`. If `me-reply-patterns` has a section for this person, follow it first (how they open, length, language, what they usually decide for this kind of message), then the category section. In routine runs, add `category: <name>` to each NEEDS REPLY item so a queued reply can carry it into `SEND`. Chinese-speaking friends get Mandarin in the friend-zh voice. Unknown register: still draft in the closest known register, mark it `(register guess: <x>)`, and never save a new style without the user's answer.
   - Fit the thread: answer what the sender actually said, keep the length and mood of the thread, reuse the user's usual particles and openers as the style file lists them.
   - Never invent facts, dates, prices or payment status. Where the reply needs something only the user knows, put the gap in square brackets, e.g. `[confirm: payment received?]`.
   - Split the draft into paragraphs, one per future message. Official or formatted text stays one block.
   - Casual chats: warm, short, personal, ends the way the user would, so the relationship stays alive. Not a brush-off.
   - Voice notes, stickers and images cannot be read: say so in Original (`voice note, not transcribed`) and draft an acknowledgement that does not pretend to have heard it.
   - Sales inquiries: draft a fast acknowledgement that captures the key details and contact info, and flag that the full follow-up comes after.
   - Never use an em dash. Numerals for numbers and times. Preserve the user's spellings verbatim.
6. **Offer** — end with the actions available as short options, not questions: "send 1 · edit 3 · queue 4 · skip 5 · remind 2 · log · archive 7". `send N` and `edit N` hand off to **reply** mode with the draft already loaded, so the show-every-change and show-before-send rules in `modes/reply.md` and `sending.md` still apply in full. `queue N` writes the draft as a `SEND-` file in `Workings/bee-send/` for the next send run (only after the user confirmed the exact text). Do nothing until the user picks.
7. **Persistence** — interactive runs: none by default; if the user says "keep this", write the digest as a `recall` note (stream B, slug `bee-recall-triage-<date>`).
8. **Routine runs** (`/bee triage routine`, or any scheduled or unattended run): follow `references/workings.md`: read `NOW.md` with pending `AMEND-` files overlaid, carry every open item forward (the user's edited drafts kept, resolved items moved to History), add this run's new items, record a `by-hand` decision for every open item the user answered themselves, publish the single new `NOW.md` (the old one goes to `archive/`), then deliver the digest with SendUserMessage, ending with the `📄 Saved:` line. Skip step 6's options in the file; keep them in the message. In the message, mark carried items `(open since <date>)` and any item the user edited `(your edit)`.

## Rules
- Drafts are proposals only. Never send, mark read, archive or set a reminder during triage.
- Never quote OTPs or verification codes in the digest.
- More than 200 unread chats: keep paging, never drop any; FYI items collapse to one line per network (`⚪ 37 WhatsApp groups, 12 promos`).
