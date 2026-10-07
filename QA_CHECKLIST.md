# THE ARCHIVE — Content QA Checklist

Every localization batch and content change **must** pass this checklist before publishing.
A batch ships only when every applicable item can be honestly checked.

## 1. Localization quality (per batch)

- [ ] Meaning preserved — no literal word-for-word translation
- [ ] Tone preserved
- [ ] Character personality preserved
- [ ] Suspense preserved
- [ ] Ambiguity preserved (intentional ambiguity must survive translation)
- [ ] Mystery preserved
- [ ] Puzzle logic intact
- [ ] Hidden clues intact (still discoverable, never flattened or over-explained)

## 2. Do-not-translate compliance

- [ ] Cryptographic strings untouched
- [ ] Passwords untouched
- [ ] IDs and file IDs untouched
- [ ] Puzzle keys untouched
- [ ] Hashes untouched
- [ ] Intentionally encoded text untouched

## 3. Technical & formatting

- [ ] No UI overflow in any locale (buttons, menus, cards, dialogs)
- [ ] Subtitle length within budget — default: ≤ 42 chars/line, ≤ 2 lines, reading speed respected
- [ ] Punctuation correct per locale (e.g. « » … ، ؟ 。 、 「」 ¡ ¿)
- [ ] **RTL layout verified** for `fa` / `ar`: mirroring, numeral handling, bidi isolation around
      placeholders and protected strings, mixed-direction safety
- [ ] **Japanese spacing correct**: no stray half-width spaces, full-width punctuation, natural line breaks
- [ ] **Arabic shaping verified** in real rendering (contextual forms connect correctly; no isolated glyphs)
- [ ] **Spanish/French expansion** accounted for in fixed-width UI (labels, buttons, tables)

## 4. Content QA detections (all must be zero)

- [ ] Missing translations
- [ ] Duplicate keys (within a file or across locale files for the same concept)
- [ ] Broken references (keys, files, or assets pointing at nothing)
- [ ] Inconsistent names (same entity spelled/named differently across locales or files)
- [ ] Accidental spoilers (early exposure via keys, tooltips, alt text, filenames, metadata)
- [ ] Broken puzzle answers (solution path re-verified in every locale)
- [ ] UI overflow
- [ ] Malformed files (valid JSON, UTF-8 without BOM, no trailing commas, correct line endings)

## 5. Pre-publish security scan

- [ ] No secrets: tokens, API keys, passwords, private credentials
- [ ] No accidental personal data
- [ ] `.env` and local artifacts untracked (`git ls-files` clean)
- [ ] Full diff inspected file-by-file before commit

## Sign-off

Record in the batch report: **date · branch · commit hash · validator · open issues**.
A batch without a sign-off line is not considered published.
