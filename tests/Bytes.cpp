import Maximus.Bytes;

static_assert (Bytes <char, 1>);
static_assert (Bytes <int, 4>);
static_assert (Bytes <unsigned short, 2>);
static_assert (not Bytes <unsigned char, 2>);
static_assert (Byte <byte>);

auto main (int argc, char** argv) -> int {
	Bytes <1> auto c = 'a';
	return 0;
}