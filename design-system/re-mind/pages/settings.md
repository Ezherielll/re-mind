# Page: Settings (+ Pro sheet)

Overrides `../MASTER.md` where more specific.

## User goal

Control the digest rhythm, own the data, and optionally support the app once.

## Structure — grouped list, rows ≥56dp, chevron on navigation rows

1. **Preferences**
   - **Daily check-in** — bell icon; value text shows chosen time ("9:00 AM"); tap → time picker; reschedules digest on confirm (snackbar "Daily check-in set for 9:00 AM").
2. **Data**
   - **Export** — share-sheet JSON (ADR-0004); helper line under group: "Your data stays on this device."
   - **Import** — file picker; result snackbar success/failure counts.
   - **Backups** — subpage listing rolling 7-day local backups (date + size), tap → restore confirm dialog ("Replaces current data").
3. **Pro**
   - Row "Re:Mind Pro — lifetime" with state: purchased (check icon) / not purchased (accent dot).
   - Gated rows (themes, app icon, advanced history views) show lock icon; tapping a locked row opens the **Pro sheet**.
4. **About**
   - Version row (static), **Privacy policy** (external link, in-app browser), **Send feedback** (mailto intent).

## Pro sheet (bottom sheet)

- Handle, title "Re:Mind Pro" 24/w700, three benefit bullets (icon + line, 16/w400):
  - Custom themes & app icon
  - Advanced history views
  - Lifetime — pay once, keep forever
- Price row large: display numeral style ("$7.99") + "one time" caption.
- Primary button "Buy lifetime" (accent orange, ≥52dp) + text button "Restore purchase" under it.
- Billing states: pending → button spinner; error → inline error text, button re-enabled; unbilled/grace → banner text, no crash (ticket T13).

## Do / Don't

- ✅ Export is free and always available — never behind Pro (ADR-0006).
- ❌ No account/login rows anywhere.
- ❌ Don't use dialogs for destructive-feeling ops with more than 2 options (backups → subpage instead).
