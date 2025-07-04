# Database Connection Guide

## Password Setup Summary

The setup includes multiple database connection options depending on your environment:

### 🐳 Docker Setup (Recommended)
- **Username**: `student`
- **Password**: `student_password`
- **Database**: `postgres`
- **Host**: `localhost`
- **Port**: `5432`

**To start:**
```bash
docker run -d --name classroom-db -p 5432:5432 \
  -e POSTGRES_USER=student \
  -e POSTGRES_PASSWORD=student_password \
  -e POSTGRES_DB=postgres \
  postgres:15
```

### 🖥️ Local PostgreSQL Setup
- **Username**: `student` or `vscode`
- **Password**: None (trust authentication)
- **Database**: `postgres`
- **Host**: `localhost`
- **Port**: `5432`

**To configure (requires admin access):**
```bash
bash scripts/fix_database_connection.sh
```

### ☁️ External Database
Use your cloud provider's database credentials (AWS RDS, Google Cloud SQL, etc.)

## Testing Connections

### Quick Test
```bash
python scripts/test_connection.py
```

### Detailed Test
```bash
python scripts/test_connection_advanced.py
```

### Simple Test (for local setup)
```bash
python scripts/test_connection_simple.py
```

## Manual Connection Examples

### Using psql (PostgreSQL command line)

**Docker setup:**
```bash
psql -h localhost -U student -d postgres
# Enter password: student_password
```

**Local setup:**
```bash
psql -h localhost -U student -d postgres
# No password required
```

### Using Python

**Docker setup:**
```python
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    database="postgres",
    user="student",
    password="student_password",
    port="5432"
)
```

**Local setup:**
```python
import psycopg2
conn = psycopg2.connect(
    host="localhost",
    database="postgres",
    user="student",
    port="5432"
)
```

## Troubleshooting

### No Database Running
- **Error**: `Connection refused`
- **Solution**: Start a database using one of the methods above

### Authentication Failed
- **Error**: `password authentication failed`
- **Solution**: Check if you're using the correct password for your setup type

### User/Role Does Not Exist
- **Error**: `role "username" does not exist`
- **Solution**: The database user hasn't been created yet

### Permission Denied
- **Error**: `permission denied`
- **Solution**: The user exists but doesn't have proper permissions

## Available Scripts

- `scripts/start_database.sh` - Start Docker database
- `scripts/test_connection.py` - Test database connection
- `scripts/test_connection_advanced.py` - Advanced connection testing
- `scripts/test_connection_simple.py` - Simple connection test
- `scripts/fix_database_connection.sh` - Configure local PostgreSQL
- `scripts/setup_local_postgres.sh` - Install and setup local PostgreSQL

## Default Credentials Quick Reference

| Setup Type | Username | Password | Database |
|------------|----------|----------|----------|
| Docker | `student` | `student_password` | `postgres` |
| Local | `student` | None | `postgres` |
| External | Your choice | Your choice | Your choice |
