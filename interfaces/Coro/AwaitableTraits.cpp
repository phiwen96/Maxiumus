export module Maximus.Coro.AwaitableTraits;

import Maximus.Coro.GetAwaiter;
import <type_traits>;

	export template<typename T, typename = void>
	struct awaitable_traits
	{};

	export template<typename T>
	struct awaitable_traits<T, std::void_t<decltype(detail::get_awaiter(std::declval<T>()))>>
	{
		using awaiter_t = decltype(detail::get_awaiter(std::declval<T>()));

		using await_result_t = decltype(std::declval<awaiter_t>().await_resume());
	};