# Complete Database Collection Summary

## Overview

This collection provides **7 comprehensive sample databases** commonly used in data science and SQL training. Each database is designed to teach different aspects of database design and querying.

## Database Collection

### 1. **Sample Database** (`sample.sql`)
- **Purpose**: Beginner-friendly introduction
- **Schema**: `public`  
- **Tables**: 1 (Students)
- **Records**: ~10
- **Best For**: First SQL queries, basic operations, connection testing

### 2. **Northwind Database** (`northwind.sql`)
- **Purpose**: Classic e-commerce training
- **Schema**: `northwind`
- **Tables**: 10 (Categories, Suppliers, Products, Customers, Orders, Order Details, Employees, Shippers, Regions, Territories)
- **Records**: ~3,000
- **Best For**: Business queries, JOINs, aggregate functions, reporting

### 3. **AdventureWorks Database** (`adventureworks.sql`)
- **Purpose**: Microsoft's flagship sample (simplified)
- **Schema**: `adventureworks`
- **Tables**: 8 (Person, Customer, Product, Sales, Territory, Address, etc.)
- **Records**: ~2,000
- **Best For**: Complex queries, business intelligence, customer analysis

### 4. **World Wide Importers Database** (`worldwideimporters.sql`)
- **Purpose**: Modern Microsoft sample (simplified)
- **Schema**: `wwi`
- **Tables**: 10 (People, Customers, Suppliers, Stock Items, Orders, Invoices, Transactions)
- **Records**: ~2,500
- **Best For**: Advanced SQL features, supply chain analytics, modern patterns

### 5. **Chinook Database** (`chinook.sql`)
- **Purpose**: Digital music store
- **Schema**: `chinook`
- **Tables**: 11 (Artist, Album, Track, Customer, Employee, Invoice, Invoice Line, Playlist, etc.)
- **Records**: ~4,000
- **Best For**: Music industry analytics, sales reporting, complex relationships

### 6. **Sakila Database** (`sakila.sql`)
- **Purpose**: DVD rental store
- **Schema**: `sakila`
- **Tables**: 16 (Film, Actor, Customer, Rental, Payment, Category, Language, Address, City, Country)
- **Records**: ~5,000
- **Best For**: Rental business analytics, geographic analysis, many-to-many relationships

### 7. **HR Employees Database** (`hr_employees.sql`)
- **Purpose**: Human resources and hierarchical data
- **Schema**: `hr`
- **Tables**: 7 (Employees, Departments, Jobs, Locations, Countries, Regions, Job History)
- **Records**: ~1,000
- **Best For**: Hierarchical queries, employee management, organizational structure

## Total Database Statistics

- **Total Databases**: 7
- **Total Tables**: 62
- **Total Records**: ~17,500
- **Total Schemas**: 6 (plus public)
- **File Size**: ~2.5MB total

## Learning Progression

### **Beginner Level**
1. **Sample Database** - Learn basic SQL syntax
2. **Northwind** - Master JOINs and basic business queries

### **Intermediate Level**
3. **AdventureWorks** - Complex business scenarios
4. **Chinook** - Multi-table analytics and reporting

### **Advanced Level**
5. **Sakila** - Complex relationships and geographic data
6. **HR Employees** - Hierarchical queries and organizational data
7. **World Wide Importers** - Modern SQL features and patterns

## Quick Start Guide

### Load All Databases
```bash
# Load everything at once
./scripts/load_databases.sh load-all

# Verify loading
./scripts/load_databases.sh test
```

### Load Individual Database
```bash
# Load specific database
./scripts/load_databases.sh load northwind

# Check what's loaded
./scripts/load_databases.sh schemas
./scripts/load_databases.sh tables northwind
```

### Sample Queries by Complexity

#### **Beginner Queries**
```sql
-- Basic SELECT (Sample DB)
SELECT * FROM students WHERE grade > 90;

-- Simple JOIN (Northwind)
SET search_path TO northwind, public;
SELECT p.product_name, c.category_name 
FROM products p JOIN categories c ON p.category_id = c.category_id;
```

