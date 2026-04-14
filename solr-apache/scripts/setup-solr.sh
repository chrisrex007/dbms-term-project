#!/bin/bash

set -euo pipefail

# Configuration variables
SOLR_VERSION="9.3.0"
ZOOKEEPER_VERSION="3.8.1"
NUM_SOLR_NODES=2
JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"  # Adjust as needed
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
BASE_DIR="$SCRIPT_DIR"
ZK_CONNECT="localhost:2181,localhost:2182,localhost:2183"

# Check for Java
if ! command -v java &> /dev/null; then
    echo "Java is not installed. Please install Java 11 or later."
    exit 1
fi

# Create directories
mkdir -p $BASE_DIR/downloads
mkdir -p $BASE_DIR/solr-nodes
mkdir -p $BASE_DIR/zookeeper

# Download Solr
if [ ! -f "$BASE_DIR/downloads/solr-$SOLR_VERSION.tgz" ]; then
    echo "Downloading Solr $SOLR_VERSION..."
    curl -o $BASE_DIR/downloads/solr-$SOLR_VERSION.tgz https://archive.apache.org/dist/solr/solr/$SOLR_VERSION/solr-$SOLR_VERSION.tgz
fi

# Download ZooKeeper
if [ ! -f "$BASE_DIR/downloads/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz" ]; then
    echo "Downloading ZooKeeper $ZOOKEEPER_VERSION..."
    curl -o $BASE_DIR/downloads/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz https://archive.apache.org/dist/zookeeper/zookeeper-$ZOOKEEPER_VERSION/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz
fi

# Extract Solr
echo "Extracting Solr..."
tar xzf $BASE_DIR/downloads/solr-$SOLR_VERSION.tgz -C $BASE_DIR/downloads

# Extract ZooKeeper
echo "Extracting ZooKeeper..."
tar xzf $BASE_DIR/downloads/apache-zookeeper-$ZOOKEEPER_VERSION-bin.tar.gz -C $BASE_DIR/downloads

# Set up ZooKeeper
echo "Setting up ZooKeeper..."
cp -r $BASE_DIR/downloads/apache-zookeeper-$ZOOKEEPER_VERSION-bin/* $BASE_DIR/zookeeper/
mkdir -p $BASE_DIR/zookeeper/data

# Build a local 3-node ZooKeeper ensemble.
# Each node has its own config, dataDir, clientPort, and myid.
for i in 1 2 3; do
    CLIENT_PORT=$((2180 + i))
    PEER_PORT=$((2887 + i))
    ELECTION_PORT=$((3887 + i))
    NODE_DATA_DIR="$BASE_DIR/zookeeper/data/zk$i"
    NODE_CFG="$BASE_DIR/zookeeper/conf/zoo$i.cfg"

    mkdir -p "$NODE_DATA_DIR"
    echo "$i" > "$NODE_DATA_DIR/myid"

    cat > "$NODE_CFG" << EOF
tickTime=2000
initLimit=10
syncLimit=5
dataDir=$NODE_DATA_DIR
clientPort=$CLIENT_PORT
server.1=127.0.0.1:2888:3888
server.2=127.0.0.1:2889:3889
server.3=127.0.0.1:2890:3890
EOF
done

# Keep zoo.cfg aligned with node-1 for tools that default to this filename.
cp "$BASE_DIR/zookeeper/conf/zoo1.cfg" "$BASE_DIR/zookeeper/conf/zoo.cfg"

# Create Solr nodes
for i in $(seq 1 $NUM_SOLR_NODES); do
    echo "Setting up Solr node $i..."
    NODE_DIR=$BASE_DIR/solr-nodes/node$i
    mkdir -p $NODE_DIR
    cp -r $BASE_DIR/downloads/solr-$SOLR_VERSION/* $NODE_DIR/
    
    # Configure Solr to use ZooKeeper
    cp $BASE_DIR/solr-config/solr.xml $NODE_DIR/server/solr/
done

echo "Local ZooKeeper ensemble configured at: $ZK_CONNECT"
echo "Setup complete! Start ZooKeeper and Solr nodes to begin."