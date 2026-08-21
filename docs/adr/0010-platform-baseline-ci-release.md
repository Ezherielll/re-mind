# 0010. Platform baseline: minSdk 24, no SQLCipher, GitHub Actions CI, manual releases

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

Trade-offs between device coverage and maintenance, between encryption claims and actual threat model (data sits in app-private storage on a personal phone; the realistic risk is loss of the device, addressed by ADR-0004), and how much release automation a solo pre-launch project needs.

## Decision

- **minSdk 24 (Android 7.0)**, target SDK always latest stable — covers the vast majority of active devices.
- **No SQLCipher in v1.** Rely on the OS sandbox; never market "encrypted at rest" — the honest claim is "data never leaves your device".
- **GitHub Actions** runs `flutter analyze` + tests on every push.
- **Releases are built locally and uploaded via Play Console** during v1; fastlane/automation deferred until cadence justifies it.

## Consequences

- Minimal native configuration surface and permission list (notifications only, per ADR-0003).
- Privacy policy hosted on GitHub Pages; Data Safety answers follow ADR-0004/0005.
- Release process stays manual and boring until volume makes automation worth its maintenance.
