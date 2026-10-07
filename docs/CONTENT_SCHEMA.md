# Content schema (version 1)

## Pack layout

```
content/packs/<pack_id>/
  manifest.json
  <entities>.json        arrays of entities, listed in manifest.files
  locales/<lang>.json    flat {"key": "text"} maps, listed in manifest.locales
```

`manifest.json`:

```json
{
  "pack_id": "core",
  "version": "0.1.0",
  "schema": 1,
  "dependencies": [],
  "files": ["seasons.json"],
  "locales": { "en": "locales/en.json" }
}
```

Paths must be relative and stay inside the pack (`..`, absolute paths and `:` are rejected). Files over 4 MB are rejected.

## Entities

Every entity has `id` (`type.slug`, lowercase/digits/underscore, prefix must equal `type`) and `type`. Optional on all: `refs`, `unlock`.

| type | required fields | notes |
| --- | --- | --- |
| `season` | `order`, `name_key` | linked with `connects_to` / `reinterprets` refs |
| `location` | `season`, `name_key` | |
| `identity` | `name_key` | a possible sender or speaker |
| `clue` | `season`, `title_key` | `unlock` condition optional |
| `message` | `season`, `body_key`, `sender` | see below |
| `file` | `season`, `title_key` | |
| `choice` | `season`, `options[{id, text_key}]` | |
| `dialogue` | `season`, `start`, `nodes` | see below |
| `puzzle` | `season`, `kind`, `solution` | `kind`: `code`, `sequence`, `pairing`; optional `effects` |
| `ending` | `conditions`, `priority`, `title_key` | highest priority match wins |

Any field ending in `_key` must exist in the loaded locale strings (the validator checks this recursively).

## refs

```json
"refs": [ { "rel": "requires", "to": "clue.other" } ]
```

Allowed relations: `requires`, `reveals`, `references`, `foreshadows`, `echoes`, `contradicts`, `identifies`, `located_in`, `appears_in`, `authored_by`, `reinterprets`, `connects_to`. Targets may be in any season, including later ones. A `requires` cycle is a validation error.

## Message

```json
{
  "id": "message.example", "type": "message", "season": "season.1", "body_key": "...",
  "sender": {
    "displayed": { "source": "UNKNOWN", "id": "17-A" },
    "true_identity": "identity.observer",
    "authenticity": { "displayed": "UNKNOWN", "true": "SUSPECT", "verify_with": ["clue.x"] }
  },
  "attribution": [ { "clue": "clue.y", "identity": "identity.nora", "weight": 0.6 } ]
}
```

`true_identity` is never shown unless a `reveal_sender` effect fires. Attribution weights are positive numbers; red-herring evidence points at the wrong identity on purpose.

## Dialogue

```json
{
  "id": "dialogue.example", "type": "dialogue", "season": "season.1", "start": "n1",
  "nodes": {
    "n1": {
      "speaker": "identity.nora", "text_key": "...", "portrait": "worried",
      "choices": [
        { "text_key": "...", "next": "n2", "conditions": { "has_clue": "clue.a" },
          "effects": [ { "op": "set_flag", "id": "met_nora" } ] }
      ]
    },
    "n2": { "text_key": "...", "end": true }
  }
}
```

Node fields: `speaker`, `text_key`, `portrait`, `effects` (run on entry), `next`, `end`, `choices`.

## Conditions

`null`/`[]` = true; an array is AND; a dictionary ANDs its operators.

`all`, `any`, `not`, `has_clue`, `flag` (string, or `{id, equals}`), `choice` (`{id, option}`), `identified` (message id), `identity_is` (`{message, identity}`), `season_unlocked`, `season_done`, `visited`, `ending_seen`, `solved`.

Unknown operators fail closed (evaluate false) and are validation errors.

## Effects

`{"op": ..., "id": ...}` with ops: `add_clue`, `deliver_message`, `reveal_sender`, `set_flag` (optional `value`), `set_choice` (needs `option`), `unlock_season`, `complete_season`, `set_season`, `visit`, `trigger_ending`.

## Validate

```bash
godot --headless --path . -s tools/validate_content.gd
godot --headless --path . -s tools/validate_content.gd -- res://content/packs/core user://packs/my_pack
```
