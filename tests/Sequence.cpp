#include <vector>
import Maximus.Sequence;

// static_assert (Same <bool, bool>);
// static_assert (not Same <bool, int>);

static_assert (Element_type_of <std::vector <int>, int>);

struct test_sequence_0 {
	using element_type = int;
};

static_assert (Element_type_of <test_sequence_0, int>);

struct test_sequence_1 {
	using value_type = char;
};

static_assert (Element_type_of <test_sequence_1, char>);

struct test_element_0 {};

template <>
struct sequence_definitions <test_element_0> {
	using element_type = double;
};

// static_assert (Element_type_of <test_element_0, double>);



auto main (int argc, char** argv) -> int {
	auto v = std::vector <bool> {};
	// auto a = AA (true);
	// iterator_type_of <decltype (v)> i = v.begin ();
	// Same <bool> auto b = true;
	return 0;
}