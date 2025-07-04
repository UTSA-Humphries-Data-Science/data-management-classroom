#!/bin/bash

echo "🔧 Quick PostgreSQL Fix for Codespace"
echo "====================================="

# Create a temporary script to fix PostgreSQL permissions
cat > /tmp/fix_postgres.sh << 'EOF'
#!/bin/bash

# Start PostgreSQL if not running
service postgresql start

# Configure PostgreSQL for local development without passwords
cd /etc/postgresql/*/main/

# Backup original pg_hba.conf
cp pg_hba.conf pg_hba.conf.backup

# Create new pg_hba.conf that allows local connections without password
cat > pg_hba.conf << 'PGEOF'
# PostgreSQL Client Authentication Configuration File
# TYPE  DATABASE        USER            ADDRESS                 METHOD

# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust
PGEOF

# Reload PostgreSQL configuration
service postgresql reload

echo "✅ PostgreSQL configured for local development"
EOF

# Try to run the fix with elevated privileges
echo "🔧 Attempting to configure PostgreSQL..."
if command -v sudo >/dev/null 2>&1; then
    echo "  Using sudo to configure PostgreSQL..."
    sudo bash /tmp/fix_postgres.sh 2>/dev/null && echo "✅ PostgreSQL fixed with sudo" || echo "⚠️ Sudo approach failed"
else
    echo "⚠️ sudo not available"
fi

# Clean up
rm -f /tmp/fix_postgres.sh

echo ""
echo "💡 Alternative: If the above didn't work, you can:"
echo "  1. Use: psql -h localhost -U postgres -d postgres"
echo "  2. Or set PGPASSWORD environment variable"
echo "  3. Or create a .pgpass file in your home directory"
