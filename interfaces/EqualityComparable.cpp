export module Maximus.EqualityComparable;

import Maximus.Bool;

export template <typename T>
concept EqualityComparable = requires (T x, T y) {
	{x == y} -> Bool;
	{x != y} -> Bool;
	{y == x} -> Bool;
	{y != x} -> Bool;
};