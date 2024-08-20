#!/bin/bash

# Function to check if a directory is a Git repository
is_git_repo() {
    git -C "$1" rev-parse > /dev/null 2>&1
}

# Scan home directory recursively for Git repositories
scan_for_git_repos() {
    local directory="$1"

    for dir in "$directory"/*; do
        # Skip if not a directory
        if [[ -d "$dir" ]]; then
            # Check if it's a Git repository
            if is_git_repo "$dir"; then
                echo "Git repository found: $dir"
            fi
            
            # Recursively scan subdirectories
            scan_for_git_repos "$dir"
        fi
    done
}

# Start scanning from the home directory
scan_for_git_repos "$HOME"
