#!/bin/bash

# Ensure the USER environment variable is set
if [ -z "$USER" ]; then
  echo "Error: The USER environment variable is not set."
  exit 1
fi

# Define the full BigQuery dataset name including the user's ID
DATASET_NAME="fintrac_prod_${USER}"
TABLE_NAME="${DATASET_NAME}.transactions"
CSV_FILE="./fintrac_batch.csv"

echo "Generating batch data..."
python generate_batch.py

echo "Creating BigQuery dataset: ${DATASET_NAME}..."
# Check if the dataset already exists to avoid errors, or just let bq mk handle it
# bq mk will error if it exists, which is often desired behavior to prevent overwriting
bq mk "${DATASET_NAME}"

echo "Loading data into BigQuery table: ${TABLE_NAME} from ${CSV_FILE}..."
bq load \
  --source_format=CSV \
  --autodetect \
  "${TABLE_NAME}" \
  "${CSV_FILE}"

echo "Batch processing complete."