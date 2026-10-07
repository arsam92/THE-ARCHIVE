# Localization

Structure, conventions, and rules for the six THE ARCHIVE locales.

## Layout

```
localization/
├── README.md          ← this file
└── strings/
    ├── en.json        ← source of truth
    ├── fa.json        ← فارسی (RTL)
    ├── ar.json        ← العربية (RTL)
    ├── ja.json        ← 日本語
    ├── es.json        ← Español
    └── fr.json        ← Français
```

Locale files are currently **structural placeholders** (`_meta` only). They are populated
exclusively by approved content batches — never seeded with invented narrative.

## Key naming

- Pattern: `<domain>.<context>.<name>`
  - `ui.menu.start`, `ui.settings.language`
  - `dialogue.CAS.031.line` · `subtitle.S03.18`
  - `quest.Q01.title` · `quest.Q01.desc`
  - `puzzle.P04.prompt` · `puzzle.P04.hint1`
  - `evidence.E04.title` · `evidence.E04.body`
  - `msg.anon.012.body`
- Domains: `ui`, `dialogue`, `subtitle`, `quest`, `puzzle`, `evidence`, `msg`, `meta`
- Keys are **stable identifiers**. Never rename a key without a migration note in the batch report.

## Protected values — DO NOT TRANSLATE

Keys matching `*.id`, `*.hash`, `*.code`, `*.key`, `*.password`, `*.encoded` hold protected
values. In every locale:

- copy the value **verbatim**,
- mark the entry `"protected": true`,
- never translate, transliterate, case-fold, re-encode, or "fix" them.

This preserves puzzle integrity and hidden clues across languages.

## Placeholders & interpolation

- ICU-style placeholders: `{playerName}`, `{count}` — every placeholder must appear exactly
  once per translated string, spelled identically.
- Reorder sentences freely for natural phrasing, but never break the grammar around a placeholder.

## Locale-specific rules

### fa · ar (right-to-left)

- Mirror layout-sensitive UI; keep timestamps/code snippets LTR inside bidi isolation.
- Use proper Arabic question mark `؟`, comma `،`, and Persian forms (`ی`, `ک`, `هٔ`) where appropriate.
- Verify shaping in a real renderer — contextual glyph joining, no isolated forms mid-word.

### ja

- No half-width spaces between words; use full-width punctuation (`。`, `、`, `「」`).
- Watch for unexpected extra spacing caused by markup; verify line-break opportunities.

### es · fr

- Expect ~+20–30% expansion vs English; keep buttons/labels within layout budget.
- French: use `« »`, non-breaking space before `! ? : ;`, proper accents on capitals.

## Process

1. Approved content lands in `en.json` first.
2. Each locale is adapted by meaning, tone, and voice — never word-for-word.
3. Run the full [`../QA_CHECKLIST.md`](../QA_CHECKLIST.md).
4. Publish via the repository workflow: focused branch → validation → security scan → push.
