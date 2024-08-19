#!/bin/bash

# GitHub credentials
GIT_USERNAME="Olooce"
GIT_PASSWORD="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"

# Repository paths
REPO_PATHS=(
  "/home/oloo/IdeaProjects/JavaSeedSpeedTest"
  "/home/oloo/IdeaProjects/MultithreadingConnectionPools"
  "/home/oloo/IdeaProjects/ORM-BasedMassDataGenerator"
  "/home/oloo/IdeaProjects/MWM_PMS-BackEndAPI"
  "/home/oloo/IdeaProjects/MWM_PMS-API"
  "/home/oloo/IdeaProjects/simple_survey_api"
  "/home/oloo/Code/Flutter/mwm_pms_desktopapp"
  "/home/oloo/Code/Flutter/first_app"
  "/home/oloo/Code/Flutter/basic_quiz_app"
  "/home/oloo/Code/Flutter/expense_tracker"
  "/home/oloo/Code/NodeJS/mwm-pms-web-react-ui-decluttered"
  "/home/oloo/Code/LeetCode"
  "/home/oloo/Code/DemoRPC"
  "/home/oloo/Code/Flutter/sky_survey_app"
  "/home/oloo/Code/Flutter/simple_survey_client"
)

# Loop through each repo path
for REPO_PATH in "${REPO_PATHS[@]}"; do
  echo "Processing repository: $REPO_PATH"

  # Change to the repository directory
  cd "$REPO_PATH" || { echo "Failed to cd into $REPO_PATH"; continue; }

  # Fetch the current remote URL and format it with credentials
  REMOTE_URL="https://$GIT_USERNAME:$GIT_PASSWORD@$(git config --get remote.origin.url | sed -e 's/^https:\/\///')"

  # Special cases for repositories with updated URLs
  case "$(basename "$REPO_PATH")" in
    "sky_survey_app")
      REMOTE_URL="https://${GIT_USERNAME}:${GIT_PASSWORD}@github.com/${GIT_USERNAME}/simple_survey_client.git"
      ;;
  esac

  # Set the GitHub remote URL with embedded credentials
  git remote set-url origin "$REMOTE_URL"

  # Print the updated remote URL
  echo "Updated remote URL: $REMOTE_URL"

  # Fetch the latest changes from the remote
  if ! git fetch origin; then
    echo "Failed to fetch from remote. The repository might not exist or the URL might be incorrect."
    echo "Skipping repository: $REPO_PATH"
    echo "-----------------------------"
    continue
  fi

  # Determine the default branch (master or main)
  DEFAULT_BRANCH=$(git remote show origin | grep 'HEAD branch' | awk '{print $NF}')

  if [ -z "$DEFAULT_BRANCH" ]; then
    echo "Failed to determine default branch for $REPO_PATH"
    echo "Skipping repository: $REPO_PATH"
    echo "-----------------------------"
    continue
  fi

  # Check if local is ahead or behind remote
  LOCAL_DIFF=$(git log HEAD..origin/"$DEFAULT_BRANCH" --oneline)
  REMOTE_DIFF=$(git log origin/"$DEFAULT_BRANCH"..HEAD --oneline)

  if [ -n "$REMOTE_DIFF" ]; then
    echo "Remote branch has commits not in the local branch. Pulling remote changes..."

    # Pull remote changes into local
    git pull --rebase origin "$DEFAULT_BRANCH" || {
      echo "Failed to pull changes. Skipping repository: $REPO_PATH"
      echo "-----------------------------"
      continue
    }
  fi

  if [ -n "$LOCAL_DIFF" ]; then
    echo "Local branch is ahead. Committing and pushing changes..."

    # Add any changes not yet staged
    git add -A

    # Commit changes
    git commit --allow-empty -m "Recommitting local changes to ensure synchronization"

    # Attempt to push changes to the remote branch
    if ! git push origin HEAD:"$DEFAULT_BRANCH"; then
      echo "Push failed. Attempting to rebase with remote changes..."
      git pull --rebase origin "$DEFAULT_BRANCH"
      git push origin HEAD:"$DEFAULT_BRANCH"
    fi
  else
    echo "Local and remote branches are up to date."
  fi

  echo "Done with repository: $REPO_PATH"
  echo "-----------------------------"
done

