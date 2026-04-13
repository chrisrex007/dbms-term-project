#!/bin/bash
# index-sample-data.sh - Script to index sample data

BASE_DIR=$(pwd)
SOLR_URL="http://localhost:8983/solr/searchcore"
SAMPLE_COUNT=10000  # Increase to 10,000 documents for better performance testing

# Download some sample data (simulated Wikipedia articles in JSON format)
if [ ! -f "$BASE_DIR/downloads/sample-data.json" ]; then
    echo "Generating sample data ($SAMPLE_COUNT documents)..."
    mkdir -p $BASE_DIR/downloads
    
    # Generate categories and tags arrays
    CATEGORIES=("Technology" "Science" "Health" "Business" "Entertainment" "Sports" "Politics" "Education" "Arts" "Environment")
    TAGS=("important" "featured" "trending" "new" "popular" "recommended" "breaking" "exclusive" "opinion" "analysis" "interview" "tutorial" "review" "guide" "report" "update" "investigation" "profile" "summary" "explainer")
    
    # Generate content paragraphs
    PARAGRAPHS=(
        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam auctor, nisl nec ultricies lacinia, nisl nisl aliquam nisl, nec ultricies nisl nisl nec nisl."
        "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis."
        "Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident."
        "At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias."
        "Nam libero tempore, cum soluta nobis est eligendi optio cumque nihil impedit quo minus id quod maxime placeat facere possimus, omnis voluptas assumenda est."
        "The quick brown fox jumps over the lazy dog. A wonderful serenity has taken possession of my entire soul, like these sweet mornings of spring."
        "Far far away, behind the word mountains, far from the countries Vokalia and Consonantia, there live the blind texts. Separated they live in Bookmarksgrove."
        "One morning, when Gregor Samsa woke from troubled dreams, he found himself transformed in his bed into a horrible vermin."
        "The European languages are members of the same family. Their separate existence is a myth. For science, music, sport, etc, Europe uses the same vocabulary."
        "A small river named Duden flows by their place and supplies it with the necessary regelialia. It is a paradisematic country, in which roasted parts of sentences fly into your mouth."
    )
    
    # Generate sample data in JSON format
    echo "Generating JSON file..."
    echo "[" > $BASE_DIR/downloads/sample-data.json
    
    for i in $(seq 1 $SAMPLE_COUNT); do
        # Generate random title and content
        TITLE="Sample Document $i: ${CATEGORIES[$((RANDOM % ${#CATEGORIES[@]}))]} Article"
        CONTENT=""
        
        # Generate 3-5 paragraphs of content
        NUM_PARAS=$((3 + RANDOM % 3))
        for p in $(seq 1 $NUM_PARAS); do
            CONTENT="$CONTENT ${PARAGRAPHS[$((RANDOM % ${#PARAGRAPHS[@]}))]}"
        done
        
        # Generate random category and tags
        NUM_CATS=$((1 + RANDOM % 3))
        CATS="["
        for c in $(seq 1 $NUM_CATS); do
            CATS="$CATS\"${CATEGORIES[$((RANDOM % ${#CATEGORIES[@]}))]}\"$(if [ $c -lt $NUM_CATS ]; then echo ","; fi)"
        done
        CATS="$CATS]"
        
        NUM_TAGS=$((2 + RANDOM % 4))
        DOCUMENT_TAGS="["
        for t in $(seq 1 $NUM_TAGS); do
            DOCUMENT_TAGS="$DOCUMENT_TAGS\"${TAGS[$((RANDOM % ${#TAGS[@]}))]}\"$(if [ $t -lt $NUM_TAGS ]; then echo ","; fi)"
        done
        DOCUMENT_TAGS="$DOCUMENT_TAGS]"
        
        # Generate random date in 2022-2024
        YEAR=$((2022 + RANDOM % 3))
        MONTH=$((1 + RANDOM % 12))
        DAY=$((1 + RANDOM % 28))
        DATE=$(date -d "$YEAR-$MONTH-$DAY" "+%Y-%m-%dT%H:%M:%SZ" 2>/dev/null)
        if [ -z "$DATE" ]; then
            DATE="2022-01-01T00:00:00Z"
        fi
        
        # Write document to JSON file
        cat << EOF >> $BASE_DIR/downloads/sample-data.json
{
  "id": "doc$i",
  "title": "$TITLE",
  "content": "$CONTENT",
  "url": "http://example.com/document$i",
  "domain": "example.com",
  "author": "Author $(($i % 20))",
  "category": $CATS,
  "tags": $DOCUMENT_TAGS,
  "last_modified": "$DATE"
}$(if [ $i -lt $SAMPLE_COUNT ]; then echo ","; fi)
EOF
        
        # Show progress
        if [ $((i % 100)) -eq 0 ]; then
            echo "Generated $i/$SAMPLE_COUNT documents..."
        fi
    done
    
    echo "]" >> $BASE_DIR/downloads/sample-data.json
    echo "Sample data generation complete!"
fi

# Check Solr status
echo "Checking if Solr is running..."
if ! curl -s "http://localhost:8983/solr/" > /dev/null; then
    echo "Error: Solr is not running. Please start Solr using the start-services.sh script."
    exit 1
fi

# Check if collection exists
echo "Checking if 'searchcore' collection exists..."
if ! curl -s "http://localhost:8983/solr/admin/collections?action=LIST" | grep -q "searchcore"; then
    echo "Error: 'searchcore' collection does not exist. Please create it first."
    exit 1
fi

# Index the data using curl
echo "Indexing sample data..."
echo "This may take a while for $SAMPLE_COUNT documents..."

# Split the large file into chunks to avoid request size limits
CHUNK_SIZE=500
TOTAL_CHUNKS=$((SAMPLE_COUNT / CHUNK_SIZE))

if [ $TOTAL_CHUNKS -eq 0 ]; then
    TOTAL_CHUNKS=1
fi

mkdir -p $BASE_DIR/downloads/chunks

# Use jq to split the file if available
if command -v jq &> /dev/null; then
    echo "Using jq to split the data file into $TOTAL_CHUNKS chunks..."
    for i in $(seq 0 $((TOTAL_CHUNKS - 1))); do
        START=$((i * CHUNK_SIZE))
        echo "Creating chunk $((i+1))/$TOTAL_CHUNKS..."
        jq ".[$START:$((START + CHUNK_SIZE))]" $BASE_DIR/downloads/sample-data.json > $BASE_DIR/downloads/chunks/chunk$i.json
    done
else
    echo "Warning: jq is not installed. This might affect indexing large files."
    echo "Falling back to indexing the entire file at once (may cause issues with very large files)."
    cp $BASE_DIR/downloads/sample-data.json $BASE_DIR/downloads/chunks/chunk0.json
    TOTAL_CHUNKS=1
fi

# Index each chunk
for i in $(seq 0 $((TOTAL_CHUNKS - 1))); do
    echo "Indexing chunk $((i+1))/$TOTAL_CHUNKS..."
    curl -X POST -H "Content-Type: application/json" --data-binary @$BASE_DIR/downloads/chunks/chunk$i.json "$SOLR_URL/update?commit=true"
    
    # Check for errors
    if [ $? -ne 0 ]; then
        echo "Error indexing chunk $((i+1)). Check the Solr logs for details."
    fi
done

# Optimize the index
echo "Optimizing the index..."
curl -X POST "$SOLR_URL/update?optimize=true&waitFlush=true"

echo "Indexing complete! Indexed $SAMPLE_COUNT documents."
echo "You can now run the benchmark scripts to test performance."