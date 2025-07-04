# 🚀 Student Setup Guide

## Quick Start

### 1. Run the Setup Script
```bash
# Make the script executable and run it
chmod +x .devcontainer/setup.sh
./.devcontainer/setup.sh
```

### 2. Container Restart (Automatic)
The post-start script runs automatically when your container starts and:
- Sets up PostgreSQL database (if Docker available)
- Creates helpful command aliases
- Tests your environment
- Loads sample data

### 3. Test Your Environment
```bash
# Test what's working
testenv           # Comprehensive test
# OR
quicktest         # Quick health check
```

### 4. Expected Results
You should see:
- ✅ Python: pandas, numpy, psycopg2 working
- ✅ R installed
- ✅ PostgreSQL client ready
- ❌ Docker not found (this is normal in some environments)

## 🛠️ What the Setup Installs

### Python Data Science Stack
- **pandas** - Data manipulation and analysis
- **numpy** - Numerical computing
- **psycopg2** - PostgreSQL adapter
- **jupyter** - Interactive notebooks

### R Environment
- **R base** - R programming language
- **DBI** - Database interface
- **RPostgreSQL** - PostgreSQL driver for R
- **dplyr** - Data manipulation
- **readr** - Data import
- **ggplot2** - Data visualization (may need manual install)

### Database Tools
- **PostgreSQL client** - Command-line tools for PostgreSQL

## 🔧 Troubleshooting

### If Setup Fails
1. **Package manager busy**: Wait 5 minutes and try again
2. **Permission issues**: Make sure you're running as authorized user
3. **R packages failing**: Run the dedicated script:
   ```bash
   bash scripts/install_r_packages.sh
   ```

### Common Issues

#### R Package Installation Fails
```bash
# Install missing R packages manually
sudo R -e "install.packages('ggplot2')"
```

#### Python Package Issues
```bash
# Reinstall Python packages
pip install --upgrade --user pandas numpy psycopg2-binary jupyter
```

#### PostgreSQL Connection Issues
```bash
# Test database connection (requires running database)
python scripts/test_connection.py
```

## 📁 What Gets Created

The setup creates these directories and files:

```
/workspaces/data-managment/
├── scripts/
│   ├── test.py                    # Environment test script
│   ├── test_connection.py         # Database connection test
│   └── install_r_packages.sh     # R packages installer
├── databases/
│   └── sample.sql                 # Sample database schema
├── notebooks/                     # Jupyter notebooks
├── data/
│   ├── raw/                      # Raw data files
│   └── processed/                # Processed data files
└── projects/                     # Your projects
```

## 🎯 Next Steps

1. **Start coding**: Use the `notebooks/` directory for Jupyter notebooks
2. **Database work**: Use the `databases/` directory for SQL scripts
3. **Data analysis**: Store data in `data/raw/` and processed results in `data/processed/`
4. **Projects**: Create your assignments in the `projects/` directory

## 🚀 Helpful Commands (Available after restart)

### Environment Testing
- `testenv` - Run comprehensive environment test
- `quicktest` - Quick environment health check

### Database Operations  
- `psql-connect` - Connect to PostgreSQL database
- `dbstatus` - Check if database is running
- `dbstart` - Start the database container
- `dbstop` - Stop the database container
- `dblogs` - View database logs

### Development Tools
- `jlab` - Start Jupyter Lab
- `jnb` - Start Jupyter Notebook  
- `r-console` - Start R console
- `workspace` - Navigate to main workspace

### Navigation
- `workspace` - Go to `/workspaces/data-managment`

## 💡 Pro Tips

- The setup script can be run multiple times safely
- If something fails, check the troubleshooting section
- The `scripts/test.py` file shows you exactly what's working
- Use `scripts/install_r_packages.sh` if R packages need reinstalling

## 📞 Need Help?

If you encounter issues:
1. Run `python scripts/test.py` to see what's working
2. Check the error messages - they often tell you exactly what to do
3. Try the troubleshooting steps above
4. Ask for help with the specific error message you're seeing
