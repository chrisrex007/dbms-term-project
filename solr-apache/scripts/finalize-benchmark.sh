#!/bin/bash
# finalize-benchmark.sh - Performs a complete benchmark and creates a comprehensive report

BASE_DIR=$(pwd)
RESULTS_DIR="$BASE_DIR/benchmark/results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_DIR="$RESULTS_DIR/report_${TIMESTAMP}"
WEB_DIR="$BASE_DIR/webapp"

mkdir -p $REPORT_DIR

# Display header
echo "===================================================="
echo "   SOLR SEARCH ENGINE PERFORMANCE BENCHMARK REPORT  "
echo "===================================================="
echo "Timestamp: $(date)"
echo "Benchmark ID: ${TIMESTAMP}"
echo

# Check if Solr is running
echo "Checking Solr status..."
if ! curl -s "http://localhost:8983/solr/" > /dev/null; then
    echo "Error: Solr is not running. Please start Solr using the start-services.sh script."
    exit 1
fi

# Collect system information
echo "Collecting system information..."
echo "==== System Information ====" > $REPORT_DIR/system_info.txt
echo "OS: $(uname -s)" >> $REPORT_DIR/system_info.txt
echo "Kernel: $(uname -r)" >> $REPORT_DIR/system_info.txt
echo "CPU: $(grep "model name" /proc/cpuinfo | head -1 | cut -d ':' -f2 | sed 's/^