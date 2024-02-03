module;
#include "Config.hpp"
// #if CPPCORO_OS_LINUX || (CPPCORO_OS_WINNT >= 0x0602)
// # include <atomic>
// # include <cstdint>
// #elif CPPCORO_OS_WINNT
// # include <cppcoro/detail/win32.hpp>
// #else
// #include <mutex>
// #include <condition_variable>
// #endif
export module Maximus.Coro.LightweightManualResetEvent;
// import <condition_variable>;
// import <mutex>;




		export template <typename mutex, typename condition_variable>
		class lightweight_manual_reset_event
		{
		public:

			lightweight_manual_reset_event(bool initiallySet = false) {

			}

			~lightweight_manual_reset_event() {

			}

			void set() noexcept {

			}

			void reset() noexcept {

			}

			void wait() noexcept {
				
			}

		private:

			// For other platforms that don't have a native futex
			// or manual reset event we can just use a std::mutex
			// and std::condition_variable to perform the wait.
			// Not so lightweight, but should be portable to all platforms.
			mutex m_mutex;
			condition_variable m_cv;
			bool m_isSet;

		};
	