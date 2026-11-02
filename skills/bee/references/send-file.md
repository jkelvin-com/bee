# Sending a file (PDF, image) through Beeper

The Beeper MCP `send_message` sends text only. To send a file, use the Beeper Desktop API on localhost:23373 with your Beeper Desktop API access token (never print it).

1. Upload: `curl -H "Authorization: Bearer $T" -F "file=@<path>;type=<mime>" -F "fileName=<name>" -F "mimeType=<mime>" http://localhost:23373/v1/assets/upload` returns `uploadID`.
2. Send: `POST http://localhost:23373/v1/chats/<url-encoded Matrix chatID, e.g. !abc:beeper.local>/messages` with JSON `{"text": "caption", "attachment": {"uploadID": "...", "fileName": "...", "mimeType": "..."}}`. Returns a pendingMessageID.
3. Verify with `list_messages` on the chat: the new FILE message shows the caption and the attachment name.

The Matrix chatID (`!...:beeper.local`) is the `chatID` field inside any message from `list_messages`; the short numeric ID from search does not work in the v1 URL.
