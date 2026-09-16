# Note formats — the two streams never mix

## Stream A · Moments (real life) — `kind: moments`
One note per day, created by bee on first log, appended after. Tag `bee-moments`. Optional `client:` and `reclassify: true`.
```
[[AI]]
---
tags: [ai, bee-moments]
reclassify: true
date: 2026-09-11
---
# 🐝 Moments — 2026-09-11

| Time | Client / context | What happened | Evidence |
|---|---|---|---|
| 14:32 | Acme Co | Quote Q-1042 sent and acknowledged | wa:// deeplink or file name |
| 16:05 | personal | Support shift ended, 11 calls handled | — |
```
Rules: one row per moment; time in config timezone; "What happened" is a completed fact in past tense; "Evidence" is a Beeper deeplink, file name, or `—`. Add `client: <name>` frontmatter when at least one row is client work (list several as YAML list).

## Stream B · Recall (pulled from Beeper) — `kind: recall`
One note per recall request. Tag `bee-recall`. Never mixed into a moments note.
```
[[AI]]
---
tags: [ai, bee-recall]
chat: Sam (Instagram)
range: 2026-09-01 → 2026-09-10
query: invoice
---
# 🐝 Recall — Sam · invoice

1. 2026-09-08 22:14 · Sam: asked whether the March invoice is due this week
2. 2026-09-08 22:40 · me: said it can wait till after the 15th
…
Summary: …
```

## Stream C · Style learned — `kind: style`
```
[[AI]]
---
tags: [ai, bee-style]
style: formal
stated: 2026-09-11
---
# ✍️ Register — formal
- <each rule exactly as the user stated it>
- Sample: "<a sample the user approved>"
```
Reconcile (or the user) promotes this into the permanent style file; until then bee reads it from here.

## Stream D · Setup — `kind: setup`
Written once by `/bee setup`: which backend, agent name, timezone. No secrets.
