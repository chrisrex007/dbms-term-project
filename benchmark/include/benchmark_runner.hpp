#pragma once

#include "connection_pool.hpp"
#include "metrics.hpp"
#include "thread_pool.hpp"

#include <string>
#include <vector>

namespace solrbench {

/**
 * BenchmarkConfig - Configuration for a benchmark run.
 */
struct BenchmarkConfig {
    std::string solr_url;                    // e.g., "http://localhost:8983/solr/searchcore"
    std::vector<int> concurrency_levels;     // e.g., {2, 5, 10, 25, 50, 100}
    int duration_seconds;                    // Duration per concurrency level
    int connection_pool_size;                // Number of CURL handles
    std::vector<std::string> queries;        // Query terms to cycle through
    std::string output_file;                 // JSON output path
    int pause_between_levels_seconds;        // Pause between concurrency levels
};

/**
 * BenchmarkRunner - Orchestrates the full benchmark workflow.
 *
 * For each concurrency level:
 *   1. Creates a ThreadPool of the specified size
 *   2. Shares a ConnectionPool for CURL handle reuse
 *   3. Each thread repeatedly picks a query, executes it, records metrics
 *   4. After the duration expires, collects and aggregates results
 *
 * Produces JSON output compatible with the existing visualize.py script.
 */
class BenchmarkRunner {
public:
    explicit BenchmarkRunner(const BenchmarkConfig& config);

    /**
     * Run the full benchmark suite across all concurrency levels.
     * @return Vector of metrics, one per concurrency level.
     */
    std::vector<BenchmarkMetrics> run();

    /**
     * Save results to the configured output file as JSON.
     */
    void save_results(const std::vector<BenchmarkMetrics>& results) const;

private:
    /**
     * Run a single benchmark at one concurrency level.
     */
    BenchmarkMetrics run_single(int concurrency_level);

    /**
     * Execute a single HTTP query against Solr and return the result.
     * @param handle Pre-configured CURL handle from the connection pool.
     * @param url    Full query URL.
     */
    RequestResult execute_query(CURL* handle, const std::string& url);

    /**
     * Build the full query URL for a given search term.
     */
    std::string build_query_url(const std::string& query) const;

    BenchmarkConfig config_;
};

} // namespace solrbench
