# 🐝 bee · triage



## Steps
1. **Scope** — default: `search_chats` with `unreadOnly: true`, `inbox: "primary"`, `includeMuted: false`, `limit: 50`. If the user gives a window ("since yesterday", "last 3 hours") add `lastActivityAfter` in config timezone converted to ISO. If they name a network, filter with `accountIDs` from `get_accounts`.
2. **Peek** — for each unread chat (max 20; say if more), `list_messages` and read only the unread tail (stop at the last message sent by `me`). Do not read whole histories.
3. **Classify** each chat:
   - 🔴 **needs reply** — a direct question, request, or a message addressed to the user that has waited > 2 h.
   - 🟡 **waiting on them** — the user's last message is unanswered; nothing to do.
   - ⚪ **FYI** — group chatter, broadcasts, receipts, OTPs.
   Mark 🔴 as **URGENT** when it contains time words (today, now, ASAP, deadline, by <time>), money, a client name found in the backend's identity/context notes, or a missed call.
4. **Digest** — numbered lines, most urgent first, one line each:
   `1. 🔴 Sam (Instagram) · 3 unread · asks if the March invoice is due this week · 22:14`
   Then one line of counts: `🔴 2 · 🟡 4 · ⚪ 9`.
5. **Offer** — end with the actions available as short options, not questions: "reply 1 · remind 3 · log · archive 5". Do nothing until the user picks.
6. **Persistence** — none by default. If the user says "keep this", write the digest as a `recall` note (stream B, slug `bee-recall-triage-<date>`).

## Rules
- Never mark anything read, archive, or reply during triage.
- Never quote OTPs or verification codes in the digest.
- If Beeper returns > 200 unread chats, triage `primary` only and say so.
