#!/bin/bash

output_file="repositories.txt"

# Source the environment variables from the specified .env file
source /home/oloo/Documents/utils/.env

# Check if GIT_USERNAME is set and not empty
if [ -z "$GITHUB_USERNAME" ]; then
    echo "Error: GIT_USERNAME is not set. Please check your .env file."
    exit 1
fi

is_git_repo() {
    git -C "$1" rev-parse > /dev/null 2>&1
}

is_repo_owned_by_user() {
    local directory="$1"
    local username="$2"
    local remote_url=$(git -C "$directory" config --get remote.origin.url)
    
    if [[ "$remote_url" == *"$username"* ]]; then
        return 0
    else
        return 1
    fi
}

is_repo_in_file() {
    local directory="$1"
    grep -qxF "$directory" "$output_file"
}

scan_for_git_repos() {
    local directory="$1"
    local username="$2"

    for dir in "$directory"/*; do 
        if [[ -d "$dir" ]]; then
            if is_git_repo "$dir"; then
                if is_repo_owned_by_user "$dir" "$username"; then
                    if ! is_repo_in_file "$dir"; then
                        echo "Git repository owned by $username found: $dir"
                        echo "$dir" >> "$output_file"
                    fi
                fi
            else
                scan_for_git_repos "$dir" "$username"
            fi
        fi
    done
}

scan_for_git_repos "$HOME" "$GITHUB_USERNAME"
