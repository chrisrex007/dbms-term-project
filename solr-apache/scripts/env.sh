#!/usr/bin/env bash
# Shared configuration for the Solr / ZooKeeper benchmark scripts.
#
# Every value is overridable from the environment; the defaults reproduce the
# original hardcoded behavior. Scripts should `source` this file so that the
# collection name, ports, node counts, and Solr URL are defined in one place.

SOLR_VERSION="${SOLR_VERSION:-9.3.0}"
ZOOKEEPER_VERSION="${ZOOKEEPER_VERSION:-3.8.1}"

NUM_SOLR_NODES="${NUM_SOLR_NODES:-2}"
NUM_ZK_NODES="${NUM_ZK_NODES:-3}"

SOLR_HOST="${SOLR_HOST:-localhost}"
SOLR_PORT_BASE="${SOLR_PORT_BASE:-8983}"

COLLECTION="${COLLECTION:-searchcore}"
SHARDS="${SHARDS:-2}"
REPLICATION_FACTOR="${REPLICATION_FACTOR:-1}"

SOLR_BASE_URL="${SOLR_BASE_URL:-http://${SOLR_HOST}:${SOLR_PORT_BASE}/solr}"
SOLR_URL="${SOLR_URL:-${SOLR_BASE_URL}/${COLLECTION}}"

# ZooKeeper client ports start at ZK_CLIENT_PORT_BASE and increment per node.
ZK_CLIENT_PORT_BASE="${ZK_CLIENT_PORT_BASE:-2181}"
if [ -z "${ZK_CONNECT:-}" ]; then
    _zk_connect=""
    for _i in $(seq 1 "$NUM_ZK_NODES"); do
        _port=$((ZK_CLIENT_PORT_BASE + _i - 1))
        _zk_connect="${_zk_connect:+$_zk_connect,}${SOLR_HOST}:${_port}"
    done
    ZK_CONNECT="$_zk_connect"
fi

# Repo-local siege resource file. Enables JSON output (required by
# run-siege-benchmark.sh's parser) and silences the logfile notice, so a fresh
# checkout produces real metrics instead of all-zero rows.
ENV_SH_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SIEGERC="${SIEGERC:-${ENV_SH_DIR}/benchmark/siege-config/siegerc}"
