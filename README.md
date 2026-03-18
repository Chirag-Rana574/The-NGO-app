# NGO Medicine Administration Management System

Production-grade medicine administration management system with WhatsApp integration for field workers and React Native mobile app for supervisors.

## 🎯 System Overview

This system manages medicine administration tasks with:
- **WhatsApp-only interaction** for field workers (no app required)
- **React Native mobile app** for supervisors
- **Deterministic state machine** for task tracking
- **Full audit logging** for compliance
- **Strict stock accounting** via transaction history
- **Zero ambiguity** in worker response handling

## 📋 Core Features

### For Workers (WhatsApp Only)
- Receive reminders via WhatsApp
- Reply with simple digits:
  - `1` = Task completed
  - `2` = Task not done
- No app installation required

### For Supervisors (Mobile App)
- View today's tasks with color-coded status
- Create and manage schedules
- Monitor medicine stock levels
- Manual stock adjustments
- View complete audit trail
- Large touch targets for ease of use

### System Capabilities
- Automatic reminder sending
- Time window validation (on-time vs late responses)
- Automatic task expiration
- Low stock alerts
- Idempotent webhook processing
- Master password override for locked schedules

## 🏗️ Architecture

### Backend Stack
- **FastAPI** - REST API
- **PostgreSQL** - Database
- **SQLAlchemy** - ORM
- **Alembic** - Migrations
- **Celery** - Background tasks
- **Redis** - Task queue
- **Twilio** - WhatsApp integration

### Mobile Stack
- **React Native** - Cross-platform mobile
- **React Navigation** - Navigation
- **Axios** - API client
- **TypeScript** - Type safety

## 🚀 Quick Start

### Prerequisites
- Docker & Docker Compose
- Node.js 18+ (for mobile app)
- Twilio account with WhatsApp enabled

### 1. Clone and Setup

```bash
git clone <repository-url>
cd ngo-medicine-system
```

### 2. Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and set:
- Database credentials
- Twilio credentials (Account SID, Auth Token, WhatsApp number)
- Master password hash (use bcrypt)
- Time window settings

### 3. Start Backend Services

```bash
docker-compose up -d
```

This starts:
- PostgreSQL database
- Redis
- FastAPI backend (port 8000)
- Celery worker
- Celery beat scheduler

### 4. Run Database Migrations

```bash
docker-compose exec backend alembic upgrade head
```

### 5. Setup Mobile App

```bash
cd mobile
npm install

# For iOS
npx pod-install
npm run ios

# For Android
npm run android
```

## 📱 Mobile App Usage

### Main Screens

1. **Home** - Today's tasks with status indicators
2. **Medicines** - Stock levels and manual adjustments
3. **Audit Log** - Complete system audit trail

### Creating a Schedule

1. Tap "+ Add Task" on Home screen
2. Select worker
3. Select medicine
4. Set date and time
5. Set dose amount
6. Submit

### Adjusting Stock

1. Go to Medicines screen
2. Tap "Adjust Stock" on any medicine
3. Enter amount (+ to add, - to remove)
4. Enter reason
5. Submit

## 🔧 Configuration

### Time Windows

Set in `.env`:
```bash
RESPONSE_WINDOW_MINUTES=60      # Worker has 60 min to respond
EXPIRY_CUTOFF_HOURS=24          # Task expires after 24 hours
REMINDER_ADVANCE_MINUTES=15     # Reminder sent 15 min before task
```

### Stock Alerts

```bash
LOW_STOCK_THRESHOLD=10          # Alert when stock falls below 10
```

### Master Password

Generate bcrypt hash:
```python
import bcrypt
password = b"YourSecurePassword123!"
hashed = bcrypt.hashpw(password, bcrypt.gensalt())
print(hashed.decode())
```

Add to `.env`:
```bash
MASTER_PASSWORD_HASH=<your-bcrypt-hash>
```

## 📊 State Machine

```
CREATED
  ↓
REMINDER_SENT (reminder sent via WhatsApp)
  ↓
AWAITING_RESPONSE (at scheduled time)
  ↓
  ├─→ COMPLETED (worker replied "1" on time)
  ├─→ LATE_COMPLETED (worker replied "1" late)
  ├─→ NOT_DONE (worker replied "2")
  └─→ EXPIRED (no response by expiry cutoff)
```

**Rules:**
- Transitions are forward-only
- No state skipping allowed
- All transitions logged in audit trail

## 🔐 Security Features

### Schedule Editing Lock
- Schedules cannot be edited within 24 hours of scheduled time
- Override requires master password + reason
- All overrides logged

### Stock Protection
- Stock can never go negative
- All changes via StockTransaction records
- No direct stock modification allowed

### Audit Trail
- All state transitions logged
- All stock changes logged
- All override actions logged
- Logs are immutable

## 🌐 WhatsApp Integration

### Twilio Setup

1. Create Twilio account
2. Enable WhatsApp sandbox (development) or get approved number (production)
3. Set webhook URL: `https://your-domain.com/api/whatsapp/webhook`
4. Add credentials to `.env`

### Webhook Processing

The system:
1. Normalizes phone numbers to E.164 format
2. Extracts first digit from message
3. Validates worker and active schedule
4. Checks time windows
5. Processes response (consume stock if completed)
6. Updates state machine
7. Logs all actions

### Idempotency

Uses Twilio's `MessageSid` to prevent duplicate processing.

## 🧪 Testing

### Backend Tests

```bash
cd backend
pytest tests/ -v --cov=app
```

### Test Scenarios

1. **State Machine**: Verify transitions cannot be skipped
2. **Stock Accounting**: Verify stock never goes negative
3. **Webhook**: Test idempotency and time windows
4. **WhatsApp**: Send test messages to sandbox

## 📈 Monitoring

### Health Checks

```bash
curl http://localhost:8000/health
```

### Logs

```bash
# Backend logs
docker-compose logs -f backend

# Celery worker logs
docker-compose logs -f celery_worker

# Celery beat logs
docker-compose logs -f celery_beat
```

### Database

```bash
docker-compose exec db psql -U ngo_user -d ngo_medicine_db
```

## 🚨 Troubleshooting

### Workers not receiving reminders
- Check Celery beat is running
- Verify Twilio credentials
- Check worker phone numbers are in E.164 format

### Stock went negative
- This should never happen due to constraints
- Check StockTransaction history
- Run integrity verification

### Schedule stuck in AWAITING_RESPONSE
- Check expiry job is running
- Verify time window settings
- Check audit log for state transitions

## 📝 API Documentation

Once running, visit:
```
http://localhost:8000/docs
```

For interactive API documentation (Swagger UI).

## 🔄 Backup & Recovery

### Database Backup

```bash
docker-compose exec db pg_dump -U ngo_user ngo_medicine_db > backup.sql
```

### Restore

```bash
docker-compose exec -T db psql -U ngo_user ngo_medicine_db < backup.sql
```

## 📞 Support

For issues or questions:
1. Check logs for error messages
2. Verify configuration in `.env`
3. Review audit logs for system actions
4. Check Twilio dashboard for WhatsApp delivery status

## 📄 License

[Your License Here]

## 🙏 Acknowledgments

Built for NGO field operations with reliability and simplicity as top priorities.
