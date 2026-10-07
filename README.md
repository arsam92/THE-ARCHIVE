# THE ARCHIVE

A multilingual narrative mystery project. All content is developed across six languages
with strict preservation of **meaning, tone, character personality, suspense, ambiguity,
mystery, puzzle logic, and hidden clues**.

> **Canon rule:** story content is canonical only when it enters this repository through an
> approved content batch. Localization adapts — it never invents.

## Languages

| Code | Language | Script · Direction        | Localization notes                          |
| ---- | -------- | ------------------------- | ------------------------------------------- |
| `fa` | Persian  | Arabic script · **RTL**   | Primary language. Verify bidi & mirroring.  |
| `en` | English  | Latin · LTR               | Source of truth for all localization.       |
| `ar` | Arabic   | Arabic script · **RTL**   | Verify shaping, ligatures, numerals.        |
| `ja` | Japanese | Kanji/Kana · LTR          | No word spaces; full-width punctuation.     |
| `es` | Spanish  | Latin · LTR               | Budget for ~+20–30% text expansion.         |
| `fr` | French   | Latin · LTR               | Budget for ~+20–30% text expansion.         |

## Repository structure

```
├── README.md                 ← this file
├── QA_CHECKLIST.md           ← mandatory gate for every content/localization batch
├── localization/
│   ├── README.md             ← conventions, key naming, protected-string rules
│   └── strings/              ← one JSON per locale (en = source of truth)
├── src/                      ← Next.js 16 app shell (TypeScript, Tailwind CSS 4, shadcn/ui)
├── prisma/                   ← database schema (SQLite via Prisma)
└── examples/                 ← reference code (e.g. WebSocket demo)
```

## Localization

- **Source of truth:** `localization/strings/en.json`
- **Locales:** `fa`, `ar`, `ja`, `es`, `fr` files sit beside it in `localization/strings/`
- **Conventions & protected strings:** see [`localization/README.md`](localization/README.md)
- **QA gate:** every batch must pass [`QA_CHECKLIST.md`](QA_CHECKLIST.md) before publishing

### Protected strings — never translated

Unless a batch explicitly instructs otherwise, the following are copied **verbatim** into
every locale: cryptographic strings, passwords, IDs, file IDs, puzzle keys, hashes, and
intentionally encoded text. Translation must never break puzzle integrity or hidden clues.

## Publishing workflow

1. Inspect the repository, pull latest changes, confirm current branch
2. Create a **focused branch** (`feat/…`, `fix/…`, `l10n/…`)
3. Make changes — never touch unrelated files
4. Run validation: lint, typecheck, JSON integrity, and the QA checklist
5. Inspect the diff file-by-file and run the pre-publish security scan
6. Commit, push, then report: commit hash, changed files, validation results

**Hard rules:** never force push · never delete branches without explicit instruction ·
no secrets in commits · approved narrative content is never overwritten without authorization.

## Security policy

- GitHub authentication is read **only** from the environment (`GITHUB_TOKEN`) or an
  authenticated GitHub CLI session — never hardcoded, echoed, or committed.
- Every batch passes a secret scan (tokens, API keys, credentials, personal data) before push.
- If a token is ever exposed in chat, logs, or history: **rotate it immediately**.

## App shell

`src/` is a Next.js 16 (App Router) + TypeScript 5 shell with Tailwind CSS 4 and shadcn/ui
components, Prisma (SQLite) wired in, and `next-intl` available for binding the six locales
to the UI.
