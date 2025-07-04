#!/bin/bash

# Manual Database Setup Script
# Sets up PostgreSQL database and user for data management course

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Configuration
DB_USER="student"
DB_PASSWORD="student_password"
DB_NAME="student_db"

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

# Function to create database and user
setup_database() {
    print_status "Setting up database and user..."
    
    # Create user and database
    sudo -u postgres psql -c "CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';" 2>/dev/null || true
    sudo -u postgres psql -c "CREATE DATABASE $DB_NAME OWNER $DB_USER;" 2>/dev/null || true
    
    # Grant privileges
    sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;"
    sudo -u postgres psql -c "ALTER USER $DB_USER CREATEDB;"
    
    print_success "Database and user created successfully"
}

# Function to test connection
test_connection() {
    print_status "Testing database connection..."
    
    if psql -U $DB_USER -d $DB_NAME -c "SELECT 1;" > /dev/null 2>&1; then
        print_success "Database connection test passed"
        return 0
    else
        print_error "Database connection test failed"
        return 1
    fi
}

# Function to load a specific database
load_database() {
    local db_name="$1"
    local db_file="/workspaces/data-managment/databases/$db_name.sql"
    
    if [ ! -f "$db_file" ]; then
        print_error "Database file not found: $db_file"
        return 1
    fi
    
    print_status "Loading $db_name database..."
    
    if psql -U $DB_USER -d $DB_NAME -f "$db_file" > /tmp/db_load.log 2>&1; then
        print_success "$db_name database loaded successfully"
        return 0
    else
        print_error "Failed to load $db_name database"
        echo "Error details:"
        cat /tmp/db_load.log
        return 1
    fi
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  setup             - Set up database and user"
    echo "  test              - Test database connection"
    echo "  load <db_name>    - Load a specific database"
    echo "  help              - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 setup                    # Set up database and user"
    echo "  $0 test                     # Test connection"
    echo "  $0 load northwind           # Load Northwind database"
    echo ""
}

# Main execution
main() {
    echo "==============================================="
    echo "Manual Database Setup for Data Management"
    echo "==============================================="
    echo ""
    
    case "${1:-help}" in
        "setup")
            check_postgresql
            setup_database
            test_connection
            ;;
        "test")
            check_postgresql
            test_connection
            ;;
        "load")
            if [ -z "$2" ]; then
                print_error "Please specify a database name"
                echo ""
                echo "Available databases:"
                echo "  sample, northwind, adventureworks, worldwideimporters"
                echo "  chinook, sakila, hr_employees, dashboard"
                exit 1
            fi
            
            check_postgresql
            if ! test_connection; then
                print_error "Cannot connect to database. Please run '$0 setup' first."
                exit 1
            fi
            
            load_database "$2"
            ;;
        "help"|"-h"|"--help")
            show_usage
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_usage
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
