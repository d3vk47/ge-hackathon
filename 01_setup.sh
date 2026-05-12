#!/bin/bash

# Define the maximum allowed length for the agent name
MAX_AGENT_NAME_LENGTH=26
AGENT_BASE_PREFIX="fintrac-detector" # The fixed part of your agent name
STUDENT_PREFIX="student_"             # The prefix expected in your USER variable

# Ensure the USER environment variable is set
if [ -z "$USER" ]; then
  echo "Error: The USER environment variable is not set. Please ensure it's configured in your environment."
  exit 1
fi

# --- Extract the desired part from the USER variable ---
if [[ "$USER" == "$STUDENT_PREFIX"* ]]; then
  USER_SUFFIX="${USER#$STUDENT_PREFIX}"
  if [ -z "$USER_SUFFIX" ]; then
    echo "Error: USER variable starts with '$STUDENT_PREFIX' but no suffix found."
    echo "Expected format: 'student_yourname'."
    exit 1
  fi
  echo "Extracted user suffix from '$USER': '$USER_SUFFIX'"
else
  echo "Error: USER variable '$USER' does not start with '$STUDENT_PREFIX'."
  echo "This script expects a username in the format 'student_yourname'."
  exit 1
fi

# Calculate the maximum length allowed for the extracted user suffix
MAX_SUFFIX_LENGTH_FOR_AGENT=$((MAX_AGENT_NAME_LENGTH - ${#AGENT_BASE_PREFIX} - 1))
if [ "$MAX_SUFFIX_LENGTH_FOR_AGENT" -lt 0 ]; then
  MAX_SUFFIX_LENGTH_FOR_AGENT=0 # Ensures we don't try to get a negative substring length
fi

# Truncate the extracted USER_SUFFIX if it's longer than allowed
TRUNCATED_USER_SUFFIX="${USER_SUFFIX:0:$MAX_SUFFIX_LENGTH_FOR_AGENT}"

# Construct the full agent name (this is the logical name for 'agents-cli create')
AGENT_FULL_NAME="${AGENT_BASE_PREFIX}_${TRUNCATED_USER_SUFFIX}"

echo "Calculated agent name (for CLI): $AGENT_FULL_NAME (Length: ${#AGENT_FULL_NAME})"

# Final validation (should pass due to truncation logic)
if [ ${#AGENT_FULL_NAME} -gt $MAX_AGENT_NAME_LENGTH ]; then
  echo "Error: The generated agent name '$AGENT_FULL_NAME' still exceeds $MAX_AGENT_NAME_LENGTH characters."
  echo "This indicates a logical error in the length calculation or truncation."
  exit 1
fi

# --- Determine the actual directory name by replacing underscores with hyphens ---
# This line performs the replacement. ${variable//pattern/replacement}
DIRECTORY_NAME="${AGENT_FULL_NAME//_/-}"
echo "Calculated directory name (on filesystem): $DIRECTORY_NAME"

# --- Start of user's original script logic, adapted ---

# Install the Agents CLI (usually a one-time setup, uncomment if you need it every time)
# uvx google-agents-cli setup

# Scaffold a new high-code agent
echo "Scaffolding agent '$AGENT_FULL_NAME'..."
agents-cli create "$AGENT_FULL_NAME" -y --deployment-target agent_runtime

# Check if agent creation was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to create agent '$AGENT_FULL_NAME'. Please review the output above for details."
  exit 1
fi

# Change into the agent's directory using the hyphenated name
echo "Changing directory to '$DIRECTORY_NAME'..."
cd "$DIRECTORY_NAME" || { echo "Error: Failed to change directory to '$DIRECTORY_NAME'. Does the directory exist or is the naming convention different?"; exit 1; }

# Add BigQuery to the project dependencies (Critical for Cloud Run deployment)
echo "Adding BigQuery dependency..."
uv add google-cloud-bigquery

echo ""
echo ""
echo "********************************************************************************"
echo "***   Agent '$AGENT_FULL_NAME' successfully created and configured."
echo "***   You are now in the agent's project directory: $(pwd)"
echo "********************************************************************************"
echo ""
echo ""
