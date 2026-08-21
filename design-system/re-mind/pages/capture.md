# Page: Capture Sheet

Overrides `../MASTER.md` where more specific.

## User goal

Record a hanging commitment in seconds: one sentence + two taps. The sheet must feel lighter than opening a form.

## Presentation

- **Modal bottom sheet**, drag handle, slides up in 250ms (easeOutCubic), scrim 50% black.
- Opens with keyboard up and text field focused (autofocus).
- Dismiss: scrim tap, back gesture, or save. Discard-guard only if text non-empty (snackbar "Discarded — Undo" 5s).

## Field order (top → bottom)

1. **Text field** — placeholder "What's hanging?", multiline (grows 1→3 lines), 16/w400, no label visible (placeholder-only acceptable here because the sheet IS the label; screen-reader label still provided).
2. **Direction toggle** — segmented control, two equal segments ≥48dp tall:
   - "I owe" (default, outgoing)
   - "Waiting for" (incoming)
   - Selected segment: filled teal; announcement: "Direction: I owe, segment 1 of 2".
3. **Person field** — inline chip input with autocomplete dropdown (existing people, prefix-filtered); typing an unknown name creates it on save silently; skippable.
4. **Reminder chips** — horizontal scroll, single-select:
   `[None] [Tomorrow] [In 3 days] [On due date] [Custom…]`
   - Default selection = deterministic default for chosen direction (CONTEXT.md), shown as selected chip labeled "Default".
5. **Live explainer line** — 13/w400 muted, updates as chips/direction change:
   "Will remind Thursday, Aug 27 · due Friday" — the determinism promise made visible.

## Save affordance

- Trailing keyboard action button (check icon, accent orange) + full-width "Save" button ≥52dp appears when keyboard closed.
- Enabled iff text non-empty; otherwise 38% opacity, no haptic.
- On save: sheet closes immediately, snackbar "Saved" (no undo in v1).

## States

- Text empty → Save disabled.
- Custom chip → inline date picker row expands below chips (not a dialog hop).
- Autocomplete open → list overlays below person field, max 4 suggestions visible.

## Do / Don't

- ✅ Every control reachable in order; save from keyboard without scrolling.
- ❌ No required-field errors (nothing here can fail validation).
- ❌ No AI parsing, no tags, no priority pickers in v1 (ADR scope).
- ❌ Don't animate width/height of the text field; let it grow naturally.
