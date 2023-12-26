export module Maximus.Number;

export template <typename T>
concept Number = requires (T x, T y) {
	x + y;
	x - y;
	x * y;
	x / y;
	x = x;
	x = 0;
};