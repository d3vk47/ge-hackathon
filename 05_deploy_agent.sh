#!/bin/bash

# --- Function to check if a command exists ---
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# --- 1. Get the current Google Cloud Project ID ---
echo "Detecting current Google Cloud project..."
if ! command_exists gcloud; then
  echo "Error: 'gcloud' CLI not found. Please install and configure Google Cloud SDK."
  echo "You can find instructions at: https://cloud.google.com/sdk/docs/install"
  exit 1
fi

CURRENT_PROJECT=$(gcloud config get-value project)

if [ -z "$CURRENT_PROJECT" ]; then
  echo "Error: No Google Cloud project is currently set in your gcloud configuration."
  echo "Please set a default project using: 'gcloud config set project YOUR_PROJECT_ID'"
  exit 1
fi

echo "Google Cloud Project detected: $CURRENT_PROJECT"

# --- 2. Get the current OS username ---
CURRENT_USER="${USER}"
if [ -z "$CURRENT_USER" ]; then
  echo "Warning: Could not determine current OS username from \$USER environment variable."
  CURRENT_USER="unknown_user"
fi
echo "Current OS User: $CURRENT_USER"

# --- 3. Deploy the agent to the current Google Cloud Project ---
echo "Checking for 'agents-cli'..."
if ! command_exists agents-cli; then
  echo "Error: 'agents-cli' not found. Please ensure the Agents CLI is installed and in your PATH."
  echo "You might need to run 'uvx google-agents-cli setup' or similar if not already done."
  exit 1
fi

echo ""
echo "Attempting to deploy the agent to Google Cloud Project: '$CURRENT_PROJECT'"
echo "The agent being deployed is the one defined in your current directory."
echo "Note: The deployed agent's name will be based on its definition, not directly modified with '_$CURRENT_USER' by this deploy command."
echo "      If you want a user-specific agent ID, it typically needs to be created with that ID first."
echo ""

# Execute the deployment command
agents-cli deploy --project "$CURRENT_PROJECT"

if [ $? -eq 0 ]; then
  echo ""
  echo "Agent deployment command initiated successfully to project '$CURRENT_PROJECT'."
  echo "Please check the console for deployment progress and status."
else
  echo ""
  echo "Error: Agent deployment command failed. Please review the output above for details."
  exit 1
fi
