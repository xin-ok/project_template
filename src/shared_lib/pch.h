#pragma once

/**
 * @file pch.h
 * @brief 预编译头文件（Precompiled Header）。
 *
 * 集中放置不常修改的标准库及平台相关头文件。预编译一次后，
 * 所有 .cc 源文件均可复用，从而大幅加速编译过程。
 *
 * @note 请勿在此文件中放置频繁变动的头文件，否则会导致 PCH 频繁失效。
 */

// clang-format off
#include <algorithm>
#include <atomic>
#include <chrono>
#include <condition_variable>
#include <cstddef>
#include <cstdint>
#include <cstring>
#include <exception>
#include <functional>
#include <future>
#include <iostream>
#include <list>
#include <map>
#include <memory>
#include <mutex>
#include <new>
#include <numeric>
#include <optional>
#include <queue>
#include <set>
#include <stdexcept>
#include <string>
#include <thread>
#include <type_traits>
#include <unordered_map>
#include <unordered_set>
#include <vector>
// clang-format on

#ifdef _WIN32
#include <Windows.h>
#else
#include <pthread.h>
#include <unistd.h>
#endif