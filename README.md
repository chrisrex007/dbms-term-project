  public:: true
- # Design and Implementation of a Scalable Text Search Engine Using Apache Solr
- ## Abstract
  
  Implementing a performant and scalable text search engine requires specialized infrastructure and technical expertise. This project explores the development of a high-performance search solution using Apache Solr running on ZooKeeper, focusing on scalability and query performance benchmarking. Rather than using managed search services, we implement a custom search engine capable of handling high query-per-second (QPS) workloads. The system leverages Solr's distributed search capabilities and full-text search features while evaluating performance under load using multi-threaded HTTP clients and siege benchmarking tools. Our approach demonstrates how open-source technologies can be configured and optimized to build enterprise-grade search solutions with measurable performance characteristics.  
  
  **Keywords:** Text Search Engine, Apache Solr, ZooKeeper, Query Performance, Scalability, Benchmarking, High QPS  
- ## Table of Contents
	- 1.Introduction
	- 2.Related Work
	- 3.Custom Search Engine Implementation
	- 4.Requirements
		- 4.1 Scalability
		- 4.2 Quality of Search
		- 4.1 Scalability
	- 5.Architecture
	- 6.Implementation and Configurations
		- 6.1 Solr Schema Configuration
		- 6.2 Solr Core Configuration
		- 6.3 ZooKeeper Ensemble Configuration
		- 6.4 Administration and Monitoring Interface
		- 6.5 Search Interface Implementation
		- 6.6 Performance Benchmarking Configuration
		- 6.7 Document Processing Pipeline
		- 6.8 Query Processing Architecture
		- 6.9 BENCHMARK
	- 7.Evaluation
		- 7.1 Scalability Evaluation
		- 7.2 Search Quality Assessment
		- 7.3 System Performance Metrics
		- 7.Evaluation
	- 8.Conclusion
	- 9.References
	- 10.Code Repository
- ## 1.Introduction
  
  In today's digital landscape, websites serve as the primary channel for businesses to communicate with customers, offering information about products, services, and company details. For many organizations—such as news portals, e-commerce platforms, and knowledge bases—the website itself is the core service. A critical factor in ensuring a positive user experience is the ability to quickly and accurately retrieve relevant information. While intuitive navigation and well-structured layouts help, an efficient search engine is essential for users to find what they need.  
  
  Developing a high-performance, scalable search solution from scratch is complex, requiring expertise in distributed systems, indexing, and query optimization. Instead of relying on proprietary or cloud-based search services, this project explores the implementation of a custom text search engine using Apache Solr, a powerful open-source search platform built on Apache Lucene. Solr provides full-text search, faceted navigation, and hit highlighting, while ZooKeeper ensures distributed coordination and fault tolerance in a clustered setup.  
  
  The primary focus of this work is to:  
	- Design and implement a scalable search engine using Solr and ZooKeeper.
	- Benchmark query performance under high load, measuring queries per second (QPS) using multi-threaded HTTP clients and tools like Siege.
	- Evaluate scalability by testing how search performance improves (or degrades) as the system handles increasing concurrent requests.
	    
	  The rest of this paper is structured as follows:  
	- Section 2 discusses related work in search engine technologies and performance benchmarking.
	- Section 3 defines key requirements for a high-performance, scalable search engine.
	- Section 4 details the system architecture, including Solr's distributed indexing and ZooKeeper's role in cluster management.
	- Section 5 explains the implementation, covering indexing strategies and query optimization.
	- Section 6 evaluates the system's performance, analyzing QPS, latency, and scalability under varying workloads.
	    
	  By the end of this study, we demonstrate how an open-source Solr-based search engine can be optimized for high throughput, making it a viable alternative to commercial search solutions.  
- ## 2.Related Work
  
  Search engine technologies can be broadly categorized into commercial cloud-based solutions and self-hosted open-source frameworks. While cloud services offer convenience, open-source solutions provide greater control, customization, and cost efficiency for organizations requiring high-performance, scalable search capabilities.  
- ### Commercial Search Services
  
  Several major providers offer managed search solutions:  
	- Google Site Search (now deprecated) allowed businesses to integrate Google's search technology into their websites.
	- Amazon CloudSearch provides a fully managed search service with auto-scaling, though it limits low-level customization.
	- Microsoft Bing Search API (via Azure) enables paid integration of Bing's search results into applications.
