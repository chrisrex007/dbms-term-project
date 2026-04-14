#!/bin/bash
# start-services.sh - Script to start ZooKeeper and Solr nodes

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BASE_DIR="$SCRIPT_DIR"
ZK_CONNECT="localhost:2181,localhost:2182,localhost:2183"

# Start ZooKeeper
echo "Starting ZooKeeper ensemble..."
for i in 1 2 3; do
  CFG="$BASE_DIR/zookeeper/conf/zoo$i.cfg"
  if [ ! -f "$CFG" ]; then
    echo "Error: Missing $CFG. Run ./setup-solr.sh first."
    exit 1
  fi
  echo "Starting ZooKeeper node $i with $CFG"
  $BASE_DIR/zookeeper/bin/zkServer.sh start "$CFG"
done

# Wait for ZooKeeper to start
sleep 5

for i in 1 2 3; do
  CFG="$BASE_DIR/zookeeper/conf/zoo$i.cfg"
  if ! $BASE_DIR/zookeeper/bin/zkServer.sh status "$CFG" >/dev/null 2>&1; then
    echo "Error: ZooKeeper node $i failed to start. Check $BASE_DIR/zookeeper/logs"
    exit 1
  fi
done

# Start Solr nodes
echo "Starting Solr nodes..."
for i in $(seq 1 2); do
    NODE_DIR=$BASE_DIR/solr-nodes/node$i
    PORT=$((8983 + $i - 1))
    echo "Starting Solr node $i on port $PORT..."
  $NODE_DIR/bin/solr start -c -p $PORT -z "$ZK_CONNECT"
done

echo "Waiting for Solr to stabilize..."
sleep 10

echo "Creating collection..."
if curl -fsS "http://localhost:8983/solr/admin/collections?action=LIST&wt=json" | grep -q '"searchcore"'; then
    echo "Collection 'searchcore' already exists, skipping create_collection."
else
    $BASE_DIR/solr-nodes/node1/bin/solr create_collection \
      -c searchcore \
      -shards 2 \
      -replicationFactor 1 \
      -p 8983
fi

echo "All services started!"
echo "Solr node 1: http://localhost:8983/solr/"
echo "Solr node 2: http://localhost:8984/solr/"
echo "ZooKeeper ensemble: $ZK_CONNECT"