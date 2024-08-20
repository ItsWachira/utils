#!/bin/bash

# Output file
output_file="repositories.txt"

# Function to check if a directory is a Git repository
is_git_repo() {
    git -C "$1" rev-parse > /dev/null 2>&1
}

# Function to check if the repo is owned by the specified username
is_repo_owned_by_user() {
    local directory="$1"
    local username="$2"

    # Get the remote origin URL
    local remote_url=$(git -C "$directory" config --get remote.origin.url)

    # Check if the remote URL contains the username
    if [[ "$remote_url" == *"$username"* ]]; then
        return 0  # true
    else
        return 1  # false
    fi
}

# Function to check if a repository is already recorded in the output file
is_repo_in_file() {
    local directory="$1"

    # Check if the directory path is already in the file
    grep -qxF "$directory" "$output_file"
}

# Scan home directory recursively for Git repositories
scan_for_git_repos() {
    local directory="$1"
    local username="$2"

    for dir in "$directory"/*; do
        # Skip if not a directory
        if [[ -d "$dir" ]]; then
            # Check if it's a Git repository
            if is_git_repo "$dir"; then
                # Check if the repository is owned by the specified username
                if is_repo_owned_by_user "$dir" "$username"; then
                    # Check if the repository is already in the output file
                    if ! is_repo_in_file "$dir"; then
                        echo "Git repository owned by $username found: $dir"
                        echo "$dir" >> "$output_file"
                    fi
                fi
            else
                # Recursively scan subdirectories
                scan_for_git_repos "$dir" "$username"
            fi
        fi
    done
}

# Start scanning from the home directory, looking for repos owned by "Olooce"
scan_for_git_repos "$HOME" "Olooce"
