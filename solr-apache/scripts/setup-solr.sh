#!/bin/bash
# setup-solr.sh - Script to set up Solr and ZooKeeper

# Configuration variables
SOLR_VERSION="9.3.0"
ZOOKEEPER_VERSION="3.8.1"
NUM_SOLR_NODES=2
JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"  # Adjust as needed
BASE_DIR=$(pwd)

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
cp $BASE_DIR/solr-config/zoo.cfg $BASE_DIR/zookeeper/conf/
mkdir -p $BASE_DIR/zookeeper/data

# Create Solr nodes
for i in $(seq 1 $NUM_SOLR_NODES); do
    echo "Setting up Solr node $i..."
    NODE_DIR=$BASE_DIR/solr-nodes/node$i
    mkdir -p $NODE_DIR
    cp -r $BASE_DIR/downloads/solr-$SOLR_VERSION/* $NODE_DIR/
    
    # Configure Solr to use ZooKeeper
    cp $BASE_DIR/solr-config/solr.xml $NODE_DIR/server/solr/
    
    # Create port-specific configuration
    PORT=$((8983 + $i - 1))
    echo "solr.port=$PORT" > $NODE_DIR/server/etc/jetty.properties
done

# Create core configuration for ZooKeeper
echo "Creating core configuration in ZooKeeper..."
$BASE_DIR/solr-nodes/node1/bin/solr start -c -p 8983 -z localhost:2181

# Create the collection
echo "Creating Solr collection..."
$BASE_DIR/solr-nodes/node1/bin/solr create_collection -c searchcore -d $BASE_DIR/solr-config/cores/searchcore/conf -shards 2 -replicationFactor 1

echo "Setup complete! Start ZooKeeper and Solr nodes to begin."