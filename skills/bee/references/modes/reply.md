# 🐝 bee · reply



## 1. Target & context
- Find the chat (`sending.md` step 1). Pull the last 10–20 messages with `list_messages` so the reply fits the thread. Note the network (WhatsApp / Instagram / Telegram …).

## 2. Pick the register
Decide from the recipient and the thread, then confirm silently unless unsure:
- `friend-en` — tech-savvy English-speaking friend (default for 1:1 chats with known friends)
- `client` — customers, vendors, officials (ghostwriting voice)
- `formal` — official notices, complaints, legal-ish
- `family`, `friend-zh`, `friend-ms`, `aggressive`, … — any other register the user has taught bee
Call `read_style(register)` via the backend adapter. It also returns the learned person and category patterns from `me-reply-patterns`; apply them.
- **Known** → use it exactly. Preserve the user's specific spellings and phrasings the style file lists.
- **`unknown`** → STOP and ask one question: "I don't have a `<register>` style yet — describe it in a few lines, or paste a sample you've sent before." When the user answers:
  1. Write it as a `style` note (stream C) with `style: <register>` and the rules exactly as stated.
  2. Mirror the rules to Anthropic memory (`/topics/writing-style.md`, tagged `[stated]`) if memory tools exist.
  3. Continue with the new register.
- **Obviously different from the default** (客户 writing in 中文, Malay thread, a stranger) and no matching register → ask; do not silently fall back.

## 3. Two modes
- **Draft mode** — the user gave a brief. Draft from the brief and thread only; never invent facts, dates or prices. Keep it as short as the register allows.
- **Fix mode** — the user pasted their own text. Fix only obvious slips. Never rewrite tone, never re-order, never add closers.

## 4. Show every change — always, before any send
Number each proposed change as `"original" → "proposed"` and include deliberate keeps (`kept as is: "share to you"`). Then STOP. Apply exactly what the user rules, one by one. Silent fixes are forbidden. "Pause" = nothing happens.

## 5. Send
Per `sending.md`: show the final split, wait for go, one paragraph per `send_message` with 1–2 s gaps, formatted/official text as one message. Report one line with the deeplink.

## 6. After sending
- If the reply completes something for a client (quote sent, deliverable delivered, confirmation given) → suggest in one line: "log this as a moment? (y/n)". If yes → run **log** mode with the deeplink as evidence.
- Do not write a `recall` note for ordinary replies.
