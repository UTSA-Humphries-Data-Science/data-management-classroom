#!/bin/bash

# Database Loader Script
# Loads all sample databases into PostgreSQL

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DB_USER="student"
DB_NAME="student_db"
DB_HOST="localhost"
DB_PORT="5432"
DATABASES_DIR="/workspaces/data-managment/databases"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if PostgreSQL is running
check_postgresql() {
    print_status "Checking PostgreSQL service..."
    if ! systemctl is-active --quiet postgresql; then
        print_warning "PostgreSQL is not running. Starting it..."
        sudo systemctl start postgresql
        sleep 2
    fi
    print_success "PostgreSQL is running"
}

# Function to check database connection
check_connection() {
    print_status "Testing database connection..."
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
        print_success "Database connection successful"
        return 0
    else
        print_error "Cannot connect to database"
        return 1
    fi
}

# Function to load a single database
load_database() {
    local db_file="$1"
    local db_name=$(basename "$db_file" .sql)
    
    print_status "Loading $db_name database..."
    
    if [ ! -f "$db_file" ]; then
        print_error "Database file not found: $db_file"
        return 1
    fi
    
    # Load the database
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -f "$db_file" > /tmp/db_load.log 2>&1; then
        print_success "$db_name database loaded successfully"
        return 0
    else
        print_error "Failed to load $db_name database"
        echo "Error details:"
        cat /tmp/db_load.log
        return 1
    fi
}

# Function to list available databases
list_databases() {
    print_status "Available sample databases:"
    echo ""
    
    if [ -f "$DATABASES_DIR/sample.sql" ]; then
        echo "  sample          - Simple starter database with basic tables"
    fi
    
    if [ -f "$DATABASES_DIR/northwind.sql" ]; then
        echo "  northwind       - Classic e-commerce database (Categories, Products, Orders)"
    fi
    
    if [ -f "$DATABASES_DIR/adventureworks.sql" ]; then
        echo "  adventureworks  - Microsoft's sample database (Sales, Customers, Products)"
    fi
    
    if [ -f "$DATABASES_DIR/worldwideimporters.sql" ]; then
        echo "  worldwideimporters - Modern Microsoft sample (Supply chain, Invoices)"
    fi
    
    if [ -f "$DATABASES_DIR/chinook.sql" ]; then
        echo "  chinook         - Digital music store (Artists, Albums, Tracks, Sales)"
    fi
    
    if [ -f "$DATABASES_DIR/sakila.sql" ]; then
        echo "  sakila          - DVD rental store (Films, Actors, Customers, Rentals)"
    fi
    
    if [ -f "$DATABASES_DIR/hr_employees.sql" ]; then
        echo "  hr_employees    - HR database (Employees, Departments, Job History)"
    fi
    
    if [ -f "$DATABASES_DIR/dashboard.sql" ]; then
        echo "  dashboard       - Cross-database analytics and summary views"
    fi
    
    echo ""
}

# Function to show database schemas
show_schemas() {
    print_status "Listing database schemas..."
    psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\\dn" || true
}

# Function to show database tables
show_tables() {
    local schema="$1"
    if [ -n "$schema" ]; then
        print_status "Listing tables in schema '$schema'..."
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\\dt $schema.*" || true
    else
        print_status "Listing all tables..."
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\\dt" || true
        print_status "Listing tables in all schemas..."
        psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "\\dt *.*" || true
    fi
}

