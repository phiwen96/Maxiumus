module;
#include <cstdint>
#include <atomic>
#include <utility>
export module Maximus.Coro.SyncWait;

import Maximus.Coro.LightweightManualResetEvent;
import Maximus.Coro.AwaitableTraits;
import Maximus.Coro.SyncWaitTask;








// namespace cppcoro
// {
// 	export template<typename AWAITABLE>
// 	auto sync_wait(AWAITABLE&& awaitable)
// 		-> typename awaitable_traits<AWAITABLE&&>::await_result_t
// 	{
// // #if CPPCORO_COMPILER_MSVC
// // 		// HACK: Need to explicitly specify template argument to make_sync_wait_task
// // 		// here to work around a bug in MSVC when passing parameters by universal
// // 		// reference to a coroutine which causes the compiler to think it needs to
// // 		// 'move' parameters passed by rvalue reference.
// // 		auto task = detail::make_sync_wait_task<AWAITABLE>(awaitable);
// // #else
// 		auto task = make_sync_wait_task(std::forward<AWAITABLE>(awaitable));
// // #endif
// 		lightweight_manual_reset_event event;
// 		task.start(event);
// 		event.wait();
// 		return task.result();
// 	}