#include <stdio.h>

import Maximus.Concurrency;

// using std::cout, std::endl;

auto main (int argc, char** argv) -> int {
	printf ("Testing Concurrency\n");
	auto thr = thread {};
	thr.join ();
	return 0;
}