# Function to run a quick test
test_databases() {
    print_status "Testing loaded databases..."
    
    # Test sample database
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SELECT COUNT(*) FROM students;" > /dev/null 2>&1; then
        print_success "Sample database is working"
    fi
    
    # Test northwind
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SET search_path TO northwind, public; SELECT COUNT(*) FROM products;" > /dev/null 2>&1; then
        print_success "Northwind database is working"
    fi
    
    # Test adventureworks
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SET search_path TO adventureworks, public; SELECT COUNT(*) FROM product;" > /dev/null 2>&1; then
        print_success "AdventureWorks database is working"
    fi
    
    # Test worldwideimporters
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SET search_path TO wwi, public; SELECT COUNT(*) FROM customers;" > /dev/null 2>&1; then
        print_success "WorldWideImporters database is working"
    fi
    
    # Test chinook
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SET search_path TO chinook, public; SELECT COUNT(*) FROM artist;" > /dev/null 2>&1; then
        print_success "Chinook database is working"
    fi
    
    # Test sakila
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SET search_path TO sakila, public; SELECT COUNT(*) FROM film;" > /dev/null 2>&1; then
        print_success "Sakila database is working"
    fi
    
    # Test hr_employees
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SET search_path TO hr, public; SELECT COUNT(*) FROM employees;" > /dev/null 2>&1; then
        print_success "HR Employees database is working"
    fi
    
    # Test dashboard
    if psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -c "SET search_path TO dashboard, public; SELECT COUNT(*) FROM database_inventory;" > /dev/null 2>&1; then
        print_success "Dashboard views are working"
    fi
}

# Main execution
main() {
    echo "==============================================="
    echo "Database Loader for Data Management Course"
    echo "==============================================="
    echo ""
    
    case "${1:-help}" in
        "help"|"-h"|"--help")
            echo "Usage: $0 [command] [options]"
            echo ""
            echo "Commands:"
            echo "  help              - Show this help message"
            echo "  list              - List available databases"
            echo "  load [db_name]    - Load a specific database"
            echo "  load-all          - Load all databases"
            echo "  schemas           - Show database schemas"
            echo "  tables [schema]   - Show tables (optionally in specific schema)"
            echo "  test              - Test loaded databases"
            echo "  status            - Check PostgreSQL and connection status"
            echo ""
            echo "Examples:"
            echo "  $0 list                    # List available databases"
            echo "  $0 load northwind          # Load only Northwind database"
            echo "  $0 load-all               # Load all databases"
            echo "  $0 tables northwind       # Show tables in northwind schema"
            echo "  $0 test                   # Test all databases"
            echo ""
            ;;
        "list")
            list_databases
            ;;
        "load")
            if [ -z "$2" ]; then
                print_error "Please specify a database name"
                echo "Available databases:"
                list_databases
                exit 1
            fi
            
            check_postgresql
            if ! check_connection; then
                print_error "Cannot connect to database. Please check your setup."
                exit 1
            fi
            
            db_file="$DATABASES_DIR/$2.sql"
            if ! load_database "$db_file"; then
                exit 1
            fi
            ;;
        "load-all")
            check_postgresql
            if ! check_connection; then
                print_error "Cannot connect to database. Please check your setup."
                exit 1
            fi
            
            # Load databases in order
            databases=("sample" "northwind" "adventureworks" "worldwideimporters" "chinook" "sakila" "hr_employees")
            
            for db in "${databases[@]}"; do
                db_file="$DATABASES_DIR/$db.sql"
                if [ -f "$db_file" ]; then
                    if ! load_database "$db_file"; then
                        print_warning "Failed to load $db, continuing with next database..."
                    fi
                    echo ""
                fi
            done
            
            # Load dashboard views
            dashboard_file="$DATABASES_DIR/dashboard.sql"
            if [ -f "$dashboard_file" ]; then
                print_status "Loading dashboard views..."
                if ! load_database "$dashboard_file"; then
                    print_warning "Failed to load dashboard views, but databases are still available"
                fi
                echo ""
            fi
            
            print_success "Database loading completed!"
            echo ""
            print_status "Running quick test..."
            test_databases
            ;;
        "schemas")
            check_postgresql
            if ! check_connection; then
                print_error "Cannot connect to database. Please check your setup."
                exit 1
            fi
            show_schemas
            ;;
        "tables")
            check_postgresql
            if ! check_connection; then
                print_error "Cannot connect to database. Please check your setup."
                exit 1
            fi
            show_tables "$2"
            ;;
        "test")
            check_postgresql
            if ! check_connection; then
                print_error "Cannot connect to database. Please check your setup."
                exit 1
            fi
            test_databases
            ;;
        "status")
            check_postgresql
            check_connection
            ;;
        *)
            print_error "Unknown command: $1"
            echo "Use '$0 help' for usage information"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
