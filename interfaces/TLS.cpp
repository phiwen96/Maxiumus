module;
#include <cstdint>
export module Maximus.TLS;

import Maximus.Bytes;

struct Uint24 {
	unsigned char bits [3]; // assuming char is 8 bits

	Uint24 () : bits () {
	}

	Uint24 (unsigned val) {
		*this = val;
	}

	Uint24 &operator= (unsigned val) {
		// store as little-endian
		bits[2] = val >> 16 & 0xff;
		bits[1] = val >> 8 & 0xff;
		bits[0] = val & 0xff;
		return *this;
	}

	unsigned as_unsigned() const {
		return bits[0] | bits[1] << 8 | bits[2] << 16;
	}
};

enum HandshakeType {
	client_hello = 1,
	server_hello = 2,
	new_session_ticket = 4,
	end_of_early_data = 5, 
	encrypted_extensions = 8,
	certificate = 11,
	certificate_request = 13,
	certificate_verify = 15,
	finished = 20,
	key_update = 24,
	message_hash = 254
};

struct Handshake {
	HandshakeType msg_type;
	Uint24 length;
};