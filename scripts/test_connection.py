#!/usr/bin/env python3
"""Test database connection"""
import psycopg2
import sys
import subprocess
import time

def check_docker_container():
    """Check if PostgreSQL container is running"""
    try:
        result = subprocess.run(['docker', 'ps'], capture_output=True, text=True, timeout=10)
        if 'classroom-db' in result.stdout or 'postgres' in result.stdout:
            return True
        return False
    except:
        return False

def start_postgres_container():
    """Try to start PostgreSQL container"""
    try:
        print("🚀 Attempting to start PostgreSQL container...")
        cmd = [
            'docker', 'run', '-d', 
            '--name', 'classroom-db',
            '-p', '5432:5432',
            '-e', 'POSTGRES_USER=student',
            '-e', 'POSTGRES_PASSWORD=student_password',
            '-e', 'POSTGRES_DB=postgres',
            'postgres:15'
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        
        if result.returncode == 0:
            print("✅ PostgreSQL container started successfully")
            print("⏳ Waiting for database to be ready...")
            time.sleep(10)  # Give the database time to start
            return True
        else:
            print(f"❌ Failed to start container: {result.stderr}")
            return False
    except Exception as e:
        print(f"❌ Error starting container: {e}")
        return False

def test_connection():
    """Test database connection with multiple credential attempts"""
    
    # Connection attempts to try
    attempts = [
        {
            "name": "Docker setup (student with password)",
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
            "name": "Peer authentication (current user)",
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

if __name__ == "__main__":
    print("🧪 Testing Database Connection...")
    print("=" * 40)
    
    # First check if we can connect
    if test_connection():
        sys.exit(0)
    
    # If connection failed, check if container is running
    print("\n🔍 Checking for running PostgreSQL container...")
    if not check_docker_container():
        print("❌ No PostgreSQL container found")
        
        # Try to start container if docker is available
        try:
            subprocess.run(['docker', '--version'], capture_output=True, timeout=5)
            if start_postgres_container():
                if test_connection():
                    sys.exit(0)
        except:
            print("❌ Docker not available")
    
    print("\n💡 Database connection failed. Here are your options:")
    print("\n🐳 Option 1: Docker Database (Recommended)")
    print("   docker run -d --name classroom-db -p 5432:5432 \\")
    print("     -e POSTGRES_USER=student -e POSTGRES_PASSWORD=student_password \\")
    print("     -e POSTGRES_DB=postgres postgres:15")
    print("   Then test: python scripts/test_connection.py")
    
    print("\n🖥️  Option 2: Local PostgreSQL (if you have admin access)")
    print("   bash scripts/fix_database_connection.sh")
    
    print("\n☁️  Option 3: External Database")
    print("   - Use a cloud database (AWS RDS, Google Cloud SQL, etc.)")
    print("   - Update connection details in scripts")
    
    print("\n📊 Current Password Setup:")
    print("   🐳 Docker: username=student, password=student_password")
    print("   🖥️  Local: username=student, password=(none - trust authentication)")
    print("   ☁️  External: Use your cloud provider's credentials")
    
    sys.exit(1)
