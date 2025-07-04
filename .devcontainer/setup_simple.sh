#!/bin/bash

echo "⚡ Codespace-Optimized Data Science Setup"
echo "Getting essentials working for GitHub Classroom environment"

# Set non-interactive mode
export DEBIAN_FRONTEND=noninteractive
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Function to safely install packages
safe_install() {
    echo "📦 Installing: $*"
    sudo apt-get update -qq >/dev/null 2>&1
    sudo apt-get install -y "$@" >/dev/null 2>&1 || {
        echo "⚠️ Failed to install: $*"
        return 1
    }
    echo "✅ Installed: $*"
}

# Install essential packages
echo "🗄️ Installing PostgreSQL and Python essentials..."
safe_install postgresql postgresql-contrib python3-pip

# Configure PostgreSQL for local development
echo "🔧 Configuring PostgreSQL..."

# Start PostgreSQL service
if sudo service postgresql start >/dev/null 2>&1; then
    echo "✅ PostgreSQL service started"
    
    # Wait for PostgreSQL to be ready
    sleep 2
    
    # Configure pg_hba.conf for local development (trust authentication)
    sudo bash -c 'cd /etc/postgresql/*/main/ && cp pg_hba.conf pg_hba.conf.backup 2>/dev/null || true'
    sudo bash -c 'cd /etc/postgresql/*/main/ && cat > pg_hba.conf << '\''EOF'\''
# PostgreSQL Client Authentication Configuration File
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
EOF'
    
    # Reload PostgreSQL configuration
    sudo service postgresql reload >/dev/null 2>&1
    
    # Create development user and database (non-interactive)
    if psql -h localhost -U postgres -d postgres -tAc "SELECT 1 FROM pg_roles WHERE rolname='vscode'" | grep -q 1; then
        echo "ℹ️ User 'vscode' already exists"
    else
        psql -h localhost -U postgres -d postgres -c "CREATE USER vscode WITH CREATEDB CREATEROLE SUPERUSER;" >/dev/null 2>&1 && echo "✅ Created PostgreSQL user 'vscode'"
    fi
    
    if psql -h localhost -U postgres -d postgres -lqt | cut -d \| -f 1 | grep -qw vscode; then
        echo "ℹ️ Database 'vscode' already exists"
    else
        psql -h localhost -U postgres -d postgres -c "CREATE DATABASE vscode OWNER vscode;" >/dev/null 2>&1 && echo "✅ Created PostgreSQL database 'vscode'"
    fi
    
    echo "✅ PostgreSQL configured for passwordless local development"
else
    echo "⚠️ PostgreSQL service failed to start, continuing without database"
fi

# Install R (optional, skip if fails)
echo "📊 Installing R..."
if safe_install r-base r-base-dev; then
    echo "✅ R installed successfully"
else
    echo "⚠️ R installation skipped"
fi

# Install Python packages (excluding jupyter since we're using VS Code)
echo "🐍 Installing Python packages..."
pip install --user --no-cache-dir psycopg2-binary pandas numpy matplotlib seaborn scikit-learn ipykernel sqlalchemy >/dev/null 2>&1 || echo "⚠️ Some Python packages may have issues"

# Create workspace directories
echo "📁 Creating workspace structure..."
mkdir -p /workspaces/data-management-classroom/{notebooks,scripts,databases,data/{raw,processed},labs,assignments,projects,personal,shared-data}

# Set up environment variables permanently
echo "🌍 Setting up environment variables..."
cat >> ~/.bashrc << 'ENV_EOF'

# PostgreSQL environment variables for data management classroom
export PGDATABASE=vscode
export PGUSER=vscode
export PGHOST=localhost
export PGPORT=5432

# Python path for user packages
export PATH="$HOME/.local/bin:$PATH"
ENV_EOF

# Create .pgpass file for passwordless connections (backup method)
echo "🔐 Setting up PostgreSQL credentials..."
echo "localhost:5432:*:vscode:" > ~/.pgpass
chmod 600 ~/.pgpass

# Install additional useful tools
echo "🔧 Installing additional development tools..."
safe_install git-lfs htop tree jq curl wget

# Create simple test script
cat > /workspaces/data-management-classroom/scripts/test_setup.py << 'EOF'
#!/usr/bin/env python3
"""Quick test to verify environment setup"""

def test_imports():
    """Test if essential packages can be imported"""
    try:
        import pandas as pd
        import numpy as np
        import psycopg2
        import matplotlib.pyplot as plt
        import seaborn as sns
        import sklearn
        import sqlalchemy
        print("✅ Python packages: pandas, numpy, psycopg2, matplotlib, seaborn, sklearn, sqlalchemy")
        return True
    except ImportError as e:
        print(f"❌ Python import error: {e}")
        return False

def test_database():
    """Test database connection"""
    try:
        import psycopg2
        conn = psycopg2.connect(
            host="localhost",
            database="vscode", 
            user="vscode"
        )
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print(f"✅ Database connection: {version[:50]}...")
        conn.close()
        return True
    except Exception as e:
        print(f"❌ Database connection failed: {e}")
        return False

def test_r():
    """Test if R is available"""
    import subprocess
    try:
        result = subprocess.run(['R', '--version'], capture_output=True, text=True, timeout=5)
        if result.returncode == 0:
            print("✅ R is available")
            return True
    except:
        pass
    print("⚠️ R not available")
    return False

if __name__ == "__main__":
    print("🧪 Testing environment setup...")
    imports_ok = test_imports()
    db_ok = test_database() 
    r_ok = test_r()
    
    print("\n📊 Test Summary:")
    print(f"  Python packages: {'✅' if imports_ok else '❌'}")
    print(f"  Database: {'✅' if db_ok else '❌'}")
    print(f"  R: {'✅' if r_ok else '⚠️'}")
    
    if imports_ok and db_ok:
        print("🎉 Environment setup successful!")
    else:
        print("⚠️ Some components need attention")
EOF

chmod +x /workspaces/data-management-classroom/scripts/test_setup.py

echo "✅ Codespace setup complete!"
echo "🧪 Run 'python scripts/test_setup.py' to verify installation"
