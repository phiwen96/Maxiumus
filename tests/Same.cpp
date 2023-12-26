import Maximus.Same;

static_assert (Same <bool, bool>);
static_assert (not Same <bool, int>);

auto main (int argc, char** argv) -> int {
	Same <bool> auto b = true;
	return 0;
}