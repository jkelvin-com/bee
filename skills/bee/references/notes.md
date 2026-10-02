# Note formats — the two streams never mix

Oaa2B layout (Drive vault): every note is a NEW file in `0-inbox`, titled `<slug>-<agent>-<surface>-YYYY-MM-DD-HHMM.md`. Line 1 is frontmatter with `agent`, `surface`, `created`, `kind`, `op_id`, `summary` plus the tags below; the first body line is `↑ [[INBOX]]`. Notes cannot be edited after creation, so "one note per day" becomes one small note per moment with `kind: append` and `target: bee-moments-<date>`. The blocks below show the BODY plus the extra frontmatter keys only.

## Stream A · Moments (real life) — `kind: moments`
One note per moment, `kind: append`, `target: bee-moments-<YYYY-MM-DD>`, slug `bee-moments`. Tag `bee-moments`. Optional `client:` and `reclassify: true`.
```
---
kind: append
target: bee-moments-2026-09-11
tags: [bee-moments]
reclassify: true
date: 2026-09-11
---
↑ [[INBOX]]

# 🐝 Moments — 2026-09-11

| Time (KL) | Client / context | What happened | Evidence |
|---|---|---|---|
| 14:32 | Acme Co | Quotation Q-0912 sent and acknowledged | wa:// deeplink or file name |
| 16:05 | personal | Support shift ended, 11 calls handled | — |
```
Rules: one row per moment (a table with the header and one row per note; the reconcile merges rows into the day); time in config timezone; "What happened" is a completed fact in past tense; "Evidence" is a Beeper deeplink, file name, or `—`. Add `client: <name>` frontmatter when at least one row is client work (list several as YAML list).

## Stream B · Recall (pulled from Beeper) — `kind: recall`
One note per recall request. Tag `bee-recall`. Never mixed into a moments note.
```
---
kind: note
tags: [bee-recall]
chat: Sam (Instagram)
range: 2026-09-01 → 2026-09-10
query: invoice
---
↑ [[INBOX]]

# 🐝 Recall — Sam · invoice

1. 2026-09-08 22:14 · Sam: asked whether the March invoice is due this week
2. 2026-09-08 22:40 · me: said it can wait till after 15 Sep
…
Summary: …
```

## Stream C · Style learned — `kind: style`
```
---
kind: note
tags: [bee-style]
style: formal
stated: 2026-09-11
---
↑ [[INBOX]]

# ✍️ Register — formal
- <each rule exactly as the user stated it>
- Sample: "<a sample the user approved>"
```
Reconcile (or the user) promotes this into the permanent style file; until then bee reads it from here.

## Stream D · Setup — `kind: setup`
Written once by `/bee setup`: which backend, agent name, timezone. No secrets.
