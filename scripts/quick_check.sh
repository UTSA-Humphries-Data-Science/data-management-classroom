#!/bin/bash

echo "🎯 Data Management Classroom - Quick Environment Check"
echo "===================================================="

# Check if PostgreSQL is running and accessible
echo "🗄️ Database Status:"
if pg_isready -h localhost -p 5432 >/dev/null 2>&1; then
    echo "  ✅ PostgreSQL is running"
    if psql -h localhost -U vscode -d vscode -c "SELECT 'Connected successfully!';" >/dev/null 2>&1; then
        echo "  ✅ Database connection working"
    else
        echo "  ⚠️ Cannot connect to database"
    fi
else
    echo "  ❌ PostgreSQL is not running"
    echo "  💡 Run: sudo service postgresql start"
fi

# Check Python packages
echo ""
echo "🐍 Python Environment:"
for pkg in pandas numpy psycopg2 matplotlib seaborn sklearn sqlalchemy; do
    if python3 -c "import $pkg" >/dev/null 2>&1; then
        echo "  ✅ $pkg"
    else
        echo "  ❌ $pkg (run: pip install --user $pkg)"
    fi
done

# Check VS Code Python extension
echo ""
echo "� VS Code Environment:"
if command -v code >/dev/null 2>&1; then
    echo "  ✅ VS Code available"
    echo "  💡 Use VS Code notebooks for data analysis"
else
    echo "  ℹ️ VS Code not in PATH (normal in container)"
fi

# Environment variables
echo ""
echo "🌍 Environment:"
if [ -n "$PGDATABASE" ]; then
    echo "  ✅ Database environment configured"
else
    echo "  ⚠️ Database environment not set"
    echo "  💡 Run: source ~/.bashrc"
fi

echo ""
echo "🏁 Quick check complete!"
echo "💡 For detailed testing, run: python3 scripts/test_setup.py"
echo "🚀 Try the quick start: python3 scripts/quickstart.py"
