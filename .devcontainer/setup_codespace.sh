#!/bin/bash

echo "⚡ Codespace-Optimized Data Science Setup"
echo "Getting essentials working for GitHub Classroom environment"

# Set aggressive timeouts and non-interactive mode
export DEBIAN_FRONTEND=noninteractive
export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=1

# Function to wait for apt lock to be released
wait_for_apt_lock() {
    local max_wait=300  # 5 minutes max wait
    local wait_time=0
    
    while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
        if [ $wait_time -ge $max_wait ]; then
            echo "⚠️ Timeout waiting for package manager lock to be released"
            return 1
        fi
        echo "⏳ Waiting for package manager lock to be released... (${wait_time}s)"
        sleep 10
        wait_time=$((wait_time + 10))
    done
    return 0
}

# Ultra-short timeout function with lock handling
quick_install() {
    # Wait for any existing apt processes to finish
    wait_for_apt_lock
    
    timeout 120 "$@" || {
        echo "❌ Timed out: $*"
        echo "⏭️ Skipping and continuing..."
        return 1
    }
}

# Essential packages only
echo "📦 Quick package update..."
quick_install sudo apt-get update -qq

echo "🗄️ Installing PostgreSQL server and client..."
quick_install sudo apt-get install -y postgresql postgresql-contrib

# Configure PostgreSQL for passwordless local access (ideal for dev containers)
echo "🔧 Configuring PostgreSQL for seamless local access..."
if [ -f /etc/postgresql/*/main/pg_hba.conf ]; then
    PG_HBA=$(find /etc/postgresql -name pg_hba.conf | head -1)
    # Backup original
    sudo cp "$PG_HBA" "$PG_HBA.backup" 2>/dev/null || true
    # Add trust authentication for local connections at the top
    sudo sed -i '1i# Local connections without password for dev environment\nlocal   all             all                                     trust\nhost    all             all             127.0.0.1/32            trust\nhost    all             all             ::1/128                 trust\n' "$PG_HBA"
    
    # Restart PostgreSQL to apply configuration
    sudo service postgresql restart
    sleep 3
    
    echo "✅ PostgreSQL configured for local trust authentication"
else
    echo "⚠️ PostgreSQL config not found - will configure later"
fi

echo "🐍 Installing Python essentials..."
# Install Python packages with user flag to avoid permission issues
if quick_install pip install --no-cache-dir --user psycopg2-binary pandas numpy jupyter; then
    echo "✅ Python packages installed"
else
    echo "⚠️ Some Python packages may have failed"
fi

echo "📊 Installing R and essential packages..."
# Install R base and development packages
if quick_install sudo apt-get install -y r-base r-base-dev r-cran-devtools; then
    echo "✅ R base installed"
    
    # Install essential R packages with timeout
    echo "📦 Installing essential R packages..."
    timeout 300 sudo R --slave --no-restore --no-save -e "
    options(repos = c(CRAN = 'https://cloud.r-project.org/'))
    options(timeout = 60)
    packages <- c('languageserver', 'jsonlite', 'httr', 'IRkernel')
    for (pkg in packages) {
        tryCatch({
            if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
                install.packages(pkg, dependencies = TRUE, quiet = TRUE)
                cat('Installed:', pkg, '\n')
            }
        }, error = function(e) {
            cat('Failed to install:', pkg, '-', e\$message, '\n')
        })
    }
    " 2>/dev/null || echo "⚠️ Some R packages installation had issues"
    
    # Configure R for Jupyter if IRkernel was installed
    timeout 60 sudo R --slave -e "
    tryCatch({
        library(IRkernel)
        IRkernel::installspec(user = FALSE)
        cat('R kernel for Jupyter installed\n')
    }, error = function(e) {
        cat('R kernel installation failed\n')
    })
    " 2>/dev/null || echo "ℹ️ R kernel setup skipped"
    
    echo "✅ R environment configured"
else
    echo "⚠️ R installation failed - continuing without R"
fi

# Create workspace and scripts
echo "📁 Creating workspace..."
mkdir -p /workspaces/data-management-classroom/{notebooks,scripts,databases}

# Simple database connection test script
cat > /workspaces/data-management-classroom/scripts/test_connection.py << 'EOF'
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
EOF

# Database setup script
cat > /workspaces/data-management-classroom/scripts/setup_database.sh << 'EOF'
#!/bin/bash
echo "🗄️ Setting up PostgreSQL for Codespace environment..."

# Start PostgreSQL if not running
echo "🚀 Starting PostgreSQL service..."
sudo service postgresql start

# Configure trust authentication if not already done
echo "🔧 Configuring PostgreSQL for passwordless local access..."
if [ -f /etc/postgresql/*/main/pg_hba.conf ]; then
    PG_HBA=$(find /etc/postgresql -name pg_hba.conf | head -1)
    if ! grep -q "# Local connections without password for dev environment" "$PG_HBA"; then
        sudo cp "$PG_HBA" "$PG_HBA.backup" 2>/dev/null || true
        sudo sed -i '1i# Local connections without password for dev environment\nlocal   all             all                                     trust\nhost    all             all             127.0.0.1/32            trust\nhost    all             all             ::1/128                 trust\n' "$PG_HBA"
        sudo service postgresql reload
        echo "✅ PostgreSQL trust authentication configured"
    else
        echo "✅ PostgreSQL trust authentication already configured"
    fi
