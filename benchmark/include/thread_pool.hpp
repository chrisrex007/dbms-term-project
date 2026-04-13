#pragma once

#include <atomic>
#include <condition_variable>
#include <functional>
#include <mutex>
#include <queue>
#include <thread>
#include <vector>

namespace solrbench {

/**
 * ThreadPool - A fixed-size thread pool using std::thread.
 *
 * Manages a pool of worker threads that execute submitted tasks from a
 * shared task queue. Uses mutex + condition_variable for synchronization.
 *
 * Usage:
 *   ThreadPool pool(8);
 *   pool.submit([](){ do_work(); });
 *   pool.shutdown();
 */
class ThreadPool {
public:
    /**
     * Create a thread pool with the specified number of worker threads.
     * @param num_threads Number of worker threads to spawn.
     */
    explicit ThreadPool(size_t num_threads);

    /**
     * Destructor - calls shutdown() if not already shut down.
     */
    ~ThreadPool();

    // Non-copyable, non-movable
    ThreadPool(const ThreadPool&) = delete;
    ThreadPool& operator=(const ThreadPool&) = delete;
    ThreadPool(ThreadPool&&) = delete;
    ThreadPool& operator=(ThreadPool&&) = delete;

    /**
     * Submit a task to the thread pool for execution.
     * @param task A callable to execute on a worker thread.
     */
    void submit(std::function<void()> task);

    /**
     * Gracefully shut down the thread pool.
     * Waits for all queued tasks to complete before returning.
     */
    void shutdown();

    /**
     * Get the number of worker threads.
     */
    size_t size() const { return workers_.size(); }

    /**
     * Check if the pool is running.
     */
    bool is_running() const { return !stopped_.load(); }

private:
    void worker_loop();

    std::vector<std::thread> workers_;
    std::queue<std::function<void()>> task_queue_;
    std::mutex queue_mutex_;
    std::condition_variable condition_;
    std::atomic<bool> stopped_{false};
};

} // namespace solrbench
