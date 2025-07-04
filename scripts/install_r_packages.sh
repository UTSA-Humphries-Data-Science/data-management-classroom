#!/bin/bash
echo "📊 Installing complete R packages..."
sudo R -e "
packages <- c('DBI', 'RPostgreSQL', 'dplyr', 'ggplot2', 'readr')
for(pkg in packages) {
    tryCatch({
        if(!require(pkg, character.only=TRUE, quietly=TRUE)) {
            install.packages(pkg, repos='https://cloud.r-project.org/')
        }
        cat('✅', pkg, 'ready\n')
    }, error=function(e) cat('❌', pkg, 'failed\n'))
}
"
