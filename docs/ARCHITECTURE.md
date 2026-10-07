# Architecture

## Layers

```
scenes/, src/boot.gd, (future UI)      presentation, thin
src/game.gd                            autoload: owns Runtime, handles Android lifecycle
src/core/runtime.gd                    composition root, no engine nodes
src/core/*                             game logic, pure and testable
content/packs/*                        story data (JSON) + strings
```

Everything in `src/core/` is `RefCounted`. Tests construct a `Runtime` directly and drive the game without a scene tree.

## Core systems

| File | Responsibility |
| --- | --- |
| `content_db.gd` | Loads packs (manifest, entity JSON, locales) into an id-indexed database. Defensive: rejects bad packs, files, entities and unsafe paths, reports in `errors`. |
| `content_validator.gd` | Cross-checks the database: dangling refs, unknown condition ops, bad effects, dialogue targets, requires-cycles, missing translations. |
| `story_graph.gd` | Edge index over every entity's `refs`. Outgoing/incoming queries, cross-season links, reachability, clue availability. |
| `condition.gd` | Evaluates declarative JSON conditions against `GameState`. Fails closed on unknown or malformed input. |
| `effects.gd` | Applies declarative effects (add clue, set flag, deliver message, unlock season, ...). |
| `message_system.gd` | Anonymous messages: evidence-weighted sender inference, authenticity, reinterpretation history, forced reveals. |
| `dialogue_runner.gd` | Steps through data-defined dialogue graphs with gated choices. |
| `puzzle_system.gd` | Code, sequence and pairing puzzles; effects fire once. |
| `ending_resolver.gd` | Priority-ordered, condition-driven endings. |
| `game_state.gd` | Serializable player progress with strict validation on load. |
| `save_system.gd` | Slots, SHA-256 checksum, temp-file write, automatic backup, safe failure. |
| `localization.gd` | Key lookup, `{placeholder}` args, fallback language, coverage report. |

## Narrative graph

There are no per-season levels in code. Seasons are entities (`season.1` ... `season.4`) linked by `connects_to` and `reinterprets` edges, and every clue, message, file, location, choice and identity carries a `season` plus optional `refs` to anything else. Forward references to later seasons are allowed; the validator only requires that targets exist once all packs are loaded.

Clue availability combines: season unlocked, all `requires` targets already known, and an optional `unlock` condition.

## Anonymous messages and sender identity

Each message has a displayed header (`source`, `id`), a hidden `true_identity`, and `attribution` evidence entries `{clue, identity, weight}`. As the player finds clues, scores accumulate per identity. A sender is *identified* only when the leading identity reaches `identify_threshold` and leads the runner-up by `identify_margin`. New evidence can withdraw or change the inference, and `identity_history` keeps every step. A story beat can force the truth with the `reveal_sender` effect. Authenticity (`UNKNOWN`, `VERIFIED`, `SUSPECT`, `FORGED`) changes only after the message's `verify_with` clues are found.

## Downloadable content

A pack is a directory with `manifest.json`. `Game.boot()` loads the shipped core pack, then any pack under `user://packs/<name>/`. Packs declare `dependencies` (loaded earlier), a content `schema` version (newer than the build is refused), and may only reference files inside their own directory.

## Android lifecycle

`Game._notification` autosaves on `NOTIFICATION_APPLICATION_PAUSED`, focus-out and back/close requests. On launch `Game.boot()` restores the autosave, falling back to the backup, then to a new game. The save/restore logic is unit tested; the notification wiring itself must be verified on a device.

## Rendering target

GL Compatibility renderer for the widest mid-range Android support. Planned visual effects (CRT, glitch, distortion, lighting) will be canvas-item shaders kept optional behind quality settings.