- While these services reduce infrastructure overhead, they introduce vendor lock-in, limited configurability, and recurring costs—making them unsuitable for use cases requiring fine-tuned performance or on-premises deployment.
- ### Open-Source Search Frameworks
  
  For organizations needing full control over search functionality, Apache Solr and Elasticsearch dominate the open-source landscape:  
  
  **Apache Solr:** Built on Lucene, Solr provides distributed search, faceting, and real-time indexing, with ZooKeeper enabling cluster coordination. Its scalability has been proven in large-scale deployments like Wikimedia and Netflix.  
  
  **Elasticsearch:** Designed for high-availability JSON document search, it emphasizes horizontal scaling and analytics.  
  
  Recent research has explored performance optimization in these systems:  
	- Studies on query latency in distributed Solr (e.g., [5]) highlight the impact of sharding strategies on throughput.
	- Benchmarking tools like Siege and JMeter [6] are widely used to measure QPS (queries per second) under load, a key focus of this project.
	- Techniques such as caching, load balancing, and JVM tuning [7] are critical for achieving high QPS in self-hosted deployments.
	    
	  Unlike proprietary solutions, open-source frameworks allow deep customization of indexing, ranking, and scalability—making them ideal for research into high-performance search architectures.  
- ## 3.Custom Search Engine Implementation
  
  While many organizations opt for managed search services to avoid infrastructure overhead, implementing a custom search engine using open-source technologies provides greater control, flexibility, and cost efficiency - particularly for applications requiring high performance and scalability. This chapter outlines our approach to building a self-hosted search solution using Apache Solr and ZooKeeper.  
  
  The key challenge in implementing an effective website search system lies in handling two critical processes simultaneously:  
	- **Content Indexing:** Maintaining an up-to-date search index that efficiently processes document updates and additions
	- **Query Processing:** Delivering fast, accurate search results even under heavy user traffic
	    
	  Traditional approaches to this problem involve either:  
	- Building a proprietary search solution (requiring significant engineering resources)
	- Using commercial search services (which may limit customization and incur ongoing costs)
	    
	  Our implementation takes a third approach by leveraging Apache Solr, an enterprise-grade open-source search platform that offers:  
	- Full-text search capabilities
	- Hit highlighting
	- Faceted navigation
	- Scalable distributed search through SolrCloud
	- ZooKeeper-based cluster coordination for fault tolerance
-
- The system architecture follows these key steps:
	- **Content Collection:** Documents are gathered from various sources (websites, databases, files)
	- **Indexing Pipeline:** Content is processed and indexed in Solr with appropriate field mappings
	- **Distributed Deployment:** The search engine runs across multiple nodes coordinated by ZooKeeper
	- **Query Processing:** Search requests are load-balanced across the cluster
	- **Performance Optimization:** Techniques like caching, sharding, and replication are applied
- Unlike commercial search services that handle crawling and indexing automatically, our solution provides:
	- Complete control over indexing strategies and schema design
	- Ability to fine-tune ranking algorithms and relevance scoring
	- Direct access to performance metrics for optimization
	- No dependency on third-party services or APIs
- This approach is particularly valuable for organizations that:
	- Handle sensitive data requiring on-premises solutions
	- Need to customize search behavior extensively
	- Must maintain predictable performance under high query loads
	- Want to avoid recurring licensing costs
	    
	  The following chapters will detail our specific implementation choices and the performance characteristics we achieved through this architecture.  
- ## 4.Requirements
  
  Before detailing the architecture and implementation, we outline the key requirements that guided our development of a Solr-based search engine with ZooKeeper coordination.  
- ### 4.1 Scalability
	- The search engine must scale effectively in two critical dimensions: handling growing data volumes and increasing query loads. As document collections expand, the system should maintain consistent performance through distributed indexing across multiple Solr nodes.
	- For applications experiencing high query traffic, the architecture must support horizontal scaling of search processing capacity without requiring complete reindexing. This dual scalability is achieved through SolrCloud's sharding mechanism, where ZooKeeper manages the distribution of both index segments and query traffic across the cluster. The system allows independent scaling of indexing and query processing resources - a crucial capability when dealing with large batch updates while simultaneously serving live search requests.
	    
	  ![image.png](assets/image_1745844676635_0.png)  
