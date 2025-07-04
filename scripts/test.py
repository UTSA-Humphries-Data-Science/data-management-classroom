#!/usr/bin/env python3
"""Quick classroom test"""
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
            return True
        else:
            print("❌ R issue")
            return False
    except:
        print("❌ R not found")
        return False

def test_postgresql_client():
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

def test_docker():
    try:
        result = subprocess.run(['docker', '--version'], capture_output=True, timeout=5)
        if result.returncode == 0:
            print("✅ Docker available")
            return True
        else:
            print("❌ Docker issue")
            return False
    except:
        print("❌ Docker not found")
        return False

if __name__ == "__main__":
    print("🧪 Testing Environment...")
    print("=" * 30)
    
    tests = [test_python, test_r, test_postgresql_client, test_docker]
    passed = sum(test() for test in tests)
    
    print("=" * 30)
    print(f"✅ {passed}/{len(tests)} tests passed")
    
    print("\n🎯 Next steps:")
    if passed >= 3:  # Python, R, PostgreSQL client
        print("✅ Core tools ready for data analysis!")
        print("💡 To enable database features, choose one:")
        print("   🐳 Docker: bash scripts/start_database.sh")
        print("   🖥️  Local: bash scripts/fix_database_connection.sh (needs admin)")
        print("   ☁️  External: Use cloud database service")
    else:
        print("⚠️ Some components need attention - check above for details")
    
    print("\n📊 Database Password Reference:")
    print("   🐳 Docker: username=student, password=student_password")
    print("   🖥️  Local: username=student, password=(none required)")
    print("   📖 Full guide: cat DATABASE_PASSWORDS.md")
    
    print("\n📚 Available commands:")
    print("   • python scripts/test_connection.py      - Test database connection")
    print("   • bash scripts/start_database.sh         - Start database (Docker)")
    print("   • bash scripts/fix_database_connection.sh - Setup local database")
    print("   • bash scripts/install_r_packages.sh     - Install additional R packages")
