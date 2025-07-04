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
