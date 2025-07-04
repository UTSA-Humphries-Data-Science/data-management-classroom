# Data Management Classroom Environment

This GitHub Codespace provides a complete data management and analysis environment with PostgreSQL, Python, and VS Code integration.

## 🚀 Quick Start

After the Codespace loads, everything should be automatically configured. You can verify your environment with:

```bash
bash scripts/quick_check.sh
```

To try a quick demonstration:

```bash
python3 scripts/quickstart.py
```

## 📊 What's Included

### Database
- **PostgreSQL 13**: Configured for passwordless local development
- **Sample Data**: Pre-loaded employee data for practice
- **Environment Variables**: Automatic connection configuration

### Python Environment
- **Data Science Stack**: pandas, numpy, matplotlib, seaborn, scikit-learn
- **Database Integration**: psycopg2, SQLAlchemy
- **VS Code Integration**: ipykernel for notebook support

### Development Tools
- **VS Code**: Integrated development environment
- **Notebooks**: Support for .ipynb files
- **Extensions**: PostgreSQL, Python, and data science extensions
- **Sample Files**: Ready-to-use datasets and notebooks

## 📁 Workspace Structure

```
data-management-classroom/
├── data/
│   ├── raw/          # Raw data files (CSV, JSON, etc.)
│   └── processed/    # Cleaned and processed data
├── notebooks/        # Jupyter notebooks for analysis
├── scripts/          # Python scripts and utilities
├── databases/        # Database schemas and SQL files
├── labs/             # Lab assignments
├── assignments/      # Course assignments
├── projects/         # Student projects
├── personal/         # Personal workspace
└── shared-data/      # Shared datasets
```

## 🗄️ Database Usage

### Connect via Command Line
```bash
psql -h localhost -U vscode -d vscode
```

### Connect via Python
```python
import pandas as pd
from sqlalchemy import create_engine

# Using SQLAlchemy (recommended)
engine = create_engine('postgresql://vscode@localhost:5432/vscode')
df = pd.read_sql("SELECT * FROM your_table", engine)
```

### Environment Variables
These are automatically configured:
```bash
PGDATABASE=vscode
PGUSER=vscode
PGHOST=localhost
PGPORT=5432
```

## 💻 Using VS Code Notebooks

1. **Create a new notebook**: File → New File → Select "Jupyter Notebook"
2. **Open existing notebook**: Navigate to `notebooks/getting-started.ipynb`
3. **Select Python kernel**: Click on kernel selector and choose Python 3.11
4. **Run cells**: Use Shift+Enter or click the run button

## 🛠️ Troubleshooting

### Database Issues
```bash
# Check PostgreSQL status
sudo service postgresql status

# Restart PostgreSQL
sudo service postgresql restart

# Recreate database connection
python3 scripts/fix_postgres.sh
```

### Python Package Issues
```bash
# Install missing packages
pip install --user package_name

# Reinstall all packages
pip install --user -r requirements.txt
```

### Environment Reset
```bash
# Run post-start setup
bash .devcontainer/post-start-simple.sh

# Reload environment variables
source ~/.bashrc
```

## 📚 Learning Resources

### Sample Notebooks
- `notebooks/getting-started.ipynb` - Environment overview and basic operations
- (Add more as you create them)

### Sample Scripts
- `scripts/quickstart.py` - Demonstrates database and data analysis
- `scripts/quick_check.sh` - Environment verification
- `scripts/test_setup.py` - Comprehensive testing

### Sample Data
- `data/raw/sample.csv` - Employee dataset for practice
- Database tables: `employees`, `employees_csv`

## 🎯 Common Tasks

### Loading CSV Data
```python
import pandas as pd
df = pd.read_csv('data/raw/your_file.csv')
```

### Database Operations
```python
from sqlalchemy import create_engine
engine = create_engine('postgresql://vscode@localhost:5432/vscode')

# Read from database
df = pd.read_sql("SELECT * FROM table_name", engine)

# Write to database
df.to_sql('new_table', engine, if_exists='replace', index=False)
```

### Data Visualization
```python
import matplotlib.pyplot as plt
import seaborn as sns

# Basic plotting
df.plot(kind='scatter', x='column1', y='column2')
plt.show()

# Seaborn styling
sns.scatterplot(data=df, x='column1', y='column2')
plt.show()
```

## 🔧 Maintenance

The environment is designed to be self-maintaining, but you can manually run setup scripts if needed:

```bash
# Full setup (run during container creation)
bash .devcontainer/setup_simple.sh

# Post-start setup (run when container starts)
bash .devcontainer/post-start-simple.sh
```

## 🆘 Getting Help

1. **Check environment**: `bash scripts/quick_check.sh`
2. **Run diagnostics**: `python3 scripts/test_setup.py`
3. **View logs**: Check VS Code terminal for error messages
4. **Reset environment**: Restart the Codespace

## 📝 Notes

- The database uses "trust" authentication for local connections (safe in containerized environment)
- All Python packages are installed in user space (`~/.local/`)
- Environment variables are automatically loaded in new terminal sessions
- The setup is optimized for GitHub Codespaces and may need adjustment for other environments

Happy data analysis! 🎉