- ### 4.2 Quality of Search
	- Search result quality encompasses both relevance and functionality. The engine must employ advanced ranking algorithms to surface the most pertinent documents, utilizing Solr's configurable scoring models including TF-IDF and BM25.
	- Beyond basic keyword matching, the system should support features like typo tolerance through fuzzy matching, synonym expansion for conceptual searches, and field-specific boosting to prioritize certain content types. The user experience is further enhanced through faceted navigation that allows result filtering, hit highlighting that shows query terms in context, and autocomplete functionality that guides query formulation. These features must work cohesively to deliver meaningful results across diverse content types and query patterns.
- ### 4.3 System Integration
	- The solution must provide straightforward integration pathways for different application scenarios. For developers, comprehensive APIs should enable index updates and search operations through standard protocols. The schema configuration should support flexible field definitions to accommodate various document structures without requiring code changes.
	- Administrative interfaces should simplify cluster management tasks such as node provisioning, index replication, and performance monitoring. Unlike managed search services, our solution emphasizes configuration transparency and control, allowing precise tuning of both indexing and query processing parameters to meet specific application requirements while maintaining system stability.
- ## 5.Architecture
  
  The architecture of our search engine implementation revolves around a distributed SolrCloud cluster coordinated by ZooKeeper, designed to handle both indexing operations and high-volume search requests efficiently. The system follows a modular design that separates the core search functionality from administrative components while maintaining tight integration between them. This architecture enables horizontal scaling to accommodate growing data volumes and query loads without service disruption, with performance validation conducted through rigorous load testing using the Siege benchmarking tool.  
  
  ![image.png](assets/image_1745844625115_0.png)  
  
  At the core of the system lies the SolrCloud cluster, which provides distributed indexing and search capabilities across multiple nodes. Each node in the cluster participates in both indexing and query processing, with ZooKeeper managing the distribution of workloads and maintaining cluster state. The index is partitioned into shards that are distributed across nodes, allowing the system to scale beyond the resource limitations of individual machines.  
  
  We employed Siege to verify the cluster's query handling capacity, configuring it to simulate hundreds of concurrent users submitting search requests across different shard configurations. When processing search requests, the query coordinator node divides queries into parallel sub-queries that execute across shards, then merges and ranks the results before returning them to the client. This sharding approach remains transparent to end users while significantly improving performance for large document collections, as confirmed by Siege benchmarks showing consistent sub-second response times under load.  
  
  ZooKeeper serves as the central coordination service for the entire architecture, running as an ensemble across multiple nodes to ensure fault tolerance. It handles critical cluster management functions including:  
	- Node discovery and membership
	- Distributed configuration management
	- Shard leader election
	- Load balancing coordination
- The system maintains consistency through ZooKeeper's atomic broadcast protocol, which synchronizes cluster state and configuration across all nodes. Our Siege testing methodology incorporated failure scenarios to validate ZooKeeper's ability to maintain cluster stability during simulated node failures, measuring the system's resilience and recovery time. While dedicated ZooKeeper nodes would be ideal for production environments, our implementation colocated ZooKeeper instances with Solr nodes to optimize resource utilization during development and testing, with Siege results confirming this configuration could still maintain target throughput levels.
  
  The administration interface forms the third major component, providing a web-based dashboard for system monitoring and management. Developed as a Spring Boot application, this interface offers:  
	- Real-time visibility into cluster health and performance metrics through comprehensive monitoring tools, including integration with Siege test results for historical performance analysis
	- Index management operations such as creation, deletion, and optimization
	- Schema editing and configuration management capabilities
