#!/usr/bin/env python3
"""
Data Management Classroom - Environment Test Script
Tests all major components of the development environment
"""

import sys
import subprocess
import os

def test_section(name):
    """Print a test section header"""
    print(f"\n🧪 Testing {name}")
    print("-" * (len(name) + 11))

def test_imports():
    """Test if essential packages can be imported"""
    test_section("Python Package Imports")
    
    packages = [
        ('pandas', 'pd'),
        ('numpy', 'np'),
        ('psycopg2', None),
        ('matplotlib.pyplot', 'plt'),
        ('seaborn', 'sns'),
        ('sklearn', None),
        ('jupyter', None)
    ]
    
    success_count = 0
    for package, alias in packages:
        try:
            if alias:
                exec(f"import {package} as {alias}")
            else:
                exec(f"import {package}")
            print(f"  ✅ {package}")
            success_count += 1
        except ImportError as e:
            print(f"  ❌ {package}: {e}")
    
    print(f"\n📊 Package Import Summary: {success_count}/{len(packages)} successful")
    return success_count == len(packages)

def test_database():
    """Test database connectivity"""
    test_section("Database Connectivity")
    
    try:
        import psycopg2
        
        # Test connection
        conn = psycopg2.connect(
            host="localhost",
            database="vscode",
            user="vscode"
        )
        
        cursor = conn.cursor()
        cursor.execute("SELECT version();")
        version = cursor.fetchone()[0]
        print(f"  ✅ PostgreSQL Connection: {version.split(',')[0]}")
        
        # Test basic operations
        cursor.execute("""
            CREATE TABLE IF NOT EXISTS test_table (
                id SERIAL PRIMARY KEY,
                name VARCHAR(100),
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            );
        """)
        
        cursor.execute("INSERT INTO test_table (name) VALUES (%s);", ("test_data",))
        cursor.execute("SELECT COUNT(*) FROM test_table;")
        count = cursor.fetchone()[0]
        print(f"  ✅ Database Operations: {count} records in test table")
        
        # Clean up
        cursor.execute("DROP TABLE IF EXISTS test_table;")
        conn.commit()
        conn.close()
        
        return True
        
    except Exception as e:
        print(f"  ❌ Database Error: {e}")
        return False

def test_environment():
    """Test environment variables"""
    test_section("Environment Variables")
    
    env_vars = ['PGDATABASE', 'PGUSER', 'PGHOST', 'PGPORT']
    success_count = 0
    
    for var in env_vars:
        value = os.environ.get(var)
        if value:
            print(f"  ✅ {var}={value}")
            success_count += 1
        else:
            print(f"  ⚠️ {var} not set")
    
    return success_count >= 2  # At least basic vars should be set

def test_jupyter():
    """Test Jupyter installation"""
    test_section("Jupyter Environment")
    
    try:
        # Check if jupyter is available
        result = subprocess.run(['jupyter', '--version'], 
                              capture_output=True, text=True, timeout=10)
        if result.returncode == 0:
            print("  ✅ Jupyter installed and accessible")
            lines = result.stdout.strip().split('\n')
            for line in lines[:3]:  # Show first few components
                print(f"    {line.strip()}")
            return True
        else:
            print("  ❌ Jupyter not accessible")
            return False
    except Exception as e:
        print(f"  ❌ Jupyter Error: {e}")
        return False

def test_data_science_basics():
    """Test basic data science operations"""
    test_section("Data Science Operations")
    
    try:
        import pandas as pd
        import numpy as np
        import matplotlib.pyplot as plt
        
        # Create sample data
        data = {
            'name': ['Alice', 'Bob', 'Charlie', 'Diana'],
            'age': [25, 30, 35, 28],
            'score': [85.5, 90.2, 78.8, 92.1]
        }
        df = pd.DataFrame(data)
        print(f"  ✅ DataFrame created: {df.shape[0]} rows, {df.shape[1]} columns")
        
        # Basic operations
        mean_age = df['age'].mean()
        print(f"  ✅ Data analysis: Average age = {mean_age}")
        
        # NumPy operations
        arr = np.array([1, 2, 3, 4, 5])
        result = np.mean(arr)
        print(f"  ✅ NumPy operations: Array mean = {result}")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Data Science Error: {e}")
        return False

def test_workspace_structure():
    """Test workspace directory structure"""
    test_section("Workspace Structure")
    
    base_dir = "/workspaces/data-management-classroom"
    expected_dirs = [
        "notebooks", "scripts", "databases", "data/raw", "data/processed",
        "labs", "assignments", "projects", "personal", "shared-data"
    ]
    
    success_count = 0
    for dir_path in expected_dirs:
        full_path = os.path.join(base_dir, dir_path)
        if os.path.exists(full_path):
            print(f"  ✅ {dir_path}/")
            success_count += 1
        else:
            print(f"  ❌ {dir_path}/ (missing)")
    
    return success_count >= len(expected_dirs) * 0.8  # 80% success rate

def main():
    """Run all tests"""
    print("🔬 Data Management Classroom - Environment Test")
    print("=" * 50)
    
    tests = [
        ("Python Packages", test_imports),
        ("Database", test_database),
        ("Environment", test_environment),
        ("Jupyter", test_jupyter),
        ("Data Science", test_data_science_basics),
        ("Workspace", test_workspace_structure)
    ]
    
    results = {}
    for test_name, test_func in tests:
        try:
            results[test_name] = test_func()
        except Exception as e:
            print(f"  ❌ {test_name} Test Failed: {e}")
            results[test_name] = False
    
    # Summary
    print("\n📋 Test Summary")
    print("=" * 20)
    passed = sum(1 for result in results.values() if result)
    total = len(results)
    
    for test_name, result in results.items():
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {status} {test_name}")
    
    print(f"\n🏁 Overall Result: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 All tests passed! Environment is ready for data science work.")
        return 0
    elif passed >= total * 0.7:
        print("⚠️ Most tests passed. Environment is mostly functional.")
        return 0
    else:
        print("🚨 Multiple test failures. Environment needs attention.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
