# THE ARCHIVE — Localization Guidelines

Applies to every locale of THE ARCHIVE: **English · فارسی (fa) · العربية (ar) · 日本語 (ja) · Español (es) · Français (fr)**.

Translation adapts meaning — it never translates word for word, and it never invents canon.

## Principles (every string, every locale)

- **Meaning** — the information the string carries survives intact.
- **Tone** — register and mood match the source.
- **Character personality** — each speaker stays recognizable.
- **Suspense & mystery** — tension must survive translation.
- **Ambiguity** — intentional ambiguity stays ambiguous in the same way.
- **Puzzle logic** — every puzzle stays solvable in every language.
- **Hidden clues** — clues stay discoverable; never flatten, over-explain, or accidentally reveal them.

## Protected strings — DO NOT TRANSLATE

Unless a batch explicitly instructs otherwise, copy **verbatim** in every locale:

- cryptographic strings
- passwords
- IDs and file IDs
- puzzle keys
- hashes
- intentionally encoded text

Never transliterate, re-case, re-encode, or "fix" them. If a protected string seems to need
a change, that is a canon decision — escalate; do not edit.

## Where locale files live

Locale strings live with their content pack under
`content/packs/<pack>/locales/<lang>.json` — flat dotted keys such as `season.1.name`,
`identity.<slug>.name`, `ui.*` — as established by the story engine foundation and
`docs/CONTENT_SCHEMA.md`.

- **English is the source of truth.** Approved English strings land first; locales follow.
- **Keys are stable identifiers.** Never rename a key without a migration note in the batch report.
- **Entity ids** follow `type.slug` (lowercase, digits, underscore).
- **Enum machine values stay machine** (`auth.UNKNOWN`); translate only the human-facing string.

### Locked names

Public season titles are locked with the public README:
**THE ARCHIVE · THE WITNESS · THE OBSERVER · THE LAST RECORD**.
Do not rename or re-title them in any locale without explicit batch guidance.
Character names follow the locked canon; official localized name spellings are defined per
approved batch — do not improvise them.

## Locale-specific technical rules

### fa · العربية (right-to-left)

- Mirror layout-sensitive UI; keep timestamps, IDs, code, and ciphers LTR inside bidi isolation.
- Correct marks: Arabic comma `،`, Arabic question mark `؟`; Persian `ی`/`ک` and ZWNJ (نیم‌فاصله) used correctly.
- Verify shaping in a real renderer: contextual joining, no isolated glyphs mid-word, correct ligatures.

### 日本語 (ja)

- No stray half-width spaces between words; full-width punctuation (`。`, `、`, `「」`).
- Check line-break opportunities and UI overflow with CJK glyph widths.

### Español · Français (expansion)

- Budget ~+20–30% vs English in buttons, labels, menus, and tables.
- French: `« »` with non-breaking space before `! ? : ;`; accents where the register requires.
- Spanish: opening `¡ ¿` where the register requires.

## Subtitles & UI budgets

- Subtitles: ≤ 42 chars/line, ≤ 2 lines, reading speed respected; preserve timing.
- UI: no overflow, truncation, or broken wrapping in any locale — verify at the smallest
  supported Android screen.

## Batch process

1. Approved English strings land first (canon-approved content only).
2. Translate per the principles above — meaning, not words.
3. Run the full [`QA_CHECKLIST.md`](QA_CHECKLIST.md).
4. Publish per the repository workflow: focused branch → validation → security scan →
   push → pull request.

> If a localized clue appears to point players outside the official surfaces, flag it —
> see `SPOILERS/SAFETY.md`. Safety overrides flavour.