- The dashboard interacts with the Solr cluster through REST APIs while storing configuration data in a PostgreSQL database, maintaining minimal state to preserve system scalability. During performance testing, we leveraged the dashboard to correlate Siege-generated load patterns with system resource utilization, identifying optimal configuration thresholds.
  
  Document processing follows a well-defined pipeline beginning with content ingestion through multiple channels including database connectors, file crawlers, and API submissions. The system transforms and normalizes documents before distributing them across Solr shards for indexing, making them available for searching in near-real-time. Continuous background optimization processes maintain index efficiency through strategic merging of index segments.  
  
  Query processing leverages Solr's distributed search capabilities with:  
	- Load-balanced request distribution
	- Parallel execution across shards
	- Intelligent result merging with relevance scoring
- Our Siege benchmarks systematically evaluated each of these components, measuring indexing throughput during document ingestion phases and query latency under various concurrency levels. The implementation includes response caching for frequent queries and comprehensive monitoring to analyze performance characteristics, with Siege tests validating cache effectiveness by comparing response times for repeated versus unique queries.
  
  ZooKeeper's coordination guarantees cluster stability even during node failures or network partitions, while SolrCloud's sharding and replication mechanisms provide both scalability and data redundancy. We designed our Siege test plans to specifically stress these fault tolerance features, simulating network partitions and node failures while continuing to measure query success rates and response times. The benchmarking results demonstrated the system's ability to maintain service continuity during outages, with automatic recovery mechanisms restoring full performance once nodes rejoined the cluster. This integrated approach to architecture and performance validation ensures the system meets both functional requirements and operational service level objectives.  
- ## 6.Implementation and Configurations
- ### 6.1 Solr Schema Configuration
  
  The schema.xml configuration establishes the foundational structure for document indexing and searching within our Solr implementation. The schema defines multiple field types to handle different data formats, including:  
- String
- Boolean
- Numeric (int, float, long, double)
- Date fields
  
  For textual content, the text_general field type implements a comprehensive analysis pipeline using:  
- StandardTokenizer for word segmentation
- StopFilter to remove common words
- LowerCaseFilter for case normalization
  
  During query processing, an additional SynonymGraphFilter expands search terms using defined synonyms to improve recall while maintaining precision.  
  
  Required fields include:  
- Document ID
- Version tracking field
  
  Core content fields capture:  
