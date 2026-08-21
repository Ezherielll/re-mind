# 0004. Manual JSON export/import plus rolling local auto-backup

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

Local-first means device loss or replacement destroys all open loops — the top complaint pattern of local-first apps. Automatic Google Drive backup would require OAuth consent verification (weeks of delay), and the privacy positioning demands a data-egress path the user controls.

## Decision

- **User-initiated export/import** of a versioned JSON file via the OS share sheet (user chooses Drive, WhatsApp, local storage, etc.).
- **Rolling automatic local backups** covering the last 7 days, stored inside app-private storage and restorable in-app.
- No accounts, no backend, no cloud component in v1.

## Consequences

- Restore requires the exported file; the app must guide users to export before uninstalling (settings + first-run hint).
- Play Data Safety can honestly declare "no data collected".
- The export format is versioned from the start for forward compatibility.
- Export is core, free functionality — never a premium gate (see ADR-0006).
