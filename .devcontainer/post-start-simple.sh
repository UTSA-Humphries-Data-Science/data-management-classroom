#!/bin/bash

echo "🚀 Starting services..."

# Start PostgreSQL if not running
if ! sudo service postgresql status >/dev/null 2>&1; then
    echo "📊 Starting PostgreSQL..."
    sudo service postgresql start >/dev/null 2>&1
    echo "✅ PostgreSQL started"
fi

# Set up environment variables for PostgreSQL
export PGDATABASE=vscode
export PGUSER=vscode
export PGHOST=localhost
export PGPORT=5432

# Save to user's bashrc
{
    echo "export PGDATABASE=vscode"
    echo "export PGUSER=vscode"
    echo "export PGHOST=localhost"
    echo "export PGPORT=5432"
} >> ~/.bashrc

echo "✅ Services ready!"
