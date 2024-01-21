module;

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <coroutine>
#include <variant>
#include <utility>
#include <exception>

export module Maximus.Concurrency;

// using std::cout, std::endl;

export template <typename T>
concept Thread = requires (T t) {
	t.join ();
	t.detach ();
};

export template <typename T>
concept Mutex = requires (T mtx) {
	mtx.lock ();
	mtx.unlock ();
};

export template <typename T>
concept Condition = requires (T c) {
	c.wait ();
	c.wake ();
};

export struct mutex {
	mutex () {
		pthread_mutex_init (&handle, nullptr);
	}
	~mutex () {
		pthread_mutex_destroy (&handle);
	}
	auto lock () -> void {
		pthread_mutex_lock (&handle);
	}
	auto unlock () -> void {
		pthread_mutex_unlock (&handle);
	}
	auto wait (pthread_cond_t& cv) -> void {
		pthread_cond_wait (&cv, &handle);
	}
private:
	pthread_mutex_t handle;
};

static_assert (Mutex <mutex>);

export template <typename T, Mutex Mtx = mutex>
requires requires (Mtx mtx, pthread_cond_t& cv) {
	mtx.wait (cv);
}
struct condition : Mtx {
	condition () {
		pthread_cond_init (&handle, nullptr);
	}
	~condition () {
		pthread_cond_destroy (&handle);
	}
	auto wake () -> void {
		pthread_cond_signal (&handle);
	}
	auto wait () -> void {
		Mtx::wait (handle);
	}
	auto value () -> T& {
		return val;
	}
private:
	// Mtx mtx;
	pthread_cond_t handle;
	T val;
};

static_assert (Condition <condition <mutex>>);

export struct thread {
	thread () : handle {nullptr} {
		if (pthread_create (&handle, nullptr, body, nullptr)) {
			printf ("thread could not be created\n");
			exit (1);
		}
	}
	auto join () -> void {
		if (pthread_join (handle, nullptr)) {
			printf ("thread could not be created\n");
			exit (1);
		}
	}
	auto detach () -> void {
		pthread_detach (handle);
	}
private:
	pthread_t handle;
	static auto body (void * data) -> void * {
		return data;
	}
};

static_assert (Thread <thread>);

export template <typename T, template <typename> typename co_handle = std::coroutine_handle , bool continuation_on_final_suspend = true>
struct co_promise {
	auto final_suspend () noexcept {
		// if constexpr (continuation_on_final_suspend) {
		// 	return cont;
		// } else {

		// }
 		// return cont;
	}
private:
	T res;
	co_handle <co_promise> cont; // a reference to the coroutine waiting for the task to complete
};

export template <typename T>
struct [[nodiscard]] co_task {
	// using promise_type = co_promise <T, std::coroutine_handle, true>;
	struct promise_type {
		std::variant <std::monostate, T, std::exception_ptr> result_;
		std::coroutine_handle <> continuation_; // A waiting coroutine
		auto get_return_object () noexcept { 
			return co_task {*this}; 
		}
		void return_value (T value) {
			result_.template emplace <1> (std::move (value));
		}
		void unhandled_exception () noexcept {
			result_.template emplace <2> (std::current_exception ());
		}
		auto initial_suspend () { 
			return std::suspend_always {}; 
		}
		auto final_suspend () noexcept {
			struct Awaitable {
				bool await_ready () noexcept { 
					return false; 
				}
				auto await_suspend (std::coroutine_handle <promise_type> h) noexcept {
					return h.promise ().continuation_;
				}
				void await_resume() noexcept {

				}
			};
			return Awaitable {};
		}
	};
	explicit co_task (promise_type & p) noexcept : handle {std::coroutine_handle <promise_type>::from_promise (p)} {}
	co_task (co_task&& t) noexcept : handle {std::exchange (t.handle, {})} {}
	~co_task () {
		if (handle) 
			handle.destroy ();
	}
	// Awaitable interface
	bool await_ready () { 
		return false; 
	}
	auto await_suspend(std::coroutine_handle <> c) {
		handle.promise ().cont = c;
		return handle;
	}
	auto await_resume() -> T {
		auto &result = handle.promise ().res;
		if (result.index () == 1) {
			return std::get <1> (std::move (result));
		} else {
			std::rethrow_exception (std::get<2> (std::move (result)));
		}
	}

private:
	std::coroutine_handle <T> handle;
};