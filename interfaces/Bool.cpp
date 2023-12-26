export module Maximus.Bool;

export template <typename T>
concept Bool = requires (T x, T y) {
	{x = true};
	{x = false};
	{x = (x == y)};
	{x = (x != y)};
	{x = !x};
};