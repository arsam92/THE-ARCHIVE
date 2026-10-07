# Roadmap and status

Honest status of every item in the project brief. "Tested" means covered by the headless test suite; nothing here has been run on an Android device yet.

## Done in the foundation milestone

| Area | Status |
| --- | --- |
| Data-driven story graph (clues, identities, messages, files, locations, seasons, choices, endings) | Implemented, tested |
| Season graph per the brief (I, II, III interconnected; IV reinterprets) | Implemented as data, tested |
| Forward and cross-season clue references | Implemented, tested |
| Anonymous message system (SOURCE / ID / AUTHENTICITY, evidence-based sender inference, reinterpretation, reveal) | Implemented, tested |
| Sender identity roster (Nora, Elias, Archive, Observer, Subject Zero, Future Player, Unknown Source) | Names only, no lore |
| Dialogue system with branching and gated choices | Implemented, tested |
| Puzzle system (code, sequence, pairing) | Implemented, tested |
| Multiple endings (priority and conditions) | Implemented, tested |
| Save/load (checksum, backup, corruption handling) | Implemented, tested |
| Localization (fallback, placeholders, coverage) | Implemented, tested |
| Corrupted/invalid content handled safely | Implemented, tested |
| Android lifecycle autosave/restore logic | Logic tested; notification wiring needs device verification |
| Downloadable content packs (manifest, dependencies, schema version, path safety) | Implemented, tested |

## Not started

- 2D environments, sprites, animation, portraits and emotion variants
- Parallax, camera, lighting, shadows, particles
- Glitch, CRT, screen distortion, cinematic transitions (shaders)
- Archive terminal UI, evidence board, file viewer, message interface, animated UI
- Interactive rooms and objects
- Audio, music, subtitles
- Settings and accessibility (text size, contrast, reduced flicker, colour-blind safe indicators)
- Trust / authenticity indicator visuals (data model exists)
- UI scaling and multi-resolution testing
- Season progression flow and menus
- Performance and memory profiling on mid-range devices
- Signed APK and AAB builds, device testing (see `ANDROID_RELEASE.md`)

## Blocked on input

- **Narrative specification.** Season content, characters, clues, messages, locations and endings. None is invented here; test fixtures are labelled `[FIXTURE]`.
- **Art direction assets.** Style references or asset source (original art, generated, licensed).
- **Orientation and target devices.** Currently landscape, sensor-based, as a default pending approval.

## Suggested next milestones

1. Archive terminal and message UI on top of the existing systems (still placeholder art).
2. Shader pack: CRT, glitch, flicker, with quality tiers and a reduced-motion setting.
3. Evidence board and file viewer.
4. Room scene framework with parallax, camera and interactive objects.
5. Import approved narrative content for Season I.
6. Android export, signing, device test pass, AAB.
