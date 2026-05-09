# How to Get Your Supabase Database URL

## Quick Steps

1. **Go to Supabase Dashboard**
   - Visit: https://supabase.com/dashboard
   - Sign in to your account

2. **Select Your Project**
   - Click on your NGO Medicine System project

3. **Navigate to Database Settings**
   - Click the **Settings** icon (⚙️) in the left sidebar
   - Select **Database** from the settings menu

4. **Copy the Connection String**
   - Scroll to the **Connection string** section
   - Click the **URI** tab
   - You'll see something like:
     ```
     postgresql://postgres.[PROJECT-REF]:[YOUR-PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres
     ```
   - **IMPORTANT**: Replace `[YOUR-PASSWORD]` with your actual database password

## Alternative: Use the "Connect" Button

Many Supabase projects have a **Connect** button at the top of the dashboard that shows the connection string directly.

## Example Connection String

Your DATABASE_URL should look like one of these:

```
# Pooler connection (recommended for serverless)
postgresql://postgres.abcdefghijklmnop:[PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres

# Direct connection
postgresql://postgres:[PASSWORD]@db.abcdefghijklmnop.supabase.co:5432/postgres
```

## Update Your .env File

Once you have the connection string:

1. Open `backend/.env`
2. Replace line 4 with your actual connection string:
   ```env
   DATABASE_URL=postgresql://postgres.YOUR_REF:[YOUR_PASSWORD]@aws-0-us-west-1.pooler.supabase.com:6543/postgres
   ```
3. Save the file
4. Run the connection test again:
   ```bash
   cd backend
   python3 test_connection.py
   ```

## Troubleshooting

### "Can't find my password"
If you forgot your database password:
1. Go to Settings → Database
2. Click "Reset database password"
3. Set a new password
4. Update your `.env` file with the new password

### "Connection still fails"
- Make sure there are no spaces in the DATABASE_URL
- Ensure the password doesn't contain special characters that need escaping
- Check that your Supabase project is active (not paused)
- Verify your IP isn't blocked in Supabase settings

## Need Help?

If you're still having trouble, share the error message (without the password!) and I can help debug.