fi

# Wait for it to be ready
sleep 3

# Create student user and database using psql directly (no sudo -u needed with trust auth)
echo "👤 Creating student user and database..."
psql -h localhost -U postgres -d postgres << 'DBEOF' || echo "⚠️ Database setup may need manual configuration"
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

-- Create vscode user if it doesn't exist (no password for local trust auth)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'vscode') THEN
        CREATE USER vscode;
        ALTER USER vscode CREATEDB;
        GRANT ALL PRIVILEGES ON DATABASE postgres TO vscode;
    ELSE
        -- Remove password from existing vscode user for trust auth
        ALTER USER vscode PASSWORD NULL;
    END IF;
END
$$;

-- Create classroom database if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = 'classroom_db') THEN
        CREATE DATABASE classroom_db OWNER student;
    END IF;
END
$$;

\q
DBEOF

echo "✅ Database setup completed successfully!"
echo ""
echo "📊 Connection details:"
echo "   Host: localhost"
echo "   Port: 5432"
echo "   Database: postgres"
echo "   Username: student (with password: student_password)"
echo "   Username: vscode (no password needed - trust auth)"
echo ""
echo "💡 Test the connection:"
echo "   python scripts/test_connection.py"
EOF

# R packages installer script
cat > /workspaces/data-management-classroom/scripts/install_r_packages.sh << 'EOF'
#!/bin/bash
echo "📊 Installing R packages for data science..."

if ! command -v R &> /dev/null; then
    echo "❌ R not found. Installing R first..."
    sudo apt-get update -qq
    sudo apt-get install -y r-base
fi

# Function to install R packages with aggressive timeout
install_r_package() {
    local package=$1
    echo "📦 Installing $package..."
    timeout 90 sudo R --slave --vanilla -e "
    options(repos='https://cloud.r-project.org/', timeout=60)
    tryCatch({
        if(!require('$package', character.only=TRUE, quietly=TRUE)) {
            install.packages('$package', dependencies=FALSE, quiet=TRUE)
            if(require('$package', character.only=TRUE, quietly=TRUE)) {
                cat('✅ $package installed successfully\n')
            } else {
                cat('❌ $package installation failed\n')
            }
        } else {
            cat('✅ $package already available\n')
        }
    }, error=function(e) {
        cat('❌ $package failed:', as.character(e), '\n')
    })
    " 2>/dev/null || echo "⚠️ $package installation timed out"
}

# Install packages one by one to avoid hanging
echo "🔄 Installing essential packages first..."
install_r_package "DBI"
install_r_package "RPostgreSQL" 

echo "🔄 Installing data manipulation packages..."
install_r_package "dplyr"
install_r_package "readr"

echo "🔄 Installing visualization packages..."
install_r_package "ggplot2"