- Title
- Content body
- URL
- Domain
- Author
- Category information
  
  The schema incorporates dynamic field definitions (metatag_*) to flexibly accommodate custom metadata without requiring schema modifications. For faceted search capabilities, specific fields like tags and category are configured as multi-valued. A catch-all text field combines content from multiple sources through copyField directives, enabling unified search across key document elements while maintaining individual field-specific searching capabilities.  
  
  ```
  <?xml version="1.0" encoding="UTF-8" ?>
  <!-- solrconfig.xml - Configuration for the search core -->
  <config>
    <luceneMatchVersion>9.8.0</luceneMatchVersion>
    <!-- Data directory for this core -->
    <dataDir>${solr.data.dir:}</dataDir>
    
    <!-- Index configuration -->
    <indexConfig>
      <ramBufferSizeMB>128</ramBufferSizeMB>
      <!-- <mergeFactor>10</mergeFactor> NOt in the solr 7.0 or > -->
      <lockType>${solr.lock.type:native}</lockType>
      <infoStream>false</infoStream>
      <maxBufferedDocs>1000</maxBufferedDocs>
    </indexConfig>
    
    <!-- JMX configuration -->
    <jmx />
    
    <!-- Request handlers -->
    <requestHandler name="/select" class="solr.SearchHandler">
      <lst name="defaults">
        <str name="echoParams">explicit</str>
        <int name="rows">10</int>
        <str name="df">content</str>
        <str name="wt">json</str>
        <!-- Highlighting configuration -->
        <str name="hl">on</str>
        <str name="hl.fl">title,content</str>
        <str name="hl.snippets">3</str>
        <str name="hl.fragsize">200</str>
        
        <!-- Faceting configuration -->
         <str name="facet">on</str>
        <str name="facet.field">category</str>
        <str name="facet.field">tags</str>
        <str name="facet.mincount">1</str>
        <str name="facet.limit">20</str>
      </lst>
    </requestHandler>
    
    <!-- Auto-suggest configuration -->
    <requestHandler name="/suggest" class="solr.SearchHandler">
      <lst name="defaults">
        <str name="suggest">true</str>
        <str name="suggest.dictionary">mySuggester</str>
        <str name="suggest.onlyMorePopular">true</str>
        <str name="suggest.count">10</str>
        <str name="suggest.collate">true</str>
      </lst>
      <arr name="components">
        <str>suggest</str>
      </arr>
    </requestHandler>
    
    <!-- Search components -->
    <searchComponent name="suggest" class="solr.SuggestComponent">
      <lst name="suggester">
        <str name="name">mySuggester</str>
        <str name="lookupImpl">FuzzyLookupFactory</str>
        <str name="dictionaryImpl">DocumentDictionaryFactory</str>
        <str name="field">title</str>
        <str name="weightField">popularity</str>
        <str name="suggestAnalyzerFieldType">text_general</str>
        <str name="buildOnStartup">true</str>
        <str name="buildOnCommit">true</str>
      </lst>
    </searchComponent>
    
    <!-- Update request processor chain -->
    <updateRequestProcessorChain name="dedupe">
      <processor class="solr.LogUpdateProcessorFactory" />
      <processor class="solr.RunUpdateProcessorFactory" />
    </updateRequestProcessorChain>
  
  
  <!-- Highlighting configuration to add to your solrconfig.xml -->
  <searchComponent name="highlight" class="solr.HighlightComponent">
    <highlighting>
      <!-- Configure the standard fragmenter -->
      <fragmenter name="gap" class="org.apache.solr.highlight.GapFragmenter" default="true">
        <lst name="defaults">
          <int name="hl.fragsize">100</int>
        </lst>
      </fragmenter>
      
      <!-- Configure the regex fragmenter -->
      <fragmenter name="regex" class="org.apache.solr.highlight.RegexFragmenter">
        <lst name="defaults">
          <int name="hl.fragsize">70</int>
          <float name="hl.regex.slop">0.5</float>
          <str name="hl.regex.pattern">[-\w ,/\n\"']{20,200}</str>
        </lst>
      </fragmenter>
      
      <!-- Configure the standard formatter -->
      <formatter name="html" class="org.apache.solr.highlight.HtmlFormatter" default="true">
        <lst name="defaults">
          <str name="hl.simple.pre"><![CDATA[<em>]]></str>
          <str name="hl.simple.post"><![CDATA[</em>]]></str>
        </lst>
      </formatter>
      
      <!-- Configure the standard encoder -->
      <encoder name="html" class="org.apache.solr.highlight.HtmlEncoder" default="true"/>
      
      <!-- Configure the standard fragListBuilder -->
      <fragListBuilder name="simple" class="org.apache.solr.highlight.SimpleFragListBuilder" default="true"/>
      
      <!-- Configure the single fragListBuilder -->
      <fragListBuilder name="single" class="org.apache.solr.highlight.SingleFragListBuilder"/>
      
      <!-- Configure the standard fragmentsBuilder -->
      <fragmentsBuilder name="default" class="org.apache.solr.highlight.ScoreOrderFragmentsBuilder" default="true"/>
      
      <!-- Configure the multi-colored fragmentsBuilder -->
      <fragmentsBuilder name="colored" class="org.apache.solr.highlight.ScoreOrderFragmentsBuilder">
        <lst name="defaults">
          <str name="hl.tag.pre"><![CDATA[<b style="background:yellow">]]></str>
          <str name="hl.tag.post"><![CDATA[</b>]]></str>
        </lst>
      </fragmentsBuilder>
      
      <boundaryScanner name="default" class="solr.highlight.SimpleBoundaryScanner" default="true">
        <lst name="defaults">
          <str name="hl.bs.maxScan">10</str>
          <str name="hl.bs.chars">.,!? &#9;&#10;&#13;</str>
        </lst>
      </boundaryScanner>
      
      <boundaryScanner name="breakIterator" class="solr.highlight.BreakIteratorBoundaryScanner">
        <lst name="defaults">
          <str name="hl.bs.type">WORD</str>
          <str name="hl.bs.language">en</str>
          <str name="hl.bs.country">US</str>
        </lst>
      </boundaryScanner>
    </highlighting>
  </searchComponent>
  
  </config>
  ```
