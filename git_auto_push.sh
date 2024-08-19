#!/bin/bash

source /home/oloo/Documents/utils/.env

# Array of repository paths
REPO_PATHS=(
  "/home/oloo/IdeaProjects/JavaSeedSpeedTest"
  "/home/oloo/IdeaProjects/MultithreadingConnectionPools"
  "/home/oloo/IdeaProjects/ORM-BasedMassDataGenerator"
  "/home/oloo/IdeaProjects/Populate_MWM-PMS"
  "/home/oloo/IdeaProjects/MWM_PMS-BackEndAPI"
  "/home/oloo/IdeaProjects/MWM_PMS-API"
  "/home/oloo/IdeaProjects/mwm_pms"
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
  "/home/oloo/Documents/utils"
)

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

# Loop through each repository
for REPO_PATH in "${REPO_PATHS[@]}"; do
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
done

