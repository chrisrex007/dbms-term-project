#!/bin/bash
# index-sample-data.sh - Download Wikipedia abstracts and index into Solr

set -euo pipefail

BASE_DIR=$(pwd)
DOWNLOADS_DIR="$BASE_DIR/downloads"
CHUNKS_DIR="$DOWNLOADS_DIR/chunks"
SOLR_URL=${SOLR_URL:-http://localhost:8983/solr/searchcore}
SAMPLE_COUNT=${SAMPLE_COUNT:-10000}
CHUNK_SIZE=${CHUNK_SIZE:-500}
FORCE_REGENERATE=${FORCE_REGENERATE:-0}
WIKI_DUMP_URL=${WIKI_DUMP_URL:-https://dumps.wikimedia.org/simplewiki/latest/simplewiki-latest-abstract.xml.gz}
WIKI_DUMP_FILE="$DOWNLOADS_DIR/simplewiki-latest-abstract.xml.gz"
SAMPLE_FILE="$DOWNLOADS_DIR/wikipedia-abstracts-data.json"

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: required command '$1' is not installed."
        exit 1
    fi
}

generate_wikipedia_abstracts_data() {
    echo "Downloading public Wikipedia abstracts dump..."
    curl -L --fail --retry 3 -o "$WIKI_DUMP_FILE" "$WIKI_DUMP_URL"

    echo "Transforming Wikipedia abstracts into Solr documents..."
    python3 - "$WIKI_DUMP_FILE" "$SAMPLE_FILE" "$SAMPLE_COUNT" << 'PY'
import datetime
import gzip
import hashlib
import json
import re
import sys
import urllib.parse
import xml.etree.ElementTree as ET

dump_path = sys.argv[1]
output_path = sys.argv[2]
max_docs = int(sys.argv[3])

def get_child_text(elem, wanted_name):
    for child in elem:
        tag_name = child.tag.split("}")[-1]
        if tag_name == wanted_name:
            return (child.text or "").strip()
    return ""

documents = []
timestamp = datetime.datetime.utcnow().strftime("%Y-%m-%dT%H:%M:%SZ")

with gzip.open(dump_path, "rb") as fh:
    parser = ET.iterparse(fh, events=("end",))
    for _, elem in parser:
        tag_name = elem.tag.split("}")[-1]
        if tag_name != "doc":
            continue

        title = get_child_text(elem, "title")
        url = get_child_text(elem, "url")
        abstract = get_child_text(elem, "abstract")

        if not title or not abstract:
            elem.clear()
            continue

        curid_match = re.search(r"curid=(\\d+)", url)
        if curid_match:
            doc_id = "wiki_" + curid_match.group(1)
        else:
            doc_id = "wiki_" + hashlib.sha1((url or title).encode("utf-8")).hexdigest()[:16]

        domain = urllib.parse.urlparse(url).netloc or "wikipedia.org"

        documents.append(
            {
                "id": doc_id,
                "title": title,
                "content": abstract,
                "url": url,
                "domain": domain,
                "author": "Wikipedia",
                "category": ["Public Dataset", "Wikipedia Abstract"],
                "tags": ["wikipedia", "abstract", "public-dataset"],
                "last_modified": timestamp,
            }
        )

        elem.clear()

        if len(documents) >= max_docs:
            break

if not documents:
    raise SystemExit("No usable documents found in the Wikipedia dump.")

with open(output_path, "w", encoding="utf-8") as out:
    json.dump(documents, out, ensure_ascii=False)

print(f"Wrote {len(documents)} Wikipedia abstract documents to {output_path}")
PY
}

get_json_count() {
    python3 - "$1" << 'PY'
import json
import sys

with open(sys.argv[1], "r", encoding="utf-8") as f:
    data = json.load(f)

print(len(data))
PY
}

split_into_chunks() {
    python3 - "$1" "$2" "$3" << 'PY'
import json
import os
import sys

source_file = sys.argv[1]
chunks_dir = sys.argv[2]
chunk_size = int(sys.argv[3])

with open(source_file, "r", encoding="utf-8") as f:
    data = json.load(f)

for index in range(0, len(data), chunk_size):
    chunk_id = index // chunk_size
    out_path = os.path.join(chunks_dir, f"chunk{chunk_id}.json")
    with open(out_path, "w", encoding="utf-8") as out:
        json.dump(data[index:index + chunk_size], out, ensure_ascii=False)
PY
}

require_command curl
require_command python3

mkdir -p "$DOWNLOADS_DIR"

if [ "$FORCE_REGENERATE" = "1" ]; then
    rm -f "$SAMPLE_FILE"
fi

if [ ! -f "$SAMPLE_FILE" ]; then
    generate_wikipedia_abstracts_data
else
    echo "Using existing dataset file at $SAMPLE_FILE"
fi

ACTUAL_COUNT=$(get_json_count "$SAMPLE_FILE")
if [ -z "$ACTUAL_COUNT" ] || [ "$ACTUAL_COUNT" -eq 0 ] 2>/dev/null; then
    echo "Error: dataset file is empty or unreadable: $SAMPLE_FILE"
    exit 1
fi

echo "Checking if Solr is running..."
if ! curl -s "http://localhost:8983/solr/" > /dev/null; then
    echo "Error: Solr is not running. Please start Solr using the start-services.sh script."
    exit 1
fi

echo "Checking if 'searchcore' collection exists..."
if ! curl -s "http://localhost:8983/solr/admin/collections?action=LIST" | grep -q "searchcore"; then
    echo "Error: 'searchcore' collection does not exist. Please create it first."
    exit 1
fi

echo "Indexing sample data..."
echo "This may take a while for $ACTUAL_COUNT documents..."

rm -rf "$CHUNKS_DIR"
mkdir -p "$CHUNKS_DIR"
split_into_chunks "$SAMPLE_FILE" "$CHUNKS_DIR" "$CHUNK_SIZE"

TOTAL_CHUNKS=$(((ACTUAL_COUNT + CHUNK_SIZE - 1) / CHUNK_SIZE))
for i in $(seq 0 $((TOTAL_CHUNKS - 1))); do
    echo "Indexing chunk $((i+1))/$TOTAL_CHUNKS..."
    curl --fail -X POST -H "Content-Type: application/json" --data-binary @"$CHUNKS_DIR/chunk$i.json" "$SOLR_URL/update?commit=true" > /dev/null
done

echo "Optimizing the index..."
curl --fail -X POST "$SOLR_URL/update?optimize=true&waitFlush=true" > /dev/null

echo "Indexing complete! Indexed $ACTUAL_COUNT documents from Wikipedia abstracts."
echo "You can now run the benchmark scripts to test performance."