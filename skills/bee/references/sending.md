# Sending rules — every message bee sends on the user's behalf

1. **Find the chat**: `search_chats` with `scope: "participants"` for a person, `"titles"` for a group. If more than one plausible chat, show the candidates (network + title + last activity) and ask which. Never guess between two people with similar names.
2. **Show before send**: display the exact final text, split into the messages it will become, and wait for an explicit go ("send", "ok", "go"). "Pause" = send nothing.
3. **Cadence** (from config `send`): default one paragraph = one `send_message`, `sleep` a random 1–2 s between (`sleep $((1 + RANDOM % 2))` in Bash). Exception: properly formatted or official text (a letter, a numbered notice, a quotation) goes as ONE message.
4. **Reply threading**: if the user is answering a specific message, pass `replyToMessageID` on the first chunk only.
5. **Report back** in one line: `Sent 3 messages to <name> (WhatsApp) · <deeplink>`.
6. **Never** send to a chat the user did not name in this conversation. **Never** send while the user is mid-edit.
