# Config — where bee keeps its settings

bee stores its settings in **Anthropic memory** at `/areas/bee-config.md` when the `memory_*` tools are present (persists across sessions and devices for this user). Mirror to `~/.bee/config.json` on the user's computer via `device_bash` when a computer is linked, so tools outside Claude can read it too.

## Loading (every skill, first step)
1. `memory_read("/areas/bee-config.md")`. Parse the fenced ```json block.
2. If missing → try `device_bash 'cat ~/.bee/config.json'`.
3. If both missing → say "bee isn't set up yet — running `/bee setup` first", read `references/modes/setup.md` and follow it, then continue.

## Schema
See `config/bee.config.example.json` in the plugin root. Keys:
- `user_name` — how bee addresses the user.
- `agent_name` — prefix used in note filenames (`claude`, `chatgpt`, `gemini`, `grok`).
- `timezone` — IANA zone for all timestamps.
- `send.paragraph_per_message` / `send.gap_seconds` — sending cadence (see `sending.md`).
- `backend.type` — `github-vault` | `local-vault` | `notion` | `notebooklm` | `none`.
- `backend.<type>` — that adapter's settings.
- `layout_obsidian_ai` — the default note layout; other layouts can be added under `layout_<name>` and referenced by `backend.<type>.layout`.

Backward compatibility: a config written before v3.6.9.2 may say `"layout": "chloe"` with a `layout_chloe` block — treat that as `obsidian-ai` and keep working, no migration needed.

## Saving
`memory_write` the whole file (frontmatter: `name: bee-config`, `description: bee plugin settings — backend, agent name, timezone, send cadence`, `sources: [cowork]`) with the JSON in a fenced block, one `[stated]` line per setting the user chose. Then `device_bash 'mkdir -p ~/.bee && cat > ~/.bee/config.json <<EOF … EOF'` if a computer is linked.
