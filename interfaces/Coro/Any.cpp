export module Maximus.Coro.Any;

namespace cppcoro
{
	namespace detail
	{
		// Helper type that can be cast-to from any type.
		export struct any
		{
			template<typename T>
			any(T&&) noexcept
			{}
		};
	}
}
