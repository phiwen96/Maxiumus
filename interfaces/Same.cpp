export module Maximus.Same;

template <typename T, typename U>
struct same_t 
{
	constexpr static bool value = false;
};

template <typename T>
struct same_t <T, T>
{
	constexpr static bool value = true;
};

export template <typename T, typename U>
concept Same = same_t <T, U>::value;