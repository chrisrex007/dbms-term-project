#!/bin/bash

# Use the provided URL as the base URL.
BASE_URL="http://localhost:8983/solr"
CORE_URL="${BASE_URL}/searchcore"  # Adjust this if necessary.
OUTPUT_DIR="./benchmark_results"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="${OUTPUT_DIR}/siege_results.json"
QUERY_ENDPOINT="/select?q=TCP"

mkdir -p $OUTPUT_DIR

# Array of concurrent users to test
CONCURRENT_USERS=(2 3 5 7 11 13 17 19 23 29 79 83 89 97)
# Test duration in seconds
DURATION=3

echo "Starting benchmark tests against $CORE_URL"
echo "Results will be saved to $OUTPUT_FILE"

# Initialize JSON output - write to a temporary file first
TEMP_FILE="${OUTPUT_DIR}/temp_results_${TIMESTAMP}.json"

echo "{" > $TEMP_FILE
echo "  \"benchmark_timestamp\": \"$(date -u +"%Y-%m-%dT%H:%M:%SZ")\"," >> $TEMP_FILE
echo "  \"solr_url\": \"$CORE_URL\"," >> $TEMP_FILE
echo "  \"results\": [" >> $TEMP_FILE

first_entry=true

for USERS in "${CONCURRENT_USERS[@]}"; do
  echo "Running test with $USERS concurrent users for $DURATION seconds..."
  
  # Run siege and capture both stdout and stderr
  SIEGE_OUTPUT=$(siege -c $USERS -t${DURATION}S -b "${CORE_URL}${QUERY_ENDPOINT}" 2>&1)

  # echo "Siege output for ${USERS} users:"
  # echo "$SIEGE_OUTPUT"

  # Extract key metrics using grep and awk, and ensure they're clean numbers
  TRANSACTIONS=$(echo "$SIEGE_OUTPUT" | grep -i '"transactions":' | awk -F: '{print $2}' | tr -d ', ')
  AVAILABILITY=$(echo "$SIEGE_OUTPUT" | grep -i '"availability":' | awk -F: '{print $2}' | tr -d ', ')
  ELAPSED_TIME=$(echo "$SIEGE_OUTPUT" | grep -i '"elapsed_time":' | awk -F: '{print $2}' | tr -d ', ')
  RESPONSE_TIME=$(echo "$SIEGE_OUTPUT" | grep -i '"response_time":' | awk -F: '{print $2}' | tr -d ', ')
  TRANSACTION_RATE=$(echo "$SIEGE_OUTPUT" | grep -i '"transaction_rate":' | awk -F: '{print $2}' | tr -d ', ')
  THROUGHPUT=$(echo "$SIEGE_OUTPUT" | grep -i '"throughput":' | awk -F: '{print $2}' | tr -d ', ')
  CONCURRENCY=$(echo "$SIEGE_OUTPUT" | grep -i '"concurrency":' | awk -F: '{print $2}' | tr -d ', ')
  SUCCESSFUL_TRANSACTIONS=$(echo "$SIEGE_OUTPUT" | grep -i '"successful_transactions":' | awk -F: '{print $2}' | tr -d ', ')
  FAILED_TRANSACTIONS=$(echo "$SIEGE_OUTPUT" | grep -i '"failed_transactions":' | awk -F: '{print $2}' | tr -d ', ')
  
  # Check if any values are empty and set to 0 if they are
  TRANSACTIONS=${TRANSACTIONS:-0}
  AVAILABILITY=${AVAILABILITY:-0}
  ELAPSED_TIME=${ELAPSED_TIME:-0}
  RESPONSE_TIME=${RESPONSE_TIME:-0}
  TRANSACTION_RATE=${TRANSACTION_RATE:-0}
  THROUGHPUT=${THROUGHPUT:-0}
  CONCURRENCY=${CONCURRENCY:-0}
  SUCCESSFUL_TRANSACTIONS=${SUCCESSFUL_TRANSACTIONS:-0}
  FAILED_TRANSACTIONS=${FAILED_TRANSACTIONS:-0}
  
  # Add comma separator if not the first entry
  if [ "$first_entry" = true ]; then
    first_entry=false
  else
    echo "    ," >> $TEMP_FILE
  fi
  
  # Add result entry to JSON
  cat << EOF >> $TEMP_FILE
    {
      "concurrent_users": $USERS,
      "duration_seconds": $DURATION,
      "transactions": $TRANSACTIONS,
      "availability": $AVAILABILITY,
      "elapsed_time": $ELAPSED_TIME,
      "response_time": $RESPONSE_TIME,
      "transaction_rate": $TRANSACTION_RATE,
      "throughput": $THROUGHPUT,
      "concurrency": $CONCURRENCY,
      "successful_transactions": $SUCCESSFUL_TRANSACTIONS,
      "failed_transactions": $FAILED_TRANSACTIONS
    }
EOF

  # Short pause between tests
  sleep 2
done

# Finish JSON structure
echo "  ]" >> $TEMP_FILE
echo "}" >> $TEMP_FILE

# Validate the JSON before finalizing
if command -v jq &> /dev/null; then
    # If jq is available, use it to validate and prettify
    jq . $TEMP_FILE > $OUTPUT_FILE
    if [ $? -ne 0 ]; then
        echo "ERROR: Generated JSON is invalid. Check the temp file at $TEMP_FILE"
        exit 1
    fi
else
    # If jq is not available, just move the temp file
    mv $TEMP_FILE $OUTPUT_FILE
fi

echo "Benchmark complete. Results saved to $OUTPUT_FILE"
echo "You can now visualize these results with: python3 visualize.py $OUTPUT_FILE"

# Echo the content of the JSON file for debugging
echo "JSON file content preview:"
head -n 20 $OUTPUT_FILE

# Activate Python environment and run post-processing
echo "Activating Python virtual environment..."
source ~/solr-project/bin/activate

echo "Running visualization script..."
python3 visualize.py ./benchmark_results/siege_results.json

echo "Running add_to_website script..."
python3 add_to_website.py

echo "All tasks completed successfully."
