#!/usr/bin/env python3
"""Test database connection for Codespace environment"""
import psycopg2
import sys
import subprocess
import time

def test_connection():
    """Test database connection with multiple credential attempts"""
    
    # Connection attempts to try
    attempts = [
        {
            "name": "Codespace setup (student with password)",
            "params": {
                "host": "localhost",
                "database": "postgres",
                "user": "student", 
                "password": "student_password",
                "port": "5432",
                "connect_timeout": 5
            }
        },
        {
            "name": "Local setup (student without password)",
            "params": {
                "host": "localhost",
                "database": "postgres",
                "user": "student",
                "port": "5432",
                "connect_timeout": 5
            }
        },
        {
            "name": "Current user authentication",
            "params": {
                "database": "postgres",
                "user": "vscode",
                "port": "5432",
                "connect_timeout": 5
            }
        }
    ]
    
    for attempt in attempts:
        try:
            print(f"🔍 Trying: {attempt['name']}")
            conn = psycopg2.connect(**attempt['params'])
            cursor = conn.cursor()
            cursor.execute("SELECT version();")
            version = cursor.fetchone()
            print(f"✅ Connected via {attempt['name']}: {version[0]}")
            cursor.close()
            conn.close()
            return True
        except Exception as e:
            print(f"❌ {attempt['name']} failed: {e}")
    
    return False

def check_postgres_service():
    """Check if PostgreSQL service is running"""
    try:
        result = subprocess.run(['sudo', 'service', 'postgresql', 'status'], 
                              capture_output=True, text=True, timeout=10)
        return 'online' in result.stdout
    except:
        return False

if __name__ == "__main__":
    print("🧪 Testing Database Connection...")
    print("=" * 40)
    
    # Check if PostgreSQL is running
    if not check_postgres_service():
        print("⚠️ PostgreSQL service not running. Starting it...")
        try:
            subprocess.run(['sudo', 'service', 'postgresql', 'start'], timeout=30)
            time.sleep(3)
        except:
            pass
    
    # Test the connection
    if test_connection():
        print("\n🎉 Database connection successful!")
        print("\n📊 Connection details:")
        print("   Host: localhost")
        print("   Database: postgres")
        print("   Username: student")
        print("   Password: student_password")
        sys.exit(0)
    else:
        print("\n❌ Database connection failed")
        print("\n💡 The database will be configured during post-start setup")
        print("   This is normal during initial container creation")
        print("\n🔧 To manually configure, run:")
        print("   bash scripts/setup_database.sh")
        sys.exit(1)
