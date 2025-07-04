#!/usr/bin/env python3
"""
Comprehensive package verification script for data science classroom.
This script checks if all required Python packages are properly installed.
"""

import importlib
import subprocess


def check_python_package(package_name, import_name=None):
    """Check if a Python package is installed and can be imported."""
    if import_name is None:
        import_name = package_name

    try:
        importlib.import_module(import_name)
        print(f"✅ {package_name}")
        return True
    except ImportError:
        print(f"❌ {package_name} - Not installed or import failed")
        return False


def check_r_package(package_name):
    """Check if an R package is installed."""
    try:
        cmd = [
            'R', '--slave', '--vanilla', '-e',
            f'if(require("{package_name}", quietly=TRUE)) '
            f'cat("SUCCESS") else cat("FAILED")'
        ]
        result = subprocess.run(
            cmd, capture_output=True, text=True, timeout=30, check=False
        )

        if 'SUCCESS' in result.stdout:
            print(f"✅ {package_name} (R)")
            return True
        else:
            print(f"❌ {package_name} (R) - Not installed")
            return False
    except (subprocess.TimeoutExpired, subprocess.SubprocessError,
            FileNotFoundError) as e:
        print(f"❌ {package_name} (R) - Error checking: {e}")
        return False


def main():
    print("🔍 Verifying Data Science Environment Packages")
    print("=" * 50)

    # Python packages to check
    python_packages = [
        ('jupyter', 'jupyter'),
        ('jupyterlab', 'jupyterlab'),
        ('notebook', 'notebook'),
        ('ipywidgets', 'ipywidgets'),
        ('pandas', 'pandas'),
        ('numpy', 'numpy'),
        ('scipy', 'scipy'),
        ('matplotlib', 'matplotlib'),
        ('seaborn', 'seaborn'),
        ('plotly', 'plotly'),
        ('bokeh', 'bokeh'),
        ('scikit-learn', 'sklearn'),
        ('tensorflow', 'tensorflow'),
        ('keras', 'keras'),
        ('sqlalchemy', 'sqlalchemy'),
        ('psycopg2-binary', 'psycopg2'),
        ('pymongo', 'pymongo'),
        ('streamlit', 'streamlit'),
        ('fastapi', 'fastapi'),
        ('requests', 'requests'),
        ('great-expectations', 'great_expectations'),
        ('pytest', 'pytest'),
        ('black', 'black'),
        ('flake8', 'flake8'),
        ('statsmodels', 'statsmodels'),
        ('pingouin', 'pingouin'),
        ('tqdm', 'tqdm'),
        ('python-dotenv', 'dotenv'),
        ('pyyaml', 'yaml'),
        ('openpyxl', 'openpyxl'),
        ('xlsxwriter', 'xlsxwriter'),
    ]

    # R packages to check
    r_packages = [
        'DBI',
        'RPostgreSQL',
        'dplyr',
        'tidyr',
        'readr',
        'readxl',
        'ggplot2',
        'plotly',
        'broom',
        'modelr',
        'lubridate',
        'stringr'
    ]

    print("\n📦 Python Packages:")
    print("-" * 20)
    python_success = 0
    for package_name, import_name in python_packages:
        if check_python_package(package_name, import_name):
            python_success += 1

    print(f"\nPython packages: {python_success}/{len(python_packages)} "
          f"installed")

    print("\n📊 R Packages:")
    print("-" * 20)
    r_success = 0
    for package_name in r_packages:
        if check_r_package(package_name):
            r_success += 1

    print(f"\nR packages: {r_success}/{len(r_packages)} installed")

    print("\n" + "=" * 50)
    total_packages = len(python_packages) + len(r_packages)
    total_success = python_success + r_success

    if total_success == total_packages:
        print("🎉 All packages are installed and working!")
        return 0
    else:
        print(f"⚠️  {total_packages - total_success} packages need attention")
        print("💡 Run the installation scripts to fix missing packages:")
        print("   pip install -r requirements.txt")
        print("   bash scripts/install_r_packages.sh")
        return 1


if __name__ == "__main__":
    exit(main())
