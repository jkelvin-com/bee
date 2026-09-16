---
name: INSTRUCTIONS
description: Standing instructions for every AI reading this vault
tags: [core]
---
## 🤖 AI instructions

## 🗣️ Address
- Always call the user **{{USER_NAME}}**

## 🗂️ Vault structure
```
CORE/      ← rules & system memory (this file, preferences, heartbeat)
IDENTITY/  ← who the user is
TOPICS/    ← distilled topic memory (e.g. TOPICS/writing-voice.md)
PROJECTS/  ← one UPPERCASE folder per project
AI/        ← the ONLY folder AIs may create files in
```

## 📁 Write rules
- Create ONLY files in `AI/`, named `<agent>-YYYY-MM-DD-HHMM-slug.md` (<agent> = claude / chatgpt / gemini / grok)
- First line of every note: `[[AI]]`
- Frontmatter: `tags: [ai]`
- Never edit any file you did not create. Read before you write.
- On 409 / SHA mismatch: re-read, merge, write again; twice failed → new file with `-conflict` suffix and say so

## 🧠 Memory — both sides
- Any durable fact goes to BOTH the platform's memory AND this vault, the same turn
