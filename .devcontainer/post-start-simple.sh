#!/bin/bash

echo "🔄 Post-start: Ensuring all services and configurations are ready..."

# Ensure PostgreSQL is running and ready
if command -v pg_isready >/dev/null 2>&1; then
    echo "🗄️ Checking PostgreSQL status..."
    
    # Start PostgreSQL if not running
    if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
        echo "🔧 Starting PostgreSQL service..."
        sudo service postgresql start >/dev/null 2>&1
        
        # Wait for PostgreSQL to be ready (up to 15 seconds)
        for i in {1..15}; do
            if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
                echo "✅ PostgreSQL is ready"
                break
            fi
            sleep 1
        done
        
        if ! pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
            echo "⚠️ PostgreSQL failed to start properly"
            echo "🔧 Attempting manual restart..."
            sudo service postgresql restart >/dev/null 2>&1
            sleep 3
        fi
    else
        echo "✅ PostgreSQL is already running"
    fi
    
    # Verify database connectivity
    if psql -h localhost -U vscode -d vscode -c "SELECT 1;" >/dev/null 2>&1; then
        echo "✅ Database connection verified"
    else
        echo "⚠️ Database connection issue detected"
        echo "🔧 Attempting to recreate user and database..."
        
        # Recreate user and database if needed
        psql -h localhost -U postgres -d postgres -c "DROP DATABASE IF EXISTS vscode;" >/dev/null 2>&1
        psql -h localhost -U postgres -d postgres -c "DROP USER IF EXISTS vscode;" >/dev/null 2>&1
        psql -h localhost -U postgres -d postgres -c "CREATE USER vscode WITH CREATEDB CREATEROLE SUPERUSER;" >/dev/null 2>&1
        psql -h localhost -U postgres -d postgres -c "CREATE DATABASE vscode OWNER vscode;" >/dev/null 2>&1
        
        if psql -h localhost -U vscode -d vscode -c "SELECT 1;" >/dev/null 2>&1; then
            echo "✅ Database connection restored"
        else
            echo "❌ Database connection still failed"
        fi
    fi
else
    echo "ℹ️ PostgreSQL not installed, skipping database checks"
fi

# Ensure environment variables are loaded
echo "🌍 Verifying environment configuration..."
source ~/.bashrc

# Check if environment variables are set
if [ -z "$PGDATABASE" ]; then
    echo "🔧 Setting up PostgreSQL environment variables..."
    export PGDATABASE=vscode
    export PGUSER=vscode
    export PGHOST=localhost
    export PGPORT=5432
    echo "✅ Environment variables configured for this session"
fi

# Verify Python packages
echo "🐍 Verifying Python environment..."
missing_packages=()
for package in pandas numpy psycopg2 matplotlib seaborn sklearn sqlalchemy; do
    if ! python3 -c "import $package" >/dev/null 2>&1; then
        missing_packages+=("$package")
    fi
done

if [ ${#missing_packages[@]} -gt 0 ]; then
    echo "🔧 Installing missing Python packages: ${missing_packages[*]}"
    pip install --user --no-cache-dir "${missing_packages[@]}" >/dev/null 2>&1
    echo "✅ Missing packages installed"
else
    echo "✅ All Python packages available"
fi

# Create sample data and scripts if they don't exist
echo "📁 Setting up sample files..."
if [ ! -f "/workspaces/data-management-classroom/data/raw/sample.csv" ]; then
    mkdir -p /workspaces/data-management-classroom/data/raw
    cat > /workspaces/data-management-classroom/data/raw/sample.csv << 'CSV_EOF'
id,name,age,department,salary
1,Alice Johnson,28,Engineering,75000
2,Bob Smith,35,Marketing,65000
3,Carol Davis,42,Engineering,85000
4,David Wilson,29,Sales,55000
5,Eve Brown,31,Marketing,60000
CSV_EOF
    echo "✅ Sample CSV file created"
fi

# Create a quick start script
if [ ! -f "/workspaces/data-management-classroom/scripts/quickstart.py" ]; then
    cat > /workspaces/data-management-classroom/scripts/quickstart.py << 'PY_EOF'
#!/usr/bin/env python3
"""
Quick Start Guide for Data Management Classroom
This script demonstrates basic database and data analysis operations.
"""

import pandas as pd
import psycopg2
import matplotlib.pyplot as plt
import seaborn as sns

def test_database_connection():
    """Test and demonstrate database connection"""
    try:
        # Connect to PostgreSQL
        conn = psycopg2.connect(
            host="localhost",
            database="vscode",
            user="vscode"
        )
        
        print("✅ Connected to PostgreSQL successfully!")
        
        # Create a sample table
        cursor = conn.cursor()
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS employees (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100),
                department VARCHAR(50),
                salary INTEGER
            );
        """)
        
        # Insert sample data
        cursor.execute("""
            INSERT INTO employees (name, department, salary) 
            VALUES 
                ('Alice Johnson', 'Engineering', 75000),
                ('Bob Smith', 'Marketing', 65000),
                ('Carol Davis', 'Engineering', 85000)
            ON CONFLICT DO NOTHING;
        """)
        
        conn.commit()
        print("✅ Sample database table created!")
        
        # Query and display data
        df = pd.read_sql("SELECT * FROM employees", conn)
        print("\n📊 Employee Data:")
        print(df)
        
        conn.close()
        return df
        
    except Exception as e:
        print(f"❌ Database error: {e}")
        return None

def analyze_sample_data():
    """Analyze the sample CSV file"""
    try:
        # Load sample CSV
        df = pd.read_csv('/workspaces/data-management-classroom/data/raw/sample.csv')
        print("\n📈 Sample Data Analysis:")
        print(f"Dataset shape: {df.shape}")
        print(f"Average salary: ${df['salary'].mean():,.2f}")
        print(f"Departments: {', '.join(df['department'].unique())}")
        
        return df
        
    except Exception as e:
        print(f"❌ Data analysis error: {e}")
        return None

if __name__ == "__main__":
    print("🚀 Data Management Classroom - Quick Start")
    print("=" * 50)
    
    # Test database
    db_data = test_database_connection()
    
    # Analyze sample data
    csv_data = analyze_sample_data()
    
    print("\n🎉 Quick start complete!")
    print("💡 You're ready to start working with data!")
PY_EOF
    chmod +x /workspaces/data-management-classroom/scripts/quickstart.py
    echo "✅ Quick start script created"
fi

echo "✅ Post-start setup complete!"

# Run a final verification
if command -v python3 >/dev/null 2>&1 && [ -f "/workspaces/data-management-classroom/scripts/test_setup.py" ]; then
    echo ""
    echo "🧪 Running final environment verification..."
    python3 /workspaces/data-management-classroom/scripts/test_setup.py
fi
