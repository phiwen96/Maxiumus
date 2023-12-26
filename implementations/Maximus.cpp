module;
#include <iostream>
module Maximus;

void aa () {
	std::cout << "hello world" << std::endl;
}

// template <typename T>
// struct has_element_type {
// 	constexpr static auto value = false;
// };

// template <>
// struct has_element_type <char*> {
// 	constexpr static auto value = true;
// 	using type = char*;
// };