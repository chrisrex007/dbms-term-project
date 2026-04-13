cmake_minimum_required(VERSION 3.14)
project(solr_benchmark VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# Find required packages
find_package(CURL REQUIRED)

# Header-only includes
include_directories(${CMAKE_SOURCE_DIR}/include)

# Source files
set(SOURCES
    src/main.cpp
    src/thread_pool.cpp
    src/connection_pool.cpp
    src/metrics.cpp
    src/benchmark_runner.cpp
)

# Executable
add_executable(solr_benchmark ${SOURCES})
target_link_libraries(solr_benchmark PRIVATE CURL::libcurl pthread)

# Install
install(TARGETS solr_benchmark DESTINATION bin)

message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "CURL found: ${CURL_VERSION_STRING}")