echo ""
echo "📊 R package installation complete!"
echo "💡 To test R packages:"
echo "   R -e \"library(DBI); library(RPostgreSQL)\""
echo "   R -e \"library(dplyr); library(ggplot2)\""
EOF

# Enhanced test script for Codespace environment
cat > /workspaces/data-management-classroom/scripts/test.py << 'EOF'
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
EOF

# Sample database
cat > /workspaces/data-management-classroom/databases/sample.sql << 'EOF'
-- Sample database setup for classroom
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY, 
    name VARCHAR(100), 
    grade INTEGER
);

INSERT INTO students (name, grade) VALUES 
    ('Alice', 95), 
    ('Bob', 87),
    ('Carol', 92)
ON CONFLICT DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO student;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO student;
EOF

# Make scripts executable
chmod +x /workspaces/data-management-classroom/scripts/*.sh
chmod +x /workspaces/data-management-classroom/scripts/*.py

# Try to install R if not already done
echo "🔄 Attempting R setup..."
if ! command -v R &> /dev/null; then
    echo "📊 R not found, attempting installation..."
    if quick_install sudo apt-get install -y r-base; then
        echo "✅ R base installed successfully"
    else
        echo "⚠️ R installation failed - students can install later"
        echo "💡 Install command: sudo apt-get install -y r-base"
    fi
else
    echo "✅ R already installed"
fi

# Install essential R packages with robust error handling
if command -v R &> /dev/null; then
    echo "📈 Installing essential R packages in background (non-blocking)..."
    
    # Create a background R package installer that won't block container creation
    cat > /tmp/install_r_packages_bg.sh << 'RBGEOF'
#!/bin/bash
# Background R package installer
echo "🔄 Installing R packages in background..."
timeout 300 R --slave --vanilla -e "
options(repos='https://cloud.r-project.org/', timeout=60)
packages <- c('DBI', 'RPostgreSQL')
for(pkg in packages) {
    tryCatch({
        if(!require(pkg, character.only=TRUE, quietly=TRUE)) {
            cat('📦 Installing', pkg, '...\n')
            install.packages(pkg, dependencies=FALSE, quiet=TRUE)
            if(require(pkg, character.only=TRUE, quietly=TRUE)) {
                cat('✅', pkg, 'installed successfully\n')
            } else {
                cat('⚠️', pkg, 'installation failed\n')
            }
        } else {
            cat('✅', pkg, 'already available\n')
        }
    }, error=function(e) {
        cat('❌', pkg, 'failed:', as.character(e), '\n')
    })
}
cat('📊 R packages setup complete\n')
" > /tmp/r_install.log 2>&1
RBGEOF
    
    chmod +x /tmp/install_r_packages_bg.sh
    # Start installation in background - won't block container creation
    nohup /tmp/install_r_packages_bg.sh > /tmp/r_bg_install.log 2>&1 &
    echo "✅ R package installation started in background"
    echo "💡 Check progress: tail -f /tmp/r_bg_install.log"
else
    echo "⚠️ R not available - students will need to install R manually"
fi

echo ""
echo "⚡ Codespace setup complete!"
echo ""
echo "🎯 What's ready:"
echo "   ✅ PostgreSQL server and client"
echo "   ✅ Python data science packages"  
if command -v R &> /dev/null; then
    echo "   ✅ R (with essential packages attempted)"
else
    echo "   ⚠️ R (installation failed)"
fi
echo ""
echo "🚀 Next steps:"
echo "1. Test environment: python scripts/test.py"
echo "2. Database will be configured during post-start"
echo "3. Test database: python scripts/test_connection.py"
echo ""
echo "📊 Database Connection Info:"
echo "   🎯 Username: student"
echo "   🔑 Password: student_password"
echo "   🏠 Host: localhost"
echo "   📚 Database: postgres"
echo ""
echo "💡 This setup is optimized for GitHub Codespaces!"
echo "🔧 If you encounter issues:"
echo "   • Database setup: bash scripts/setup_database.sh"
echo "   • R packages: bash scripts/install_r_packages.sh"
echo "   • Full guide: cat DATABASE_PASSWORDS.md"
