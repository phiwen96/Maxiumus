module;
#include <cstdint>
export module Maximus;

export import Maximus.Bytes;
export import Maximus.Same;
export import Maximus.Concurrency;

export using opaque = byte;

export template <typename T>
concept Opaque = Byte <T> and Same <T, opaque>;

export template <typename T>
concept ProtocolVersion = Bytes <T, 2>;

export template <typename T>
concept Extension = MinBytes <T, 1> and MaxBytes <T, 65535>;

template <typename T>
struct has_element_type {
	constexpr static auto value = false;
};

export template <typename T>
concept HasElementType = has_element_type <T>::value;

export template <typename T>
requires HasElementType <T>
using element_type = typename has_element_type <T>::type;

// export template <typename T>
// requires HasElementType <T>
// using element_type = typename has_element_type <T>::type;

// export template <typename T, typename U>
// concept ElementType = HasElementType <T> and Same <get_element_type <T>, U>;

// export template <typename T>
// concept Random = Bytes <T, 32> and ElementType <T, opaque>;





export using datum = opaque [3];

// export template <typename 

export void aa ();

// uint8 uint16[2];
// uint8 uint24[3];
// uint8 uint32[4];
// uint8 uint64[8];



template <typename T>
struct has_element_type <T*> {
	constexpr static auto value = true;
	using type = T;
};

template <typename T>
requires requires {typename T::value_type;} 
struct has_element_type <T> {
	constexpr static auto value = true;
	using type = typename T::value_type;
};



