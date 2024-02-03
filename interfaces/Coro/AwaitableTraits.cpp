export module Maximus.Coro.AwaitableTraits;

import <type_traits>;

import Maximus.Coro.GetAwaiter;


	export template<typename T, typename = void>
	struct awaitable_traits
	{};

	export template<typename T>
	struct awaitable_traits<T, std::void_t<decltype(get_awaiter(std::declval<T>()))>>
	{
		using awaiter_t = decltype(get_awaiter(std::declval<T>()));

		using await_result_t = decltype(std::declval<awaiter_t>().await_resume());
	};