- ### 6.2 Solr Core Configuration
  
  The solrconfig.xml file governs core operational parameters and search functionality. Index configuration establishes a 128MB RAM buffer size and merge factor of 10 to balance memory usage with indexing performance.  
  
  The primary search handler (/select) configures default parameters including:  
	- 10 results per page
	- JSON response format
	- Comprehensive highlighting settings for title and content fields
- Highlighting displays up to three snippets of approximately 200 characters each, helping users quickly identify relevant content. Faceting is pre-configured for category and tags fields with practical defaults including minimum value thresholds and limits on returned facets.
  
  The configuration implements a dedicated suggest handler for auto-complete functionality, utilizing fuzzy matching against title fields with optional popularity-based ranking. Update processing uses a streamlined chain that maintains essential logging while minimizing overhead. The configuration specifies native locking for thread safety and disables verbose infoStream logging in production environments. These settings collectively optimize the core for both indexing throughput and query responsiveness while supporting advanced search features.  
  
  ```
  <?xml version="1.0" encoding="UTF-8" ?>
  <schema name="PDF Search Schema" version="1.6">
    <!-- Basic field types -->
    <fieldType name="string" class="solr.StrField" sortMissingLast="true" omitNorms="true"/>
    <fieldType name="int" class="solr.IntPointField" docValues="true"/>
    <fieldType name="long" class="solr.LongPointField" docValues="true"/>
    <fieldType name="float" class="solr.FloatPointField" docValues="true"/>
    <fieldType name="double" class="solr.DoublePointField" docValues="true"/>
    <fieldType name="date" class="solr.DatePointField" docValues="true"/>
    
    <!-- Text fields with various analyzers for different search needs -->
    <fieldType name="text_general" class="solr.TextField" positionIncrementGap="100">
      <analyzer type="index">
        <tokenizer class="solr.StandardTokenizerFactory"/>
        <filter class="solr.StopFilterFactory" ignoreCase="true" words="stopwords.txt"/>
        <filter class="solr.LowerCaseFilterFactory"/>
      </analyzer>
      <analyzer type="query">
        <tokenizer class="solr.StandardTokenizerFactory"/>
        <filter class="solr.StopFilterFactory" ignoreCase="true" words="stopwords.txt"/>
        <filter class="solr.SynonymGraphFilterFactory" synonyms="synonyms.txt" ignoreCase="true" expand="true"/>
        <filter class="solr.LowerCaseFilterFactory"/>
      </analyzer>
    </fieldType>
    
    <!-- Special text field for improved phrase searching and highlighting -->
    <fieldType name="text_highlight" class="solr.TextField" positionIncrementGap="100">
      <analyzer>
        <tokenizer class="solr.StandardTokenizerFactory"/>
        <filter class="solr.StopFilterFactory" ignoreCase="true" words="stopwords.txt"/>
        <filter class="solr.LowerCaseFilterFactory"/>
      </analyzer>
    </fieldType>
  
    <!-- Fields for document metadata and content -->
    <field name="id" type="string" indexed="true" stored="true" required="true" multiValued="false"/>
    <field name="file_name" type="string" indexed="true" stored="true"/>
    <field name="file_path" type="string" indexed="true" stored="true"/>
    <field name="file_type" type="string" indexed="true" stored="true"/>
    <field name="file_size" type="long" indexed="true" stored="true"/>
    <field name="last_modified" type="date" indexed="true" stored="true"/>
    
    <!-- Fields for document structure -->
    <field name="page_number" type="int" indexed="true" stored="true"/>
    <field name="page_count" type="int" indexed="true" stored="true"/>
    <field name="paragraph_id" type="string" indexed="true" stored="true"/>
    <field name="paragraph_number" type="int" indexed="true" stored="true"/>
    <field name="title" type="text_general" indexed="true" stored="true"/>
    
    <!-- Content fields -->
    <field name="content" type="text_general" indexed="true" stored="true" termVectors="true" termPositions="true" termOffsets="true"/>
    <field name="content_highlight" type="text_highlight" indexed="true" stored="true" termVectors="true" termPositions="true" termOffsets="true" multiValued="true"/>
    <field name="paragraph_text" type="text_highlight" indexed="true" stored="true" termVectors="true" termPositions="true" termOffsets="true" multiValued="true"/>
    
    <!-- Dynamic fields for additional metadata -->
    <dynamicField name="*_i" type="int" indexed="true" stored="true"/>
    <dynamicField name="*_s" type="string" indexed="true" stored="true"/>
    <dynamicField name="*_l" type="long" indexed="true" stored="true"/>
    <dynamicField name="*_t" type="text_general" indexed="true" stored="true"/>
    <dynamicField name="*_dt" type="date" indexed="true" stored="true"/>
    <!-- <dynamicField name="*_p" type="location" indexed="true" stored="true"/> -->
  
    <!-- Copy fields for enhanced searching -->
    <copyField source="content" dest="content_highlight"/>
    <copyField source="paragraph_text" dest="content_highlight"/>
  
    <!-- Unique key field -->
    <uniqueKey>id</uniqueKey>
  
    <!-- Field to use to determine and enforce document uniqueness -->
    <similarity class="solr.ClassicSimilarityFactory"/>
  </schema>
  ```
