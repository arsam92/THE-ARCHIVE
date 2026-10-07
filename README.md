# THE ARCHIVE

2D narrative mystery / investigation / ARG game. Android first. Built with **Godot 4.3** (GDScript, GL Compatibility renderer).

> Status: **foundation milestone.** The data-driven story engine and its tests exist. Art, UI, audio and story content are not built yet. See [`docs/ROADMAP.md`](docs/ROADMAP.md) for exactly what is and is not done.

## Principles

- **Story is data.** Dialogue, clues, messages, puzzles, endings and season links are JSON in `content/packs/`. Gameplay code never hardcodes story.
- **One narrative graph, not four levels.** Any entity can reference any other, across seasons, including forward references.
- **Anonymous by default.** Messages show `SOURCE / ID / AUTHENTICITY` and only resolve a sender when evidence supports it.
- **Fail safe.** Broken or hostile content and saves are rejected with an error, never a crash.
- **No invented canon.** Narrative content comes from the approved narrative specification only.

## Quick start

Requires [Godot 4.3](https://godotengine.org/download/archive/4.3-stable/).

```bash
godot --headless --path . --import                       # first time only
godot --headless --path . -s tests/run_tests.gd          # run all tests
godot --headless --path . -s tools/validate_content.gd   # validate shipped content
```

Both commands exit non-zero on failure. Filter tests: `-s tests/run_tests.gd -- test_save_system`.

## Layout

| Path | Purpose |
| --- | --- |
| `src/core/` | Engine-free game logic (graph, messages, dialogue, puzzles, endings, save, i18n) |
| `src/game.gd` | Autoload bridging Android lifecycle events to core |
| `content/packs/core/` | Shipped content pack (season graph, sender identity roster) |
| `tests/` | Unit tests and fixtures (`[FIXTURE]` text is placeholder, not canon) |
| `tools/` | Command-line tooling |
| `docs/` | Architecture, content schema, roadmap, Android release notes |

## Docs

- [Architecture](docs/ARCHITECTURE.md)
- [Content schema](docs/CONTENT_SCHEMA.md)
- [Roadmap and status](docs/ROADMAP.md)
- [Android build and release](docs/ANDROID_RELEASE.md)
- [Working on this repo (humans and AI agents)](AGENTS.md)
