# Production Readiness Audit — Complete

Audited every file: 14 backend modules, 14 backend routers, 16 mobile screens, 3 services, 2 components, all config files.

---

## Summary

| Category | Count | Severity |
|---|---|---|
| 🔴 **Critical Security** | 8 | Must fix before any real use |
| 🟠 **Infrastructure & Deployment** | 7 | Must fix before hosting |
| 🟡 **Backend Code Quality** | 6 | Bugs & maintainability |
| 🔵 **Mobile App Issues** | 6 | Breaks device testing |
| ⚪ **Dead Code & Cleanup** | 4 | Remove before production |
| 🟣 **Testing & Monitoring** | 3 | Risk without them |
| 📝 **Documentation** | 1 | Professional delivery |

**Total: 35 items**

---

## 🔴 Critical Security (8 items)

### S1. API Routes Have Zero Authentication
**Files:** All routers except [push.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/push.py)

[get_current_user](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/google_auth.py#65-81) (JWT auth) is only used in [push.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/push.py) and `/auth/me`. The following 12 routers are **completely unprotected** — anyone with the URL can read/write/delete all data:

| Router | File | What's exposed |
|---|---|---|
| schedules | [schedules.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/schedules.py) | CRUD all schedules |
| patients | [patients.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/patients.py) | CRUD all patients |
| workers | [workers.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/workers.py) | CRUD all workers |
| medicines | [medicines.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/medicines.py) | CRUD all medicines + stock |
| reports | [reports.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/reports.py) | All dashboard data |
| audit | [audit.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/audit.py) | Full audit trail |
| exports | [exports.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/exports.py) | CSV downloads |
| settings | [settings.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/settings.py) | App config |
| cleanup | [cleanup.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/cleanup.py) | Permanent data deletion |
| auth (key mgmt) | [auth.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/auth.py) | Setup/change master key |
| test-whatsapp | [test_whatsapp.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/test_whatsapp.py) | Send WhatsApp to ANY number |
| notifications | (via push.py) | Only one that IS protected ✅ |

**Risk:** Anyone who discovers your backend URL can delete all patients, change schedules, export data, and send WhatsApp messages.

**Fix:** Add `current_user: User = Depends(get_current_user)` to every route. ~30 min.

---

### S2. SECRET_KEY is a Placeholder
**File:** [.env:15](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/.env)
```
SECRET_KEY=your-secret-key-here-change-in-production
```
JWT tokens are signed with this known string → anyone can forge authentication tokens.

**Fix:** `python3 -c "import secrets; print(secrets.token_urlsafe(32))"` → paste into .env. **1 min.**

---

### S3. No .gitignore — Secrets Will Be Pushed
**Location:** `/Users/chiragrana/Downloads/idk/ngo-medicine-system/` — no `.gitignore` found anywhere.

If you `git push`, the following are exposed:
- `.env` → Supabase DB password, Twilio tokens, Google OAuth client ID
- `venv/` → hundreds of MB of junk
- `node_modules/` → hundreds of MB more
- `.expo/` → device info

**Fix:** Create `.gitignore` at project root. **2 min.**

---

### S4. Test WhatsApp Router in Production
**File:** [test_whatsapp.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/test_whatsapp.py)

Exposes `POST /api/test-whatsapp/send-message` — sends WhatsApp to **any phone number** with **any message**. No authentication. Anyone can use your Twilio credits.

**Fix:** Either remove router from `main.py`, or guard with `if settings.debug:`. **5 min.**

---

### S5. Master Key in Query String
**File:** [cleanup.py:23](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/cleanup.py#L23)
```python
master_key: str = Query(..., description="Master key required for purge")
```
Query strings are logged in server access logs, browser history, and proxy logs. The master key is visible in plaintext.

**Fix:** Move to request body: `class PurgeRequest(BaseModel): master_key: str`. **5 min.**

---

### S6. No Brute-Force Protection on PIN Verify
**File:** [auth.py:77-93](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/auth.py#L77-L93)

`/auth/verify-key` has no rate limiting. An attacker can try all 10,000 4-digit PINs in seconds.

**Fix:** Add per-IP rate limiting (5 attempts/minute) or account lockout after 5 failures. **15 min.**

---

### S7. DEBUG=True Skips Twilio Validation
**File:** [.env:32](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/.env)

With `DEBUG=True`, anyone can POST fake WhatsApp webhooks and mark schedules as completed without any worker actually doing them.

**Fix:** Set to `False` before any real testing. Only `True` during Cloudflare tunnel development. **1 min.**

---

### S8. CORS Wildcard (`*`) Allows All Origins
**File:** [main.py:31](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/main.py#L31)

`"*"` in ALLOWED_ORIGINS means any website can make API calls to your backend (XSS amplification).

**Fix:** Remove `"*"`, keep only your actual origins. **2 min.**

---

## 🟠 Infrastructure & Deployment (7 items)

### I1. No Backend Hosting
Backend runs only on your Mac. App dies when laptop sleeps/disconnects.

**Fix:** Deploy to Railway/Render/Fly.io. Dockerfile exists. **30-60 min.**

---

### I2. Hardcoded LAN IPs in Mobile
**Files:**
- [api.service.ts:4](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/src/services/api.service.ts#L4) → `http://192.168.0.106:8000/api`
- [ExportScreen.tsx:16](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/src/screens/ExportScreen.tsx#L16) → `http://10.248.163.249:8000/api` (stale!)

Breaks on every network switch. ExportScreen uses a completely different stale IP than api.service.ts.

**Fix:** Centralize in api.service.ts and import from there; or use `Constants.expoConfig.extra.apiUrl`. **10 min.**

---

### I3. Missing EAS Project ID
**File:** [app.json](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/app.json)

No `extra.eas.projectId` → push notifications crash trying to get project ID.

**Fix:** `npx eas init`. **2 min.**

---

### I4. Dockerfile Uses `--reload` 
**File:** [Dockerfile:24](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/Dockerfile#L24)

`--reload` watches for file changes — inappropriate for production. Causes unnecessary restarts.

**Fix:** Remove `--reload`, add `--workers 2`. **1 min.**

---

### I5. No .dockerignore
`venv/` (hundreds of MB) gets copied into the Docker image, making builds slow and images huge.

**Fix:** Create `backend/.dockerignore` with `venv/`, `__pycache__/`, `.env`, `.git/`. **1 min.**

---

### I6. Stale Twilio Webhook URL
**File:** [.env:11](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/.env#L11)

Points to a dead Cloudflare tunnel. Worker WhatsApp replies go nowhere.

**Fix:** After deploying backend, update to permanent URL + configure in Twilio Console. **5 min.**

---

### I7. Twilio Sandbox Number
**File:** [.env:10](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/.env#L10)

`+14155238886` is Twilio's shared sandbox. Requires workers to "join" first, expires after 72 hours of inactivity, can't be used in production.

**Fix:** Purchase a Twilio number ($1/mo) + register WhatsApp Business. **15 min.**

---

## 🟡 Backend Code Quality (6 items)

### Q1. `datetime.utcnow()` Used (Deprecated/Incorrect)
**Files:**
- [state_machine.py:91](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/state_machine.py#L91) → `schedule.updated_at = datetime.utcnow()`
- [stock_service.py:83](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/stock_service.py#L83) → `medicine.updated_at = datetime.utcnow()`

`datetime.utcnow()` creates **naive** datetime objects (no timezone info). This causes comparison bugs with timezone-aware datetimes from the database.

**Fix:** Replace with `datetime.now(timezone.utc)`. **2 min.** (We already fixed this in the webhook!)

---

### Q2. Synchronous Database Engine
**File:** [database.py:8](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/database.py#L8)

Uses `create_engine` (synchronous) with FastAPI (async framework). Every DB query blocks the event loop — limits concurrency.

**Risk:** Under load, the server becomes unresponsive.

**Fix (future):** Switch to `create_async_engine` with `AsyncSession`. Moderate effort (~2-4 hours). Not a blocker for PoC.

---

### Q3. No Database Migrations
**Directory:** [migrations/](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/migrations) — **empty**

Schema managed by `Base.metadata.create_all()` on startup. If you change a model (add/remove columns), existing data breaks silently.

**Fix:** Initialize Alembic, create initial migration. **15 min.**

---

### Q4. Dev Bypass Accepts Any Token
**File:** [LoginScreen.tsx:107](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/src/screens/LoginScreen.tsx#L107)

The dev bypass stores `jwt_token = 'dev-bypass-token'`. If the backend doesn't validate this token (it does — `verify_jwt` will reject it), the mobile app shows an "authenticated" state but all API calls fail.

More importantly: if the backend has a `dev-bypass-token` fallback somewhere, it's a backdoor.

**Fix:** Guard with `__DEV__` or remove for production builds. **1 min.**

---

### Q5. Cleanup Stats Endpoint Unprotected
**File:** [cleanup.py:75](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/routers/cleanup.py#L75)

`GET /cleanup/stats` requires no authentication — exposes how many records exist in each table.

**Fix:** Add `get_current_user` dependency. Part of S1 fix.

---

### Q6. `pool_size=10` May Be Too High for Supabase Free Tier
**File:** [database.py:11](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/database.py#L11)

Supabase free tier allows ~15 concurrent connections. With `pool_size=10` + `max_overflow=20`, you could open 30 connections and hit the limit.

**Fix:** Reduce to `pool_size=5, max_overflow=5` for Supabase free tier. **1 min.**

---

## 🔵 Mobile App Issues (6 items)

### M1. App Only Runs in Expo Go
Push notifications broken in Expo Go (SDK 53+). Google OAuth returns wrong redirect URI. Can't distribute to testers.

**Fix:** Build preview APK with `npx eas build --profile preview --platform android`. **20 min.**

---

### M2. ExportScreen Uses Wrong API URL
**File:** [ExportScreen.tsx:16](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/src/screens/ExportScreen.tsx#L16)
```typescript
const API_BASE = 'http://10.248.163.249:8000/api';
```
This is a completely different IP from `api.service.ts`. Exports will always fail.

**Fix:** Import from api.service.ts or use the same constant. **2 min.**

---

### M3. Offline Queue Only Handles Creates
**File:** [offline.ts](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/src/services/offline.ts)

Only supports `schedule`, `patient`, `worker` creates. No support for updates, deletes, or medicine operations.

**Risk:** Users think they've made changes offline but they're silently lost.

**Fix (future):** Extend queue to support all operation types. Not a blocker for PoC.

---

### M4. No Loading/Error States on Some Screens
**Files:** [MoreScreen.tsx](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/src/screens/MoreScreen.tsx)

MoreScreen is static (no API calls), which is fine. But CreateScheduleScreen and EditScheduleScreen don't show errors if the API call fails silently.

**Fix:** Add error alerts on form submission failures. **10 min.**

---

### M5. Google OAuth Client ID Hardcoded in LoginScreen
**File:** [LoginScreen.tsx:20](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/src/screens/LoginScreen.tsx#L20)

The Google Client ID is hardcoded in the source. Should be in app.json `extra` config.

**Fix:** Move to `Constants.expoConfig.extra.googleClientId`. **5 min.**

---

### M6. No App Icon or Splash Screen
**File:** [app.json](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/app.json)

No `icon`, `splash`, or `adaptiveIcon` config. App shows default Expo icon — looks unprofessional.

**Fix:** Design icon + splash screen, add to app.json. **15 min.**

---

## ⚪ Dead Code & Cleanup (4 items)

### D1. Celery App + Tasks Module (Dead Code)
**Files:** [celery_app.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/celery_app.py), [tasks.py](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/tasks.py)

Celery was replaced by `reminder_scheduler.py` (asyncio background task). These files import Celery + configure Redis beat schedules but are never used. Redis isn't even running.

**Fix:** Delete both files or add a note. **1 min.**

---

### D2. Stale LAN IPs in CORS Origins
**File:** [main.py:29-30](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/backend/app/main.py#L29-L30)

Old IPs `10.248.163.249` that haven't been used in weeks.

**Fix:** Remove stale entries, keep only relevant origins. **1 min.**

---

### D3. react-native-calendars Still in Dependencies
**File:** [package.json](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/package.json)

The full calendar was replaced by the custom week strip, but `react-native-calendars` is still installed (~400KB unused).

**Fix:** `npm uninstall react-native-calendars`. **1 min.**

---

### D4. @react-navigation/drawer Still in Dependencies
**File:** [package.json](file:///Users/chiragrana/Downloads/idk/ngo-medicine-system/mobile/package.json)

Drawer was replaced by a custom `Animated` sidebar due to Reanimated 3 conflicts. Package still installed.

**Fix:** `npm uninstall @react-navigation/drawer`. **1 min.**

---

## 🟣 Testing & Monitoring (3 items)

### T1. Zero Automated Tests
No test files found. `pytest` in requirements but no tests written.

**Fix (minimum for PoC):**
- Backend: health check, auth flow, schedule CRUD, stock transaction smoke test
- Mobile: at least verify screens render without crashing
**Effort:** 2-4 hours for basic coverage.

---

### T2. No Error Tracking / Crash Reporting
No Sentry, LogRocket, or Bugsnag configured. Crashes in production are invisible.

**Fix:** Add `sentry-expo` to mobile + `sentry-sdk` to backend. **30 min.**

---

### T3. No Health Check Endpoint
No `/health` or `/ping` endpoint for uptime monitoring.

**Fix:** Add a simple route returning `{"status": "ok", "version": "1.0.0"}`. **2 min.**

---

## 📝 Documentation (1 item)

### Doc1. No README
No README.md explaining how to set up, run, or deploy the project.

**Fix:** Create README with setup instructions, env var documentation, deployment guide. **30 min.**

---

## Deployment Paths

### Path A: Quick Proof of Concept (~30 min)

| # | Step | Time |
|---|---|---|
| 1 | Generate real SECRET_KEY → paste into .env | 1 min |
| 2 | Fix ExportScreen.tsx stale IP (use api.service constant) | 2 min |
| 3 | Run `npx eas init` (adds projectId to app.json) | 2 min |
| 4 | Run `npx eas build --profile preview --platform android` | 15-20 min |
| 5 | Install APK on phone, keep Mac running backend on same WiFi | 2 min |

**Result:** Real APK on your phone. Push notifications work. Google OAuth works (if redirect URI configured). Backend on Mac — both must be on same WiFi.

### Path B: Full Production (~3-4 hours)

| # | Step | Time |
|---|---|---|
| 1 | Create `.gitignore` | 2 min |
| 2 | Fix SECRET_KEY, set DEBUG=False | 2 min |
| 3 | Add `get_current_user` to all routes (S1) | 30 min |
| 4 | Remove/guard test_whatsapp router | 5 min |
| 5 | Fix `datetime.utcnow()` → `datetime.now(timezone.utc)` | 2 min |
| 6 | Fix ExportScreen stale IP | 2 min |
| 7 | Remove dead Celery files + unused npm packages | 5 min |
| 8 | Create `.dockerignore`, fix Dockerfile `--reload` | 2 min |
| 9 | Push backend to GitHub → deploy to Railway/Render | 30 min |
| 10 | Update API_BASE_URL to production URL | 5 min |
| 11 | Update Twilio webhook URL | 5 min |
| 12 | Remove dev bypass from LoginScreen | 1 min |
| 13 | Restrict CORS origins | 2 min |
| 14 | Add app icon and splash screen | 15 min |
| 15 | Add health check endpoint | 2 min |
| 16 | Build APK via EAS | 20 min |
| 17 | End-to-end test on device | 30 min |

**Result:** Self-hosted, secured backend with permanent URL. Distributable APK. All data protected by JWT auth.
