#!/bin/bash

# Check if a filename is provided as an argument
#if [ -z "$1" ]; then
#  echo "Usage: $0 <filename>"
#  echo "Example: $0 mcp_bigquery.py"
#  exit 1
#fi

# Ensure the USER environment variable is set
if [ -z "$USER" ]; then
  echo "Error: The USER environment variable is not set."
  exit 1
fi

FILE_TO_MODIFY="mcp_bigquery.py"
USERNAME="${USER}" # Get the current user's username from the environment

# Check if the file exists
if [ ! -f "$FILE_TO_MODIFY" ]; then
  echo "Error: File '$FILE_TO_MODIFY' not found."
  exit 1
fi

echo "Modifying file: '$FILE_TO_MODIFY'"
echo "Appending username '$USERNAME' to 'fintrac_prod' string."

# Use sed to find and replace the string
# The -i option modifies the file in place.
# The 's/fintrac_prod/fintrac_prod${USERNAME}/g' command performs the substitution.
# 'g' ensures all occurrences on a line are replaced.
sed -i "s/fintrac_prod/fintrac_prod_${USERNAME}/g" "$FILE_TO_MODIFY"

echo "Modification complete."
echo "You can check the file '$FILE_TO_MODIFY' to see the changes."
echo ""
echo ""
echo "********************************************************************************"
echo "*** Your database will be called:                                            ***"
echo "***   fintrac_prod_$USERNAME"
echo "********************************************************************************"
echo ""
echo ""
