"""
Database Connection Test Script

This script tests the connection to your Supabase database.
Run this to verify your DATABASE_URL is correct.

Usage:
    python test_connection.py
"""

import os
import sys
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

def test_connection():
    """Test database connection"""
    print("🔍 Testing Supabase Database Connection...")
    print("-" * 50)
    
    # Get database URL
    database_url = os.getenv("DATABASE_URL")
    
    if not database_url:
        print("❌ ERROR: DATABASE_URL not found in .env file")
        print("\n📝 Please update your .env file with:")
        print("DATABASE_URL=postgresql://postgres:[PASSWORD]@db.xxx.supabase.co:5432/postgres")
        return False
    
    # Hide password in output
    safe_url = database_url.replace(database_url.split('@')[0].split(':')[-1], "****")
    print(f"📡 Connecting to: {safe_url}")
    
    try:
        # Create engine
        engine = create_engine(database_url)
        
        # Test connection
        with engine.connect() as connection:
            # Test query
            result = connection.execute(text("SELECT version()"))
            version = result.fetchone()[0]
            
            print("\n✅ Connection successful!")
            print(f"📊 PostgreSQL version: {version[:50]}...")
            
            # Check if tables exist
            result = connection.execute(text("""
                SELECT table_name 
                FROM information_schema.tables 
                WHERE table_schema = 'public'
                ORDER BY table_name
            """))
            
            tables = [row[0] for row in result.fetchall()]
            
            if tables:
                print(f"\n📋 Found {len(tables)} tables:")
                for table in tables:
                    print(f"   - {table}")
            else:
                print("\n⚠️  No tables found. You may need to run the migration script.")
                print("   Check: database/supabase_migration.sql")
            
            return True
            
    except Exception as e:
        print(f"\n❌ Connection failed!")
        print(f"Error: {str(e)}")
        print("\n🔧 Troubleshooting:")
        print("1. Check your DATABASE_URL in .env file")
        print("2. Verify your Supabase password is correct")
        print("3. Ensure your Supabase project is running")
        print("4. Check if your IP is allowed in Supabase settings")
        return False

if __name__ == "__main__":
    success = test_connection()
    sys.exit(0 if success else 1)
