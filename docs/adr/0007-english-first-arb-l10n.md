# 0007. English-first UI with .arb localization from day one

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

The beachhead (freelancers/solo professionals) is a global segment with higher willingness to pay, but the home market (Indonesia) offers low-competition validation. Retrofitting i18n into a finished Flutter app is expensive; doing it from the first commit is cheap.

## Decision

- Every user-facing string lives in **`.arb` files from the first commit** (`flutter_localizations` + `gen_l10n`, hardcoded literals rejected by lint).
- The shipped UI language is **English**.
- Store listing ships as **English + Indonesian** simultaneously.
- Bahasa Indonesia UI translation is added post-validation as pure translation work — no refactor.

## Consequences

- Slight per-string overhead during development.
- No bilingual QA burden at launch (one UI language).
- Global ASO addressable from day one while keeping the ID market one translation away.
