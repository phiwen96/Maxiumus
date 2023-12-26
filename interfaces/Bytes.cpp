module;
#include <cstddef>
export module Maximus.Bytes;

export using byte = std::byte;

export template <typename T, auto n>
concept Bytes = sizeof (T) == n;

export template <typename T>
concept Byte = Bytes <T, 1>;

export template <typename T, auto n>
concept MaxBytes = sizeof (T) <= n;

export template <typename T, auto n>
concept MinBytes = sizeof (T) >= n;


