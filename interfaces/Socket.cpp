export module Maximus.Socket;

export auto connect_to (char const* hostname, int port) -> int;
export auto receive_from (int sock) -> char *;
export auto send_to (int sock, char const* msg) -> void;