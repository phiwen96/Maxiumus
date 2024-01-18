#include <iostream>
#include <queue>

using std::cout, std::endl;

import Maximus.Bool;


template <typename task>
requires requires (task t) {
	t.execute ();
	{t.complete ()} -> Bool;
}
struct scheduler {
	std::queue <task> queue;
};


auto main (int argc, char** argv) -> int {
	cout << "task" << endl;

	return 0;
}