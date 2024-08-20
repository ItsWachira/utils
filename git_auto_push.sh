#!/bin/bash

source /home/oloo/Documents/utils/.env

# File containing repository paths
REPO_FILE="repositories.txt"

# Commit messages array
COMMITS=(
  "Update"
  "Updates"
  "More updates"
)

# Function to print a timestamp
print_timestamp() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')]"
}

# Read each line from the repositories file and process it as a repository path
while IFS= read -r REPO_PATH || [[ -n "$REPO_PATH" ]]; do
  echo "-------------------------------------------------"
  print_timestamp
  echo "Processing repository at $REPO_PATH"

  # Navigate to the repository
  cd "$REPO_PATH" || continue

  # Check for changes
  if [[ $(git status --porcelain) ]]; then
    echo "Changes detected in $REPO_PATH. Committing and pushing..."

    # Stage all changes
    git add .

    # Generate a random commit message
    random_number=$((RANDOM % ${#COMMITS[@]}))
    COMMIT_MESSAGE="${COMMITS[$random_number]}"

    # Commit the changes
    git commit -m "$COMMIT_MESSAGE"

    # Push the changes to the remote repository
    git push https://${GIT_USERNAME}:${GIT_PASSWORD}@$(git config --get remote.origin.url | sed -e 's/^https:\/\///')

    print_timestamp
    echo "Changes committed and pushed for $REPO_PATH"
  else
    print_timestamp
    echo "No changes in $REPO_PATH"
  fi

  echo "-------------------------------------------------"
  echo ""
done < "$REPO_FILE"
