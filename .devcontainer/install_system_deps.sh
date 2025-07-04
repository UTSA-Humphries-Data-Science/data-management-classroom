#!/bin/bash

# Install system dependencies needed for R packages
echo "🔧 Installing system dependencies for R packages..."

# Update package list
sudo apt-get update -qq

# Install essential system libraries for R packages
echo "📦 Installing system libraries..."
sudo apt-get install -y \
    libharfbuzz-dev \
    libfribidi-dev \
    libudunits2-dev \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    cmake \
    libabsl-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libxml2-dev \
    libfontconfig1-dev \
    libfreetype6-dev

echo "✅ System dependencies installation complete!"
