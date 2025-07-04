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
