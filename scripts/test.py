#!/usr/bin/env python3
"""Environment test for Codespace data science setup"""
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
            print("✅ R installed")
            # Test if essential packages are available
            try:
                r_test = subprocess.run(['R', '--slave', '-e', 'library(DBI); library(RPostgreSQL)'], 
                                      capture_output=True, timeout=10)
                if r_test.returncode == 0:
                    print("✅ R essential packages available")
                else:
                    print("⚠️ R packages may need installation")
            except:
                print("⚠️ R package test failed")
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
    except:
        print("❌ Database connection failed (setup needed)")
        return False

if __name__ == "__main__":
    print("🧪 Testing Codespace Environment...")
    print("=" * 30)
    
    tests = [test_python, test_r, test_postgresql]
    basic_passed = sum(test() for test in tests)
    
    # Test database connection separately
    print("=" * 30)
    db_working = test_database_connection()
    
    print("=" * 30)
    print(f"✅ {basic_passed}/3 core components working")
    
    if db_working:
        print("✅ Database connection working")
    else:
        print("ℹ️  Database setup will complete during post-start")
    
    print("\n🎯 Environment Status:")
    if basic_passed >= 2:  # Python and PostgreSQL client at minimum
        print("✅ Core tools ready for data science work!")
        if not db_working:
            print("💡 Database will be configured automatically")
    else:
        print("⚠️ Some components need attention - check above for details")
    
    print("\n📊 Database Connection Info:")
    print("   🎯 Username: student")
    print("   🔑 Password: student_password")
    print("   🏠 Host: localhost")
    print("   📚 Database: postgres")
    print("   📖 Full guide: cat DATABASE_PASSWORDS.md")
    
    print("\n📚 Available commands:")
    print("   • python scripts/test_connection.py   - Test database connection")
    print("   • bash scripts/setup_database.sh     - Setup database manually")
    print("   • bash scripts/install_r_packages.sh - Install R packages")
