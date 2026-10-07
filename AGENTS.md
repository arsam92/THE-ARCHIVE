# Working on THE ARCHIVE (humans and AI agents)

## Workflow

1. Pull the latest changes.
2. Inspect repository state (`git status`, `git log`).
3. Create a focused branch: `feature/<topic>`, `fix/<topic>`.
4. Implement one feature.
5. Run `tests/run_tests.gd` and `tools/validate_content.gd`; both must pass.
6. Commit with a clear message (what and why).
7. Push the branch and open a pull request.
8. Report the files changed and the tests performed.

## Rules

- **Do not invent canon.** Names, events, identities, clue meaning and endings come from the approved narrative specification. If something is missing, ask. Test fixtures must be clearly marked `[FIXTURE]` and live under `tests/`.
- **Do not modify unrelated files.**
- **Story stays in data.** No dialogue text, puzzle solutions or branching logic in `.gd` files. Add content under `content/packs/` and strings under that pack's `locales/`.
- **Never commit secrets.** No GitHub tokens, keystores, passwords or signing credentials. Use environment variables or the platform's authentication, and never print secrets to logs. `.gitignore` already excludes `*.keystore`, `*.jks` and `.env`.
- **Add tests for critical systems** and for every bug fixed.
- **Do not claim a feature is done** until it is tested. Features that need a device (Android lifecycle on hardware, performance, UI scaling) are not verified by headless unit tests; say so in the report.

## Conventions

- GDScript with static types where practical. Core logic lives in `src/core/` as `RefCounted` classes with no scene dependencies so it stays testable.
- Entity ids are `type.slug` (lowercase, digits, underscore). See [`docs/CONTENT_SCHEMA.md`](docs/CONTENT_SCHEMA.md).
- New relations between entities use the `refs` mechanism; add the relation name to `StoryGraph.ALLOWED_RELS` and document it.
