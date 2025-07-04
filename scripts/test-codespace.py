#!/usr/bin/env python3
"""
Simple environment test for Codespace data science setup
"""
import subprocess
import sys

def test_python():
    try:
        import pandas as pd
        import numpy as np
        import psycopg2
        print("✅ Python: pandas, numpy, psycopg2 working")
        return True
    except ImportError as e:
        print(f"❌ Python issue: {e}")
        return False

def test_r():
    try:
        result = subprocess.run(['R', '--version'], capture_output=True, timeout=5)
        if result.returncode == 0:
            print("✅ R installed and ready")
            return True
        else:
            print("❌ R issue")
            return False
    except:
        print("❌ R not found")
        return False

def test_postgresql():
    try:
        result = subprocess.run(['psql', '--version'], capture_output=True, timeout=5)
        if result.returncode == 0:
            print("✅ PostgreSQL client ready")
            return True
        else:
            print("❌ PostgreSQL client issue")
            return False
    except:
        print("❌ PostgreSQL client not found")
        return False

def test_database_connection():
    """Test if we can connect to the database"""
    try:
        import psycopg2
        conn = psycopg2.connect(
            host="localhost",
            database="postgres", 
            user="student",
            password="student_password",
            port="5432",
            connect_timeout=3
        )
        conn.close()
        print("✅ Database connection working")
        return True
    except Exception as e:
        print("❌ Database connection failed")
        return False

if __name__ == "__main__":
    print("🧪 Testing Codespace Environment...")
    print("=" * 35)
    
    tests = [test_python, test_r, test_postgresql]
    basic_passed = sum(test() for test in tests)
    
    # Test database connection separately
    print("=" * 35)
    db_working = test_database_connection()
    
    print("=" * 35)
    print(f"📊 Core components: {basic_passed}/3 working")
    
    if db_working:
        print("📊 Database: ✅ Connected")
    else:
        print("📊 Database: ❌ Not connected")
    
    print("\n🎯 Environment Status:")
    if basic_passed >= 2 and db_working:
        print("🎉 Environment is ready for data science work!")
    elif basic_passed >= 2:
        print("⚠️ Core tools ready, database needs setup")
        print("💡 Try: python scripts/test_connection.py")
    else:
        print("❌ Some components need attention")
    
    print("\n📊 Database Connection Info:")
    print("   🎯 Username: student")
    print("   🔑 Password: student_password")
    print("   🏠 Host: localhost")
    print("   📚 Database: postgres")
    print("   📖 Full guide: cat DATABASE_PASSWORDS.md")
    
    print("\n🚀 Available commands:")
    print("   • python scripts/test_connection.py - Test database connection")
    print("   • bash scripts/setup_database.sh   - Setup database manually")
    print("   • jlab                             - Start Jupyter Lab")
    print("   • psql-connect                     - Connect to database")
    
    if basic_passed >= 2 and db_working:
        sys.exit(0)
    else:
        sys.exit(1)
