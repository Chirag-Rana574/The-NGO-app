# NGO Medicine System - Session Handoff (2026-04-03)

Use this document to quickly resume the project with Antigravity.

## 🚀 Current Status
- **Servers:** All servers (Backend & Expo) have been shut down manually.
- **Git State:** A stuck commit was cleared (`.git/index.lock` removed).
- **Environment:** Backend is configured (Supabase connected), Mobile is configured for Expo Go (Local IP: `192.168.0.104`).

## 📋 Files to Review on Return
1. [expo_runtime_logs.md](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/expo_runtime_logs.md) - Contains the logs from the last running session.
2. [project_audit.md](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/project_audit.md) - High-level tracker for all system issues.

## 🛠️ Resolved in this Session
- Fixed a crash loop in Expo Go related to `expo-notifications` (SDK 53+ incompatibility) by bypassing token registration in dev mode.
- Unlocked the Git repository.
- Verified backend-to-frontend network connectivity (No more Axios 401/Network errors).

## 📌 Pending Tasks (The "Next Steps")
1. **Fix Stock Keyboard:** Change `keyboardType` in the Stock Adjustment UI to support plus/minus/decimals.
2. **Implement Slidable Calendar:** Replace the static week-strip with a navigatable horizontal calendar.
3. **Address 400/422 Errors:** Fix the "duplicate medicine" and "null amount" validation errors caught in the runtime logs.

## 🏃 How to Restart
1. **Backend:** `cd backend && source venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload`
2. **Frontend:** `cd mobile && HOME=$(pwd)/.expo_home EXPO_NO_TELEMETRY=1 npx expo start -c`
