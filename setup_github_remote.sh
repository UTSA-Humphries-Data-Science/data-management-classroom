#!/bin/bash

# GitHub Repository Setup Script
# This script helps you connect your local repository to GitHub

echo "🚀 GitHub Repository Setup"
echo "=========================="
echo ""

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI (gh) is available"
    HAS_GH_CLI=true
else
    echo "ℹ️  GitHub CLI not available (will use manual setup)"
    HAS_GH_CLI=false
fi

echo ""
echo "Choose an option:"
echo "1. Connect to existing GitHub repository"
echo "2. Create new GitHub repository"
echo "3. Just show the manual commands"
echo ""

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo ""
        read -p "Enter your GitHub username: " username
        read -p "Enter your repository name: " reponame
        
        echo ""
        echo "Adding remote origin..."
        git remote add origin "https://github.com/$username/$reponame.git"
        
        echo "Pushing to GitHub..."
        if git push -u origin main; then
            echo ""
            echo "✅ Successfully pushed to GitHub!"
            echo "🔗 Repository URL: https://github.com/$username/$reponame"
            echo ""
            echo "Next steps:"
            echo "1. Go to your repository on GitHub"
            echo "2. Test creating a Codespace"
            echo "3. Run ./scripts/verify_deployment.sh in the Codespace"
        else
            echo ""
            echo "❌ Push failed. Please check:"
            echo "1. Repository exists and you have write access"
            echo "2. You're authenticated with GitHub"
            echo "3. Repository URL is correct"
        fi
        ;;
        
    2)
        if [ "$HAS_GH_CLI" = true ]; then
            echo ""
            read -p "Enter your desired repository name (default: data-management): " reponame
            reponame=${reponame:-data-management}
            
            echo ""
            echo "Creating repository and pushing..."
            if gh repo create "$reponame" --public --source=. --remote=origin --push; then
                echo ""
                echo "✅ Repository created and pushed successfully!"
                echo "🔗 Repository URL: $(gh repo view --json url -q .url)"
            else
                echo ""
                echo "❌ Failed to create repository. Please check your GitHub CLI authentication."
                echo "Run 'gh auth login' if needed."
            fi
        else
            echo ""
            echo "GitHub CLI not available. Please:"
            echo "1. Go to https://github.com/new"
            echo "2. Create a repository (don't initialize with README)"
            echo "3. Run this script again with option 1"
        fi
        ;;
        
    3)
        echo ""
        echo "Manual Setup Commands:"
        echo "======================"
        echo ""
        echo "For existing repository:"
        echo "git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git"
        echo "git push -u origin main"
        echo ""
        echo "For new repository (with GitHub CLI):"
        echo "gh repo create YOUR_REPO_NAME --public --source=. --remote=origin --push"
        echo ""
        ;;
        
    *)
        echo "Invalid choice. Please run the script again."
        exit 1
        ;;
esac

echo ""
echo "📋 See PUSH_TO_GITHUB.md for detailed instructions"