#### **Intermediate Queries**
```sql
-- Aggregate with GROUP BY (Chinook)
SET search_path TO chinook, public;
SELECT ar.name, COUNT(t.track_id) as track_count
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t ON al.album_id = t.album_id
GROUP BY ar.name
ORDER BY track_count DESC;
```

#### **Advanced Queries**
```sql
-- Hierarchical Query (HR)
SET search_path TO hr, public;
WITH RECURSIVE org_chart AS (
    SELECT employee_id, first_name, last_name, manager_id, 0 as level
    FROM employees WHERE manager_id IS NULL
    UNION ALL
    SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, oc.level + 1
    FROM employees e
    JOIN org_chart oc ON e.manager_id = oc.employee_id
)
SELECT * FROM org_chart ORDER BY level, last_name;
```

## Database Features by Type

### **E-commerce/Sales**
- **Northwind**: Classic online store
- **AdventureWorks**: Enterprise sales
- **Chinook**: Digital downloads
- **Sakila**: Physical rentals

### **Industry-Specific**
- **Chinook**: Music/Entertainment industry
- **Sakila**: Movie/Entertainment industry
- **HR**: Human resources and corporate

### **Data Complexity**
- **Simple**: Sample, Northwind
- **Moderate**: AdventureWorks, Chinook
- **Complex**: Sakila, HR, World Wide Importers

### **Special Features**
- **Hierarchical Data**: HR (employee-manager relationships)
- **Geographic Data**: Sakila (address-city-country), HR (locations)
- **Time Series**: All databases (dates, history)
- **Many-to-Many**: Sakila (film-actor), Chinook (playlist-track)
- **Self-Referencing**: HR (employees-managers)

## Common Learning Objectives

### **Basic SQL (Sample, Northwind)**
- SELECT statements
- WHERE clauses
- ORDER BY
- Basic JOINs
- Aggregate functions

### **Intermediate SQL (AdventureWorks, Chinook)**
- Complex JOINs
- GROUP BY with HAVING
- Subqueries
- Window functions
- CASE statements

### **Advanced SQL (Sakila, HR, WWI)**
- Recursive CTEs
- Complex window functions
- Advanced aggregation
- Hierarchical queries
- Performance optimization

## Setup Verification

After loading all databases, verify your setup:

```bash
# Check all schemas
./scripts/load_databases.sh schemas

# Test all databases
./scripts/load_databases.sh test

# Show tables in each schema
./scripts/load_databases.sh tables northwind
./scripts/load_databases.sh tables chinook
./scripts/load_databases.sh tables sakila
./scripts/load_databases.sh tables hr
```

## Troubleshooting

### Database Not Loading
```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check connection
psql -U student -d student_db -c "SELECT 1;"

# Manual load
psql -U student -d student_db -f databases/northwind.sql
```

### Schema Issues
```sql
-- List all schemas
\dn

-- Set working schema
SET search_path TO northwind, public;

-- Check current schema
SELECT current_schema();
```

### Permission Issues
```bash
# Grant permissions (if needed)
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE student_db TO student;"
```

## File Structure

```
databases/
├── README.md                   # This comprehensive guide
├── sample.sql                  # Basic starter database
├── northwind.sql              # Classic e-commerce
├── adventureworks.sql         # Microsoft enterprise sample
├── worldwideimporters.sql     # Modern Microsoft sample
├── chinook.sql               # Digital music store
├── sakila.sql                # DVD rental store
└── hr_employees.sql          # HR and hierarchical data

scripts/
└── load_databases.sh         # Database loader utility
```

## Summary

This complete database collection provides:
- **Progressive learning path** from beginner to advanced
- **Industry-standard examples** used in real training
- **Diverse data types** and business scenarios
- **Comprehensive coverage** of SQL features
- **Easy setup and management** with automated scripts

Perfect for data science courses, SQL training, and database learning in any environment including GitHub Codespaces, local development, or cloud platforms.
