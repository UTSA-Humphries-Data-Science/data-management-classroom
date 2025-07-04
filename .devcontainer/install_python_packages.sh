#!/bin/bash

# Essential Python packages installation script
echo "📦 Installing essential Python packages..."

# Essential packages for data science classroom
PYTHON_PACKAGES="pandas numpy openpyxl xlsxwriter seaborn statsmodels scikit-learn matplotlib jupyter jupyterlab"

# Install packages
pip install --user $PYTHON_PACKAGES

echo "✅ Essential Python packages installation complete!"

# Quick verification
echo "🔍 Verifying installations..."
python3 -c "
import sys
packages = ['pandas', 'numpy', 'openpyxl', 'xlsxwriter', 'seaborn', 'statsmodels', 'sklearn', 'matplotlib', 'jupyter']
failed = []
for pkg in packages:
    try:
        if pkg == 'sklearn':
            __import__('sklearn')
        else:
            __import__(pkg)
        print(f'✅ {pkg}')
    except ImportError:
        print(f'❌ {pkg}')
        failed.append(pkg)

if failed:
    print(f'⚠️ Failed packages: {failed}')
    sys.exit(1)
else:
    print('🎉 All essential Python packages installed successfully!')
"
