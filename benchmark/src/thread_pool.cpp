#include "thread_pool.hpp"
#include <iostream>

namespace solrbench {

ThreadPool::ThreadPool(size_t num_threads) {
    workers_.reserve(num_threads);
    for (size_t i = 0; i < num_threads; ++i) {
        workers_.emplace_back(&ThreadPool::worker_loop, this);
    }
}

ThreadPool::~ThreadPool() {
    if (!stopped_.load()) {
        shutdown();
    }
}

void ThreadPool::submit(std::function<void()> task) {
    {
        std::lock_guard<std::mutex> lock(queue_mutex_);
        if (stopped_.load()) {
            throw std::runtime_error("Cannot submit to a stopped ThreadPool");
        }
        task_queue_.push(std::move(task));
    }
    condition_.notify_one();
}

void ThreadPool::shutdown() {
    {
        std::lock_guard<std::mutex> lock(queue_mutex_);
        stopped_.store(true);
    }
    condition_.notify_all();

    for (auto& worker : workers_) {
        if (worker.joinable()) {
            worker.join();
        }
    }
}

void ThreadPool::worker_loop() {
    while (true) {
        std::function<void()> task;
        {
            std::unique_lock<std::mutex> lock(queue_mutex_);
            condition_.wait(lock, [this] {
                return stopped_.load() || !task_queue_.empty();
            });

            // If stopped and no more tasks, exit
            if (stopped_.load() && task_queue_.empty()) {
                return;
            }

            task = std::move(task_queue_.front());
            task_queue_.pop();
        }

        try {
            task();
        } catch (const std::exception& e) {
            std::cerr << "[ThreadPool] Task threw exception: " << e.what() << std::endl;
        }
    }
}

} // namespace solrbench
