#!/bin/bash

echo "🔍 Data Science Classroom Environment Diagnosis"
echo "=============================================="

echo ""
echo "📋 System Information:"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Container: $(uname -a)"

echo ""
echo "🐍 Python Environment:"
python3 --version 2>/dev/null || echo "❌ Python not found"
pip --version 2>/dev/null || echo "❌ pip not found"

echo ""
echo "📦 Python Packages:"
for pkg in pandas numpy psycopg2 jupyter; do
    python3 -c "import $pkg; print('✅ $pkg')" 2>/dev/null || echo "❌ $pkg not found"
done

echo ""
echo "📊 R Environment:"
R --version 2>/dev/null | head -1 || echo "❌ R not found"
which R 2>/dev/null || echo "❌ R not in PATH"

echo ""
echo "🗄️ Database:"
sudo service postgresql status | grep -q "online" && echo "✅ PostgreSQL running" || echo "❌ PostgreSQL not running"
psql --version 2>/dev/null || echo "❌ psql not found"

echo ""
echo "🔌 Network Ports:"
netstat -tlnp 2>/dev/null | grep -E ":(5432|8888|8000)" | head -5 || echo "❌ No services detected on common ports"

echo ""
echo "📁 Workspace Structure:"
ls -la /workspaces/data-management-classroom/ 2>/dev/null | head -10 || echo "❌ Workspace not found"

echo ""
echo "🔧 VS Code Extensions (R related):"
code --list-extensions 2>/dev/null | grep -i r || echo "❌ No R extensions found"

echo ""
echo "=============================================="
echo "🏁 Diagnosis complete!"
echo ""
echo "💡 If you see ❌ marks, try running:"
echo "   - sudo apt-get update && sudo apt-get install -y r-base"
echo "   - bash .devcontainer/install_r_packages.sh"
echo "   - sudo service postgresql start"
