#!/bin/bash
# start-services.sh - Script to start ZooKeeper and Solr nodes

BASE_DIR=$(pwd)

# Start ZooKeeper
echo "Starting ZooKeeper..."
$BASE_DIR/zookeeper/bin/zkServer.sh start

# Wait for ZooKeeper to start
sleep 5

# Start Solr nodes
echo "Starting Solr nodes..."
for i in $(seq 1 2); do
    NODE_DIR=$BASE_DIR/solr-nodes/node$i
    PORT=$((8983 + $i - 1))
    echo "Starting Solr node $i on port $PORT..."
    $NODE_DIR/bin/solr start -c -p $PORT -z localhost:2181
done

echo "All services started!"
echo "Solr node 1: http://localhost:8983/solr/"
echo "Solr node 2: http://localhost:8984/solr/"