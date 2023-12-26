#include <cstdint>
#include <iostream>
#include <format>
#include <sstream>
#include <bitset>
import Maximus;

struct K {
	constexpr static auto k = 5;
};

auto set_huge (auto val) -> void {
	unsigned char* rep;
	decltype (val) mask, i, shift;
	auto size = sizeof (val);
	// Figure out the minimum amount of space this “val” will take
	// up in chars (leave at least one byte, though, if “val” is 0).
	for (mask = 0xFF000000; mask > 0x000000FF; mask >>= 8)
	{
		if (val & mask)
		{
			break;
		}
		size--;
	}
	// std::cout << size << std::endl;
	rep = (unsigned char *)malloc(size);
	// Now work backward through the int, masking off each 8-bit
	// byte (up to the first 0 byte) and copy it into the “huge”
	// array in big-endian format.
	mask = 0x000000FF;
	shift = 0;
	for (i = size; i; i--)
	{
		rep[i - 1] = (val & mask) >> shift;
		mask <<= 8;
		shift += 8;
	}

	for (i = 0; i < size; ++i) {
		// std::cout << rep [i] << std::endl;
		// std::cout << rep [i] << " : ";
		std::cout << std::format ("{:b}", rep [i]);
	}
	std::cout << std::endl;
}

template<typename T>
static std::string toBinaryString(const T& x)
{
    std::stringstream ss;
    ss << std::bitset<sizeof(T) * 8>(x);
    return ss.str();
}

static_assert (HasElementType <char*> and Same <char, element_type <char*>>);

auto main (int argc, char** argv) -> int {
	ProtocolVersion auto pv = uint16_t {0x0304};
	// using protocol_version = 
	// std::cout << sizeof (unsigned int) << std::endl;
	std::cout << toBinaryString ((unsigned int) 255) << std::endl;
	// set_huge (255);
	// set_huge (256);
	// std::cout << std::format ("{:b}", 255) << std::endl;
	aa ();
	return 0;
}