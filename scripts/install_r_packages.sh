#!/bin/bash
echo "📊 Installing R packages for data science..."

if ! command -v R &> /dev/null; then
    echo "❌ R not found. Installing R first..."
    sudo apt-get update -qq
    sudo apt-get install -y r-base
fi

# Function to install R packages with aggressive timeout
install_r_package() {
    local package=$1
    echo "📦 Installing $package..."
    timeout 90 sudo R --slave --vanilla -e "
    options(repos='https://cloud.r-project.org/', timeout=60)
    tryCatch({
        if(!require('$package', character.only=TRUE, quietly=TRUE)) {
            install.packages('$package', dependencies=FALSE, quiet=TRUE)
            if(require('$package', character.only=TRUE, quietly=TRUE)) {
                cat('✅ $package installed successfully\n')
            } else {
                cat('❌ $package installation failed\n')
            }
        } else {
            cat('✅ $package already available\n')
        }
    }, error=function(e) {
        cat('❌ $package failed:', as.character(e), '\n')
    })
    " 2>/dev/null || echo "⚠️ $package installation timed out"
}

# Install packages one by one to avoid hanging
echo "🔄 Installing essential packages first..."
install_r_package "DBI"
install_r_package "RPostgreSQL" 

echo "🔄 Installing data manipulation packages..."
install_r_package "dplyr"
install_r_package "readr"

echo "🔄 Installing visualization packages..."
install_r_package "ggplot2"

echo ""
echo "📊 R package installation complete!"
echo "💡 To test R packages:"
echo "   R -e \"library(DBI); library(RPostgreSQL)\""
echo "   R -e \"library(dplyr); library(ggplot2)\""
