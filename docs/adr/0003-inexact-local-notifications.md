# 0003. Inexact local notifications, no exact-alarm permission

- **Status:** Accepted
- **Date:** 2026-08-21

## Context

The digest and due-today alerts are the retention engine, but Android 12+ restricts exact alarms: `SCHEDULE_EXACT_ALARM` is default-deny on Android 14 (manual opt-in in settings), `USE_EXACT_ALARM` is restricted by Play policy to alarm/calendar apps, and Workmanager polling is delayed unpredictably by Doze. A daily check-in digest does not need second-level precision.

## Decision

Schedule all notifications with **`flutter_local_notifications` + `timezone` using inexact `zonedSchedule`**. The daily digest reschedules itself via a boot-completed receiver. The app never requests an exact-alarm permission.

## Consequences

- Notifications may fire ±5–15 minutes late — acceptable for a check-in digest and same-day alerts.
- Zero Play policy friction and no Android 14 permission dead-end.
- No headless background polling; scheduling logic lives in one notification service.
