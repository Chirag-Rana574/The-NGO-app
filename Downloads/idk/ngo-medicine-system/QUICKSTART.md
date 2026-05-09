# Quick Start Guide - NGO Medicine System

## Running the Real Application

### Prerequisites

- Python 3.8+ installed
- Node.js 16+ and npm installed
- Supabase account with database set up
- Expo CLI (for mobile app)

## Backend Setup (5 minutes)

### 1. Navigate to Backend

```bash
cd /Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/backend
```

### 2. Install Dependencies

```bash
pip install -r requirements.txt
```

### 3. Configure Environment

Create or update `.env` file:

```env
# Database (from Supabase)
DATABASE_URL=postgresql://postgres:[YOUR-PASSWORD]@db.xxx.supabase.co:5432/postgres

# Medicine Management Passkey
MEDICINE_PASSKEY=1234

# Optional: Twilio for SMS
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=your_twilio_number
```

### 4. Start Backend Server

```bash
uvicorn app.main:app --reload
```

✅ Backend running at: **http://localhost:8000**  
📚 API Docs at: **http://localhost:8000/docs**

## Mobile App Setup (5 minutes)

### 1. Navigate to Mobile

```bash
cd /Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/mobile
```

### 2. Install Dependencies

```bash
npm install
```

### 3. Configure API Endpoint

Update `mobile/src/services/api.service.ts` if needed:

```typescript
// Change this if backend is on different host
private baseURL = 'http://localhost:8000/api';
```

### 4. Start Mobile App

```bash
npm start
```

This will:
- Start Expo Dev Server
- Show QR code in terminal
- Open Expo DevTools in browser

### 5. Run on Device/Simulator

**iOS Simulator:**
```bash
# Press 'i' in terminal
```

**Android Emulator:**
```bash
# Press 'a' in terminal
```

**Physical Device:**
1. Install "Expo Go" app from App Store/Play Store
2. Scan QR code with camera (iOS) or Expo Go app (Android)

## Database Setup

### Option A: Fresh Database

Run in Supabase SQL Editor:
```bash
database/supabase_migration.sql
```

### Option B: Migrate Existing Database

1. Read [`DATABASE_MIGRATION.md`](file:///Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/DATABASE_MIGRATION.md)
2. Run `database/migration_existing_db.sql`
3. Add worker data manually
4. Update schedule references

## Testing the App

### 1. Test Backend API

Visit http://localhost:8000/docs

Try these endpoints:
- `GET /api/patients` - List patients
- `GET /api/workers` - List workers
- `GET /api/medicines` - List medicines
- `GET /api/schedules` - List schedules

### 2. Test Mobile App

Navigate through:
1. **Home Screen** - See today's schedules and 2x2 grid
2. **Patients Tab** - Add/edit patients (name only)
3. **Workers Tab** - Add/edit workers (name + mobile)
4. **Stock Tab** - Manage medicine inventory
5. **Schedules Tab** - View calendar and create schedules

### 3. Create a Test Schedule

1. Tap "Schedules" tab
2. Tap "+" button
3. Select:
   - Patient (who receives medicine)
   - Worker (who administers it)
   - Medicine
   - Time
4. Save
5. Check it appears on Home screen

## Troubleshooting

### Backend Won't Start

**Error: "No module named 'fastapi'"**
```bash
pip install -r requirements.txt
```

**Error: "Connection refused"**
- Check DATABASE_URL in `.env`
- Verify Supabase database is running
- Test connection in Supabase dashboard

### Mobile App Issues

**Error: "Network request failed"**
- Ensure backend is running on http://localhost:8000
- Check `api.service.ts` has correct baseURL
- If using physical device, use computer's IP instead of localhost

**Expo won't start**
```bash
npm install -g expo-cli
npm install
```

### Database Issues

**Tables don't exist**
- Run migration script in Supabase SQL Editor
- Check for errors in query results

**Foreign key violations**
- Ensure patients and workers exist before creating schedules
- Check migration completed successfully

## Project Structure

```
ngo-medicine-system/
├── backend/
│   ├── app/
│   │   ├── main.py          # FastAPI app
│   │   ├── models.py        # Database models
│   │   ├── schemas.py       # Pydantic schemas
│   │   └── routers/         # API endpoints
│   │       ├── patients.py  # Patient CRUD
│   │       ├── workers.py   # Worker CRUD
│   │       ├── medicines.py # Medicine CRUD
│   │       └── schedules.py # Schedule management
│   └── .env                 # Configuration
├── mobile/
│   ├── App.tsx              # Navigation setup
│   └── src/
│       ├── screens/         # UI screens
│       │   ├── HomeScreen.tsx
│       │   ├── PatientsScreen.tsx
│       │   ├── WorkersScreen.tsx
│       │   ├── MedicinesScreen.tsx
│       │   └── SchedulesScreen.tsx
│       ├── services/        # API calls
│       └── types/           # TypeScript types
└── database/
    ├── supabase_migration.sql      # Fresh setup
    └── migration_existing_db.sql   # Migrate existing
```

## Key Features

### Patients Management
- Name only (no phone number)
- Add, edit, delete
- Soft delete support

### Workers Management
- Name + mobile number
- Phone number validation
- Unique mobile numbers

### Schedule Management
- Links patient + worker + medicine
- Time-based scheduling
- Status tracking (CREATED, SENT, CONFIRMED, COMPLETED)
- Override support with master password

### Medicine Stock
- Track inventory
- Automatic stock updates
- Low stock warnings

### Audit Logging
- All CRUD operations logged
- Track who did what when
- Soft delete tracking

## Next Steps

1. ✅ Backend running
2. ✅ Mobile app running
3. ✅ Database migrated
4. 🔄 Add sample data
5. 🔄 Test complete flow
6. 🔄 Configure Twilio for SMS (optional)
7. 🔄 Deploy to production

## Production Deployment

### Backend
- Deploy to Heroku, Railway, or DigitalOcean
- Set environment variables
- Enable HTTPS

### Mobile App
- Build with `expo build:ios` or `expo build:android`
- Submit to App Store / Play Store
- Or use Expo's OTA updates

### Database
- Supabase handles scaling automatically
- Enable Row Level Security (RLS)
- Set up regular backups

## Support

- 📖 [Full Walkthrough](file:///Users/chiragrana/.gemini/antigravity/brain/72fb5d89-eadf-40e9-910f-3593c39e416a/walkthrough.md)
- 🗄️ [Database Migration Guide](file:///Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/DATABASE_MIGRATION.md)
- 🔧 [Supabase Setup](file:///Users/chiragrana/.gemini/antigravity/scratch/ngo-medicine-system/SUPABASE_SETUP.md)
