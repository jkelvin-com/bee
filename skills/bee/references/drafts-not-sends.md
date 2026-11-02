# Drafts, then approval, then send

When the assistant writes a message for the user to anyone, show the exact text in chat first. Send it with Beeper MCP `send_message` only after the user approves it. Do not use `focus_app` drafts: they pop Beeper open on the desktop and the draft does not reach the user's phone. If a `focus_app` draft was left by mistake, clear it with `draftText: ""` after sending.
