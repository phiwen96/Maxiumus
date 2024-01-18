module;

#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

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

export template <Mutex Mtx = mutex>
requires requires (Mtx mtx, pthread_cond_t& cv) {
	mtx.wait (cv);
}
struct condition {
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
		mtx.wait (handle);
	}
private:
	Mtx mtx;
	pthread_cond_t handle;
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