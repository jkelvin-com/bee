# 🐝 bee · remind



## Set a reminder
1. Find the chat (participants / titles). Ambiguous → ask.
2. Parse the time in config timezone → Unix ms. Relative phrases: "tomorrow 9am", "in 2 hours", "Monday". If the user names a date without a time, use 09:00.
3. `set_chat_reminder` with `remindAtMs`; set `dismissOnIncomingMessage: true` when the user says "unless they reply", otherwise false.
4. Confirm in one line: `⏰ Sam (Instagram) · Fri 12 Sep 09:00 · clears if they reply`.

## Clear / snooze
- "clear" → `clear_chat_reminder`. "snooze 1h" → clear, then set again at +1 h.

## Who am I waiting on
1. `search_chats` `inbox: "primary"`, `lastActivityAfter` = now − 14 days (or the user's window), `limit: 100`.
2. For each chat, `list_messages` and check whether the last message was sent by `me` and contains a question/ask (a `?`, "can you", "please", "let me know", "confirm"). Those are open follow-ups.
3. Numbered list, oldest first: `1. Jamie (WhatsApp) · 4 days · you asked about the arrears schedule` and offer "remind 1 tomorrow · nudge 2".
4. "nudge N" → hand to **reply** mode with the brief "gentle follow-up on <topic>".

## What did I promise
- Same scan, but look for `me` messages with "I will", "I'll", "will send", "later", "tomorrow" in the last window. List them; offer to log each as a moment when done.

## Rules
- Reminders live in Beeper only — never in the calendar, never in the notes backend (the user's calendar is their own).
- Never set a reminder on a chat the user didn't name or pick from a list bee just showed.
