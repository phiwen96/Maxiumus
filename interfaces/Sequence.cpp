export module Maximus.Sequence;

import Maximus.Same;

export template <typename... T>
struct sequence_definitions;

struct element {};

template <typename T>
struct element_type;

template <typename T>
requires requires {typename T::element_type;}
struct element_type <T> {
	using value = typename T::element_type;
};

template <typename T>
requires requires {typename T::value_type;}
struct element_type <T> {
	using value = typename T::value_type;
};

template <typename...>
struct sequence_definitions_getter;

export template <typename T>
using element_type_of = typename sequence_definitions_getter <T>::get <element_type>;

export template <typename T, typename U>
concept Element_type_of = Same <element_type_of <T>, U>;

export template <typename T>
using iterator_type_of = typename sequence_definitions <T>::iterator_type;




template <typename>
struct bajs {};

// template <typename>
struct get_iterator {};

template <typename T>
concept Get_iterator = Same <T, get_iterator>;

template <>
struct bajs <int> {
	template <Get_iterator T>
	using type = int;
};

template <typename T>
concept HasValueType = requires {typename T::value_type;};

#define X (y) \
	constexpr static auto aa = (y)

// #define choose (T)
// 	__builtin_choose_expr (HasValueType <T>, using a = int, using a = double);



// struct element_type {};

template <typename T>
// requires requires {typename T::element_type;} or requires {typename T::value_type;}
// requires requires {typename T::value_type;}
struct sequence_definitions_getter <T> {
	template <template <typename> typename U>
	requires requires {typename U <T>::value;}
	using get = typename U <T>::value;
	// template <Get_iterator>
	// requires requires {typename T::element_type;}
	// using element_type = __builtin_choose_expr ()typename T::value_type;
	// using e = true ? int : char;

	// template <Get_iterator>
	// requires requires {typename T::value_type;}
	// using element_type = typename T::value_type;
	// choose (T);
	// X (4);
};

struct myVec0 {
	using element_type = int;
};

struct myVec1 {};

template <>
struct sequence_definitions <myVec1> {
	using element_type = int;
};


// template <typename T>
// requires requires {typename T::bajs;}
// struct sequence_definitions <T> {

// };


// template <typename T>
// requires requires {typename T::element_type;}
// struct sequence_definitions <T> {
// 	using element_type = typename T::element_type;
// };

// template <typename T>
// requires requires {typename T::value_type;}
// struct sequence_definitions <T> {
// 	using element_type = typename T::value_type;
// };

// template <typename T>
// requires requires {typename T::element_type;}
// using get_bajs = int;

// template <typename T>
// requires requires {typename T::value_type;}
// using get_bajs = int;

// template <typename T>
// requires requires {typename T::iterator_type;}
// struct sequence_definitions <T> {
// 	using iterator_type = typename T::iterator_type;
// };

// template <typename T>
// requires requires {typename T::iterator;}
// struct sequence_definitions <T> {
// 	using iterator_type = typename T::iterator;
// };

// export template <typename T>
// concept Sequence = requires (T t) {

// };