# 0006. Freemium with a lifetime Pro unlock

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

Unknown developer, utility category. Subscriptions add billing complexity, churn management, and resistance before willingness-to-pay is validated; paid-upfront kills discovery for an app with no reputation.

## Decision

**Freemium with one lifetime Pro in-app purchase (~USD 6–9):**

- **Free tier = the entire core value**: unlimited commitments, capture, home list, digest notifications, notes, history, and JSON export/import.
- **Pro** gates cosmetics and future power features: themes/app icon, advanced history views; later recurring follow-ups and attachments if built.
- Single SKU via `in_app_purchase`; no subscription infrastructure in v1.

## Consequences

- Minimal billing surface and support burden; lower revenue per user than a subscription — revisit only if cloud sync ever ships (it would become the natural Pro anchor).
- Export must never be gated: it is the privacy promise (ADR-0004), not a feature.
- Free tier must stay genuinely complete to drive word-of-mouth growth.
