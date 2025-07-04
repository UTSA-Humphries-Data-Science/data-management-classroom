# Rebuilding Your Codespace

If you encounter issues with your development environment, here are the steps to rebuild your codespace:

## Quick Fix: Restart Codespace
1. Go to your codespace
2. Click on the gear icon (⚙️) or the codespace name
3. Select "Restart Codespace"

## Full Rebuild: 
1. In VS Code, open the Command Palette (`Ctrl+Shift+P` or `Cmd+Shift+P`)
2. Type "Codespaces: Rebuild Container"
3. Select the option and confirm

## Manual R Installation (if needed)
If R is not working after rebuild, run these commands in the terminal:

```bash
# Install R
sudo apt-get update
sudo apt-get install -y r-base r-base-dev

# Install R packages
bash .devcontainer/install_r_packages.sh
```

## Check Installation Status
Run this command to verify everything is working:

```bash
bash scripts/verify_deployment.sh
```

## Common Issues

### R not found
- **Problem**: `which R` returns nothing
- **Solution**: Run the manual R installation commands above

### PostgreSQL connection issues
- **Problem**: Cannot connect to database
- **Solution**: Run `sudo service postgresql restart`

### Python packages missing
- **Problem**: Import errors for pandas, numpy, etc.
- **Solution**: Run `pip install --user -r requirements.txt`

## Getting Help
If you continue to have issues, please:
1. Check the creation log for errors
2. Contact your instructor
3. Create a new codespace as a last resort
