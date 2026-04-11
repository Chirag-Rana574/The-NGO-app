# Expo Runtime Error Logs

This file tracks all errors, warnings, and significant events captured during the active Expo/Backend development session.

---

## Session: 2026-04-03 16:07

### 🔵 Manual Feedback & UI Issues

| Timestamp | Issue | Status | Description / UX Impact |
|---|---|---|---|
| 16:04:15 | **Keyboard** | ✅ FIXED | No plus/minus keys when editing stock → Added stepper buttons (+/−) and `numbers-and-punctuation` keyboard |
| 16:04:15 | **Calendar** | ✅ FIXED | Week strip is not slidable → Added ‹/› navigation arrows with "Back to Today" button |
| 17:15:00 | **Safe Area** | ✅ FIXED | Tray overlapping phone bottom buttons → Used `useSafeAreaInsets` for tab bar positioning |
| 17:15:00 | **Calendar UI** | ✅ FIXED | Sliding calendar doesn't work → Now has week-by-week navigation |
| 17:15:00 | **Visual Bug** | ✅ FIXED | Sliding taskbar old version → Tab bar updated with safe area support |
| 17:15:00 | **State Sync** | ✅ FIXED | New event not visible in list → Added navigation `focus` listener to reload data |
| 17:15:00 | **Misc Question** | ✅ FIXED | "Regional district/cse/sector" → Removed placeholder text, now shows selected date |
| 17:15:00 | **Sorting** | 🟡 TODO | "Sorted by recent" doesn't work correctly |
| 17:15:00 | **Redundancy** | 🟡 INFO | Edit and stock buttons serve different purposes (edit metadata vs adjust stock count) |
| 17:15:00 | **UX/Keyboard** | ✅ FIXED | No + or - on keyboard → Same as Keyboard fix above |
| 17:24:00 | **UI/Placeholder** | ✅ FIXED | Three dots (⋮) now opens the sidebar drawer |
| 17:24:00 | **UI/Placeholder** | ✅ FIXED | Removed non-functional search icons from headers; ⋮ now opens drawer instead |

---

### 🔴 Critical & API Errors

| Timestamp | Component | Error Level | Status | Message / Detail |
|---|---|---|---|---|
| 16:03:28 | **Backend** | `ERROR` | 🟡 BY DESIGN | `Medicine with name 'Crocin' already exists` — Duplicate prevention working correctly |
| 16:03:28 | **Backend** | `ERROR` | ✅ FIXED | `Validation error: null amount` — Added input validation + stepper to prevent empty submissions |
| 15:52:20 | **Frontend** | `ERROR` | ✅ FIXED (prev session) | `Error getting push token` — Bypassed in Expo Go SDK 53+ |
| 15:52:20 | **Frontend** | `ERROR` | ✅ FIXED (prev session) | `expo-notifications removed from Expo Go` — Skips registration in Expo Go |
| 17:15:10 | **Frontend** | `ERROR` | 🟡 NETWORK | `AxiosError: Network Error` — Occurs when backend is not running on LAN |
| 17:17:14 | **Backend**  | `ERROR` | 🟡 CONFIG | `TwilioRestException: Authenticate Error 20003` — Twilio sandbox credentials expired |

### 🟡 Warnings & Socket Events

| Timestamp | Component | Level | Message |
|---|---|---|---|
| 15:52:20 | **Frontend** | `WARN` | `expo-notifications` functionality is not fully supported in Expo Go |
| 15:49:35 | **Backend** | `INFO` | `🚀 Reminder scheduler started (interval: 30s)` |

### 🟢 Successful API Traffic

| Timestamp | Method | Route | Status |
|---|---|---|---|
| 16:07:40 | `GET` | `/api/reports/dashboard`| `200 OK` |
| 16:07:40 | `GET` | `/api/reports/stock-summary`| `200 OK` |
| 16:07:40 | `GET` | `/api/reports/worker-performance`| `200 OK` |
| 16:00:10 | `GET` | `/api/auth/key-status`| `200 OK` |
| 16:00:12 | `GET` | `/api/schedules` | `200 OK` |
| 16:00:12 | `GET` | `/api/patients` | `200 OK` |
| 16:00:12 | `GET` | `/api/medicines` | `200 OK` |

---

## Fixes Applied (2026-04-11)

### Files Modified:
1. **MedicinesScreen.tsx** — Stock adjustment: +/− stepper buttons, `numbers-and-punctuation` keyboard, null validation, live preview
2. **SchedulesScreen.tsx** — Slidable calendar: ‹/› week arrows, "Back to Today" button, removed "Regional District A", focus reload
3. **HomeScreen.tsx** — Focus listener to reload today's tasks when returning from CreateSchedule
4. **App.tsx** — Safe area insets for tab bar, wired ⋮ button to open drawer, removed non-functional search icons
