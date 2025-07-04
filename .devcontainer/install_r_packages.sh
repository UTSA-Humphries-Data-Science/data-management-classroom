#!/bin/bash

echo "📊 Installing R packages for data science classroom..."

# Check if R is available
if ! command -v R &> /dev/null; then
    echo "❌ R is not installed. Install R first with: sudo apt-get install -y r-base r-base-dev"
    exit 1
fi

# Essential R packages for data science and database work
R --slave --no-restore --no-save -e "
options(repos = c(CRAN = 'https://cloud.r-project.org/'))
options(timeout = 120)

# Core packages needed for the classroom
essential_packages <- c(
    'languageserver',  # For VS Code R support
    'jsonlite',        # JSON handling
    'httr',           # HTTP requests
    'IRkernel'        # Jupyter R kernel
)

# Data science packages
data_packages <- c(
    'dplyr',
    'tidyr', 
    'ggplot2',
    'readr',
    'DBI',
    'RPostgreSQL',
    'dbplyr',
    'knitr',
    'rmarkdown'
)

# Function to safely install packages
safe_install <- function(packages, description) {
    cat('Installing', description, 'packages...\n')
    for (pkg in packages) {
        cat('Installing', pkg, '...')
        tryCatch({
            if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
                install.packages(pkg, dependencies = TRUE, quiet = TRUE)
                cat(' ✅\n')
            } else {
                cat(' (already installed)\n')
            }
        }, error = function(e) {
            cat(' ❌ Failed:', e\$message, '\n')
        })
    }
}

# Install packages in order of importance
safe_install(essential_packages, 'essential')
safe_install(data_packages, 'data science')

cat('\n📊 R packages installation completed!\n')

# Try to install Jupyter R kernel
tryCatch({
    library(IRkernel)
    IRkernel::installspec(user = FALSE)
    cat('✅ R kernel for Jupyter installed\n')
}, error = function(e) {
    cat('⚠️ R kernel installation failed\n')
})
"

echo "✅ R packages installation script completed"