- ### 6.3 ZooKeeper Ensemble Configuration
  
  The ZooKeeper ensemble configuration establishes reliable cluster coordination with carefully tuned timeouts and quorum settings. The base tickTime of 2000ms defines the fundamental time unit for heartbeat intervals and timeout calculations. The initLimit permits 10 ticks (20 seconds) for follower servers to connect to the leader during initial ensemble startup, while the syncLimit allows 5 ticks (10 seconds) for followers to synchronize with the leader.  
  
  A three-server ensemble provides fault tolerance through distributed coordination, with each server identified by IP address and dedicated ports for:  
	- Peer communication (2888)
	- Leader election (3888)
- The configuration stores cluster state and configuration data in the local filesystem while exposing the standard 2181 port for client connections. This setup ensures continuous availability even during individual node failures while maintaining responsive coordination for SolrCloud operations. The configuration balances responsiveness with stability, providing sufficient timeouts for distributed operations while maintaining tight synchronization of cluster state.
-
  ```apl
  bin/solr start -c -z localhost:2181,localhost:2181,localhost:2181 -p 8983
  bin/solr zk upconfig -n searchcore -d  -z 192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181
  ```
-
  ```
  zoo1.cfg, zoo2.cfg, zoo3.cfg
  tickTime=2000
  initLimit=10
  syncLimit=5
  dataDir=/var/lib/zookeeper
  clientPort=2181
  server.1=192.168.1.10:2888:3888
  server.2=192.168.1.11:2888:3888
  server.3=192.168.1.12:2888:3888
  ```
- ### 6.4 Administration and Monitoring Interface
  
  The administration interface provides comprehensive tools for managing the search infrastructure and monitoring system health. Built as a Spring Boot application, the interface integrates with Solr's REST API to offer real-time visibility into cluster operations.  
  
  Core management features enable dynamic schema modifications through Solr's Schema API, allowing field additions and adjustments without requiring core reloads. The dashboard displays key performance metrics including:  
	- Query throughput
	- Indexing rates
	- Visualization capabilities
- ![image.png](assets/image_1745833271054_0.png)
-
- The interface incorporates historical Siege benchmark results for longitudinal performance analysis, enabling administrators to track system capacity over time and plan for scaling needs. Alerting configurations notify operators of emerging issues like growing query latencies or resource constraints. This comprehensive monitoring solution provides the operational visibility needed to maintain high service levels while supporting administrative tasks through an intuitive web interface.
- ### 6.5 Search Interface Implementation
  
  The search interface implementation leverages modern web technologies to deliver responsive, feature-rich search experiences. AJAX-driven components initialize a Solr manager instance that coordinates communication with the appropriate Solr core.  
  
  Specialized widgets handle distinct interface elements including:  
	- Result display
	- Pagination controls
	- Faceted navigation
	- Auto-suggest functionality
- The manager executes queries asynchronously, passing JSON-formatted parameters to Solr and distributing responses to widgets for rendering. Result display incorporates highlighting to show matched terms in context, while faceted navigation allows intuitive result filtering by categories and tags. The auto-suggest feature builds on Solr's suggest component to offer query completions with typo tolerance.
-
- ![image.png](assets/image_1745836671405_0.png)
# dbms-term-project
