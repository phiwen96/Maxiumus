export module Maximus.Coro.BrokenPromise;
import <stdexcept>;

	/// \brief
	/// Exception thrown when you attempt to retrieve the result of
	/// a task that has been detached from its promise/coroutine.
	export class broken_promise : public std::logic_error
	{
	public:
		broken_promise()
			: std::logic_error("broken promise")
		{}
	};
