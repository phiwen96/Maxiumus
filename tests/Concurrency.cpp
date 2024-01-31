#include <stdlib.h>
#include <stdio.h>
#include <thread>

import Maximus.Concurrency;

// using std::cout, std::endl;

auto test_0 () -> bool {
	printf ("Test 0\n");

	auto cond = condition <bool> {};
	cond.value () = false;

	auto const body0 = [&cond] {
		cond.lock ();
		printf ("Aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa");
		cond.value () = true;
		cond.wake ();
		cond.unlock ();
	};

	auto const body1 = [&cond] {
		cond.lock ();
		while (not cond.value ()) {
			cond.wait ();
		}
		printf ("Bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb\n");
		cond.unlock ();
	};

	auto thr0 = std::thread {body1};
	auto thr1 = std::thread {body0};

	thr0.join ();
	thr1.join ();

	return true;
}


auto test_1 () -> bool {
	printf ("Test 1\n");
	
	return true;
}

auto main (int argc, char** argv) -> int {
	printf ("Testing Concurrency\n");
	if (not test_0 ()) {
		printf ("failed test 0\n");
		exit (1);
	}
	if (not test_1 ()) {
		printf ("failed test 1\n");
		exit (1);
	}
	return 0;
}