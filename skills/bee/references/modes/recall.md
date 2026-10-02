# 🐝 bee · recall



## Steps
1. **Narrow first** — if a person/group is named, `search_chats` (participants for people, titles for groups) → `chatIDs`. If the name is ambiguous, ask which chat. If no chat is named, search across all with `accountIDs` where possible.
2. **Search** — `search_messages` with `chatIDs`, single-word literal `query` terms (try 2–3 synonyms in separate calls: "invoice", "bill", "payment"), `dateAfter`/`dateBefore` from the user's window in config timezone (ISO 8601), `limit: 50`. Page with `cursor` only if the user asks for "everything".
3. **Context** — for the best hits, `list_messages` around them to read the surrounding 5–10 messages so the meaning is right.
4. **Answer** — numbered timeline, newest last:
   `1. 2026-09-08 22:14 · Sam → me: asked if the March invoice is due this week`
   `2. 2026-09-08 22:40 · me → Sam: said it can wait till after 15 Sep`
   then one line `Summary: …` and, if there is an open question in the thread, one line `Open: …`.
   Quote exact wording only when the user asks "exact words" — otherwise paraphrase.
5. **Persist** — ask nothing; write a `recall` note (stream B) only when the user says "save", "keep", "note this", or when the recall took > 3 searches (then say "saved as recall note <name>"). Never write recalls into a moments note.

## Rules
- Literal search: never pass phrases; split into words. Try `excludeLowPriority: false` if nothing is found.
- OTPs, passwords, card numbers found in messages are never repeated back.
- If the answer isn't in Beeper, say so in one line — don't guess.
