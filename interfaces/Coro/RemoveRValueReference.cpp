export module Maximus.Coro.RemoveRValueReference;

namespace cppcoro
{
	namespace detail
	{
		template<typename T>
		struct remove_rvalue_reference
		{
			using type = T;
		};

		template<typename T>
		struct remove_rvalue_reference<T&&>
		{
			using type = T;
		};

		export template<typename T>
		using remove_rvalue_reference_t = typename remove_rvalue_reference<T>::type;
	}
}