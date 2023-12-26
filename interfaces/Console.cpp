module;
#include <unistd.h>
#include <string.h>
export module Maximus.Console;

struct console_t {
	auto operator << (char const* str) -> console_t & {
		write (0, str, strlen (str));
		return *this;
	}
};

export auto console = console_t {};