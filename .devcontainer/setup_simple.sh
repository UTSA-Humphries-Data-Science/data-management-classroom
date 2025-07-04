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
sudo service postgresql start >/dev/null 2>&1

# Create development user and database
sudo -u postgres createuser -s vscode 2>/dev/null || echo "User already exists"
sudo -u postgres createdb vscode 2>/dev/null || echo "Database already exists"

# Install R (optional, skip if fails)
echo "📊 Installing R..."
if safe_install r-base r-base-dev; then
    echo "✅ R installed successfully"
else
    echo "⚠️ R installation skipped"
fi

# Install Python packages
echo "🐍 Installing Python packages..."
pip install --user --no-cache-dir psycopg2-binary pandas numpy jupyter matplotlib seaborn scikit-learn >/dev/null 2>&1 || echo "⚠️ Some Python packages may have issues"

# Create workspace directories
echo "📁 Creating workspace structure..."
mkdir -p /workspaces/data-management-classroom/{notebooks,scripts,databases,data/{raw,processed},labs,assignments,projects,personal,shared-data}

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
        print("✅ Python packages: pandas, numpy, psycopg2")
        return True
    except ImportError as e:
        print(f"❌ Python import error: {e}")
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
    test_imports()
    test_r()
    print("✅ Environment test complete")
EOF

chmod +x /workspaces/data-management-classroom/scripts/test_setup.py

echo "✅ Codespace setup complete!"
echo "🧪 Run 'python scripts/test_setup.py' to verify installation"
