#!/bin/bash

# Deployment Verification Script
# Checks if all files are present and ready for GitHub Classroom deployment

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
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# Check if file exists
check_file() {
    local file="$1"
    local description="$2"
    
    if [ -f "$file" ]; then
        print_success "$description: $file"
        return 0
    else
        print_error "$description: $file NOT FOUND"
        return 1
    fi
}

# Check if directory exists
check_directory() {
    local dir="$1"
    local description="$2"
    
    if [ -d "$dir" ]; then
        print_success "$description: $dir"
        return 0
    else
        print_error "$description: $dir NOT FOUND"
        return 1
    fi
}

# Main verification function
verify_deployment() {
    echo "==============================================="
    echo "Deployment Verification for GitHub Classroom"
    echo "==============================================="
    echo ""
    
    local errors=0
    
    # Check core directories
    print_status "Checking core directories..."
    check_directory ".devcontainer" "DevContainer directory" || ((errors++))
    check_directory "scripts" "Scripts directory" || ((errors++))
    check_directory "databases" "Databases directory" || ((errors++))
    echo ""
    
    # Check devcontainer files
    print_status "Checking devcontainer files..."
    check_file ".devcontainer/setup_codespace.sh" "Codespace setup script" || ((errors++))
    check_file ".devcontainer/post-start.sh" "Post-start script" || ((errors++))
    if [ -f ".devcontainer/devcontainer.json" ]; then
        print_success "DevContainer config: .devcontainer/devcontainer.json"
    else
        print_warning "DevContainer config: .devcontainer/devcontainer.json (you may need to update your existing one)"
    fi
    echo ""
    
    # Check scripts
    print_status "Checking scripts..."
    check_file "scripts/test.py" "Environment test script" || ((errors++))
    check_file "scripts/test_connection.py" "Database connection test" || ((errors++))
    check_file "scripts/test-codespace.py" "Codespace test script" || ((errors++))
    check_file "scripts/setup_database.sh" "Manual database setup" || ((errors++))
    check_file "scripts/install_r_packages.sh" "R package installer" || ((errors++))
    check_file "scripts/load_databases.sh" "Database loader utility" || ((errors++))
    echo ""
    
    # Check executable permissions
    print_status "Checking executable permissions..."
    if [ -x "scripts/load_databases.sh" ]; then
        print_success "Database loader is executable"
    else
        print_warning "Database loader needs executable permission (chmod +x scripts/load_databases.sh)"
    fi
    
    if [ -x "scripts/setup_database.sh" ]; then
        print_success "Database setup script is executable"
    else
        print_warning "Database setup script needs executable permission (chmod +x scripts/setup_database.sh)"
    fi
    echo ""
    
    # Check database files
    print_status "Checking database files..."
    check_file "databases/README.md" "Database guide" || ((errors++))
    check_file "databases/DATABASE_COLLECTION_SUMMARY.md" "Database collection summary" || ((errors++))
    check_file "databases/sample.sql" "Sample database" || ((errors++))
    check_file "databases/northwind.sql" "Northwind database" || ((errors++))
    check_file "databases/adventureworks.sql" "AdventureWorks database" || ((errors++))
    check_file "databases/worldwideimporters.sql" "WorldWideImporters database" || ((errors++))
    check_file "databases/chinook.sql" "Chinook database" || ((errors++))
    check_file "databases/sakila.sql" "Sakila database" || ((errors++))
    check_file "databases/hr_employees.sql" "HR Employees database" || ((errors++))
    check_file "databases/dashboard.sql" "Dashboard views" || ((errors++))
    echo ""
    
    # Check documentation
    print_status "Checking documentation..."
    check_file "DATABASE_PASSWORDS.md" "Database connection reference" || ((errors++))
    check_file "STUDENT_SETUP_GUIDE.md" "Student setup guide" || ((errors++))
    check_file "DEPLOYMENT_READY.md" "Deployment ready guide" || ((errors++))
    check_file "FINAL_DEPLOYMENT_PACKAGE.md" "Final deployment package" || ((errors++))
    echo ""
    
    # Check database file sizes
    print_status "Checking database file sizes..."
    for db_file in databases/*.sql; do
        if [ -f "$db_file" ]; then
            size=$(stat -c%s "$db_file" 2>/dev/null || stat -f%z "$db_file" 2>/dev/null || echo "0")
            if [ "$size" -gt 1000 ]; then
                print_success "$(basename "$db_file"): ${size} bytes"
            else
                print_warning "$(basename "$db_file"): ${size} bytes (possibly empty)"
            fi
        fi
    done
    echo ""
    
    # Count total files
    print_status "Deployment statistics..."
    db_count=$(ls -1 databases/*.sql 2>/dev/null | wc -l)
    script_count=$(ls -1 scripts/*.py scripts/*.sh 2>/dev/null | wc -l)
    doc_count=$(ls -1 *.md 2>/dev/null | wc -l)
    
    echo "  Database files: $db_count"
    echo "  Script files: $script_count"
    echo "  Documentation files: $doc_count"
    echo ""
    
    # Final summary
    if [ $errors -eq 0 ]; then
        echo "==============================================="
        print_success "DEPLOYMENT VERIFICATION PASSED!"
        echo "==============================================="
        echo ""
        echo "✅ All required files are present"
        echo "✅ $db_count database files ready"
        echo "✅ $script_count script files ready"
        echo "✅ $doc_count documentation files ready"
        echo ""
        echo "🎉 Ready to deploy to GitHub Classroom!"
        echo ""
        echo "Next steps:"
        echo "1. Copy all files to your GitHub Classroom repository"
        echo "2. Update your .devcontainer/devcontainer.json if needed"
        echo "3. Test with a new Codespace"
        echo "4. Deploy to your students"
        echo ""
        return 0
    else
        echo "==============================================="
        print_error "DEPLOYMENT VERIFICATION FAILED!"
        echo "==============================================="
        echo ""
        echo "❌ Found $errors missing files or issues"
        echo "❌ Please fix the issues above before deploying"
        echo ""
        return 1
    fi
}

# Run verification
verify_deployment
