# 0005. Crash-only telemetry (Sentry), no product analytics

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

A solo developer needs to know when the production app crashes, but the product positioning is privacy-first ("data never leaves your device"). Full analytics would force Data Safety declarations and weaken the marketing claim; zero telemetry leaves production crashes undiagnosed and generates unfixable bad reviews.

## Decision

Ship **crash reporting only, via Sentry, with PII scrubbing enabled**. No product-analytics SDK (no Firebase Analytics, no Mixpanel). The privacy policy discloses crash data collection explicitly. Product learning comes from closed-beta feedback (ADR-0008), Play reviews, and an in-app feedback channel.

## Consequences

- Production crashes are diagnosable; behavioral funnels are not measured.
- Data Safety form stays minimal (crash data, optional).
- The "no tracking" positioning survives with an honest, narrow disclosure.
