DBMS Term Project Proposal
Project Title
High QPS Text Search Engine using Apache Solr and ZooKeeper
Abstract
Modern applications demand search systems capable of handling massive query volumes
without degrading response quality or latency. This project aims to design and evaluate a
scalable, high-throughput text search engine built on Apache Solr, an enterprise-grade search
platform from the Apache Lucene project, orchestrated using Apache ZooKeeper for distributed
coordination.
The system will support full-text keyword search across a large document corpus. To evaluate
its performance under stress, we will conduct systematic benchmarking using two approaches:
a custom multithreaded HTTP client leveraging C++ thread pool and connection pool
abstractions (using std::thread and libcurl), and the Siege HTTP load testing utility to
simulate a large number of concurrent users.
The primary outcome will be a QPS (Queries Per Second) analysis - measuring how throughput,
latency, and error rates scale as concurrent request load increases. Results will be visualized to
highlight the performance envelope of the system, identify bottlenecks, and demonstrate the
scalability benefits of a distributed Solr-over-ZooKeeper architecture compared to a standalone
deployment.
Key Technologies Used
Technology Purpose
Apache Solr Full-text search indexing and querying
Apache ZooKeeper Distributed cluster coordination (SolrCloud
mode)
Siege HTTP benchmarking and load simulation
C++ (std::thread, libcurl) Multithreaded HTTP client for controlled QPS
benchmarking
Matplotlib Performance data visualization
Weekly Work Plans
Week 1 - Environment Setup
● Study Apache Solr architecture, SolrCloud mode, and ZooKeeper coordination model
● Install and configure Apache Solr in standalone mode on local machines
● Install ZooKeeper and configure a basic Solr cluster (SolrCloud)
● Identify and select a suitable public dataset for indexing (e.g., Wikipedia abstracts, news
articles, product catalog)
● Deliverable: Working Solr + ZooKeeper environment; dataset selected
Week 2 - Data Ingestion and Schema Design
● Design the Solr schema (fields, field types, analyzers, tokenizers)
● Write data ingestion scripts to bulk-index the chosen dataset into Solr
● Verify correctness of indexed data via Solr Admin UI and basic query tests
● Set up collections and shards in SolrCloud for distributed indexing
● Deliverable: Fully indexed corpus ready for querying; schema finalized
Week 3 - Search Engine Development and Query Interface
● Develop a keyword-based search interface (REST API or simple web frontend)
● Implement query features: full-text search, filtering, pagination, hit highlighting
● Test edge cases: empty queries, special characters, large result sets
● Establish baseline query performance metrics (single-threaded, single user)
● Deliverable: Functional search engine with documented API endpoints
Week 4 - Benchmarking Tool Setup and Initial Load Tests
● Install and configure Siege for HTTP load testing
● Develop a multithreaded HTTP client in C++ using std::thread and libcurl for ThreadPool
and ConnectionPool
● Define benchmarking scenarios: varying concurrency levels (e.g., 10, 50, 100, 500, 1000
concurrent users)
● Run initial load tests; collect raw QPS, latency, and error-rate data
● Deliverable: Benchmarking infrastructure ready; first round of QPS data collected
Week 5 - Benchmarking, Optimization and Analysis
● Run comprehensive benchmarks across all concurrency levels for both standalone and
SolrCloud deployments
● Compare QPS performance: standalone Solr vs. distributed SolrCloud (multiple
shards/replicas)
● Apply performance tuning (caching, connection pool sizing) and re-benchmark
● Visualize QPS, latency percentiles (p50, p95, p99), and error rates using Matplotlib
● Write the final project report covering: motivation, design, implementation, benchmarking
methodology, results, and conclusions
● Deliverable: Final report, presentation, complete QPS dataset, and demo-ready system
