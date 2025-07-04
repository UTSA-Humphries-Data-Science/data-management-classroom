#!/bin/bash

# Post-Start Script - Runs every time the container starts
echo "🔄 Starting data science environment..."

# Navigate to workspace first
cd /workspaces/data-management-classroom 2>/dev/null || cd /workspaces

# Function to check if a service is ready
wait_for_service() {
    local service_name=$1
    local check_command=$2
    local max_wait=${3:-60}
    local wait_time=0
    
    echo "⏳ Waiting for $service_name to be ready..."
    while ! eval "$check_command" &>/dev/null; do
        if [ $wait_time -ge $max_wait ]; then
            echo "⚠️ Timeout waiting for $service_name"
            return 1
        fi
        sleep 5
        wait_time=$((wait_time + 5))
        echo "   ... still waiting ($wait_time/${max_wait}s)"
    done
    echo "✅ $service_name is ready!"
    return 0
}

# Ensure all scripts are executable
chmod +x scripts/*.sh scripts/*.py 2>/dev/null || true

# Check if we're in a GitHub Codespace
if [ -n "$CODESPACE_NAME" ]; then
    echo "📡 Detected GitHub Codespace: $CODESPACE_NAME"
    echo "🔧 Configuring for Codespace environment..."
    
    # Run the Codespace-specific setup script first
    if [ -f ".devcontainer/setup_codespace.sh" ]; then
        echo "🚀 Running Codespace setup script..."
        chmod +x .devcontainer/setup_codespace.sh
        ./.devcontainer/setup_codespace.sh
    else
        echo "⚠️ setup_codespace.sh not found, proceeding with manual setup..."
    fi
    
    # In Codespaces, Docker might not be available, so set up local PostgreSQL
    echo "🗄️ Setting up local PostgreSQL for Codespace..."
    
    # Install PostgreSQL server if not already installed
    if ! command -v postgres &> /dev/null; then
        echo "📦 Installing PostgreSQL server..."
        sudo apt-get update -qq
        sudo apt-get install -y postgresql postgresql-contrib
    fi
    
    # Start PostgreSQL
    echo "🚀 Starting PostgreSQL service..."
    sudo service postgresql start
    
    # Configure PostgreSQL for easy classroom use
    echo "🔧 Configuring PostgreSQL for classroom environment..."
    
    # Create student user and database
    sudo -u postgres psql << 'EOF' 2>/dev/null || true
-- Create student user if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'student') THEN
        CREATE USER student WITH PASSWORD 'student_password';
        ALTER USER student CREATEDB;
        GRANT ALL PRIVILEGES ON DATABASE postgres TO student;
    END IF;
END
$$;

-- Create vscode user if it doesn't exist  
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'vscode') THEN
        CREATE USER vscode WITH PASSWORD 'vscode_password';
        ALTER USER vscode CREATEDB;
        GRANT ALL PRIVILEGES ON DATABASE postgres TO vscode;
    END IF;
END
$$;

-- Create classroom database if it doesn't exist
SELECT 'CREATE DATABASE classroom_db OWNER student' 
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'classroom_db');

\q
EOF

    echo "✅ PostgreSQL configured for classroom use"
    
    # Set up database credentials for Codespace
    cat > ~/.pg_credentials << 'EOF'
export PGUSER=student
export PGPASSWORD=student_password
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=postgres
EOF
    chmod 600 ~/.pg_credentials
    
elif command -v docker &> /dev/null; then
    echo "🐳 Setting up PostgreSQL container..."
    
    # Check if container already exists and is running
    if docker ps | grep -q "classroom-db"; then
        echo "✅ PostgreSQL container already running"
    else
        # Remove any stopped container
        docker rm -f classroom-db 2>/dev/null || true
        
        # Start fresh PostgreSQL container
        echo "🚀 Starting new PostgreSQL container..."
        docker run -d --name classroom-db -p 5432:5432 \
            -e POSTGRES_USER=student \
            -e POSTGRES_PASSWORD=student_password \
            -e POSTGRES_DB=postgres \
            -e POSTGRES_INITDB_ARGS="--auth-host=scram-sha-256 --auth-local=scram-sha-256" \
            postgres:15
        
        # Wait for PostgreSQL to be ready
        if wait_for_service "PostgreSQL" "docker exec classroom-db pg_isready -U student" 120; then
            echo "🎉 PostgreSQL is ready and accepting connections!"
            
            # Load sample data if available
            if [ -f "databases/sample.sql" ]; then
                echo "📊 Loading sample database..."
                docker exec -i classroom-db psql -U student -d postgres < databases/sample.sql 2>/dev/null || true
            fi
        else
            echo "⚠️ PostgreSQL setup may have issues, but continuing..."
        fi
    fi
    
    # Set up database credentials for Docker
    cat > ~/.pg_credentials << 'EOF'
export PGUSER=student
export PGPASSWORD=student_password
export PGHOST=localhost
export PGPORT=5432
export PGDATABASE=postgres
EOF
    chmod 600 ~/.pg_credentials
else
    echo "⚠️ Docker not available, skipping PostgreSQL setup"
    echo "💡 You can still work with Python and R for data analysis"
fi

# Add to bashrc if not already there
if ! grep -q "source ~/.pg_credentials" ~/.bashrc; then
    echo "source ~/.pg_credentials 2>/dev/null || true" >> ~/.bashrc
fi

# Create helpful aliases (only add if not already present)
if ! grep -q "# Data Science Environment Aliases" ~/.bashrc; then
    cat >> ~/.bashrc << 'EOF'

# Data Science Environment Aliases
alias jlab='jupyter lab --ip=0.0.0.0 --port=8888 --no-browser --allow-root'
alias jnb='jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --allow-root'  
alias r-console='R'
alias psql-connect='psql -h localhost -U student -d postgres'
alias workspace='cd /workspaces/data-management-classroom'
alias dbstatus='docker ps | grep classroom-db || echo "No database container running"'
alias dblogs='docker logs classroom-db'
alias dbstart='docker start classroom-db 2>/dev/null || echo "Run setup script first to create database"'
alias dbstop='docker stop classroom-db'
alias testenv='python scripts/test.py'
alias quicktest='python ~/test_environment.py'
EOF
fi

# Run our comprehensive test
echo "🧪 Running environment tests..."
if [ -f "scripts/test.py" ]; then
    python scripts/test.py
else
    echo "⚠️ Test script not found - run setup.sh first"
fi

# Create a quick test script for students
cat > ~/test_environment.py << 'EOF'
#!/usr/bin/env python3
"""Quick environment test for students"""
import sys

print("🧪 Testing Data Science Environment")
print("=" * 40)

# Test Python packages
packages_status = []
try:
    import pandas as pd
    import numpy as np
    print("✅ pandas, numpy: OK")
    packages_status.append(True)
except ImportError as e:
    print(f"❌ pandas/numpy: {e}")
    packages_status.append(False)

try:
    import psycopg2
    print("✅ psycopg2: OK")
    packages_status.append(True)
except ImportError as e:
    print(f"❌ psycopg2: {e}")
    packages_status.append(False)

try:
    import jupyter
    print("✅ jupyter: OK")
    packages_status.append(True)
except ImportError as e:
    print(f"❌ jupyter: {e}")
    packages_status.append(False)

# Test database connection
try:
    import psycopg2
    conn = psycopg2.connect(
        host="localhost",
        database="postgres", 
        user="student",
        password="student_password",
        connect_timeout=5
    )
    conn.close()
    print("✅ Database connection: OK")
    packages_status.append(True)
except Exception as e:
    print(f"❌ Database connection: {e}")
    print("💡 Try: dbstart (to start database)")
    packages_status.append(False)

print("=" * 40)
success_rate = sum(packages_status) / len(packages_status) * 100
print(f"📊 Environment health: {success_rate:.0f}% ({sum(packages_status)}/{len(packages_status)} components)")

if success_rate >= 75:
    print("🎉 Environment is ready for data science work!")
else:
    print("⚠️ Some components need attention - check the setup guide")
EOF

chmod +x ~/test_environment.py

echo ""
echo "🎉 Post-start setup complete!"
echo ""
echo "📋 Environment Status Summary:"
if command -v docker &> /dev/null && docker ps | grep -q classroom-db; then
    echo "   🗄️ Database: ✅ Running"
else
    echo "   🗄️ Database: ⚠️ Not running (use 'dbstart')"
fi

if command -v python3 &> /dev/null; then
    echo "   🐍 Python: ✅ Available"
else
    echo "   🐍 Python: ❌ Missing"
fi

if command -v R &> /dev/null; then
    echo "   📊 R: ✅ Available"
else
    echo "   📊 R: ⚠️ Not installed"
fi

echo ""
echo "🚀 Quick commands for students:"
echo "   testenv        - Run comprehensive environment test"
echo "   quicktest      - Quick environment health check"
echo "   workspace      - Go to main workspace directory"
echo "   psql-connect   - Connect to database"
echo "   dbstatus       - Check database status"
echo "   jlab           - Start Jupyter Lab"
echo ""
echo "� Need help? Check: STUDENT_SETUP_GUIDE.md"
echo "💡 First time? Run: ./devcontainer/setup.sh"

echo ""
echo "📊 Database Connection Info:"
if [ -n "$CODESPACE_NAME" ]; then
    echo "   🎯 Codespace: username=student, password=student_password"
    echo "   📝 Test connection: python scripts/test_connection.py"
else
    echo "   🐳 Docker: username=student, password=student_password"
    echo "   📝 Test connection: python scripts/test_connection.py"
fi
echo "   📖 Full guide: cat DATABASE_PASSWORDS.md"
