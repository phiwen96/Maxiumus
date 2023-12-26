#include <stdio.h> 
#include <stdlib.h> 
#include <unistd.h>
#include <errno.h> 
#include <string.h> 
#include <netdb.h> 
#include <sys/types.h> 
#include <netinet/in.h> 
#include <sys/socket.h>
#include <arpa/inet.h>
#include <cstdlib>
#include <iostream>
#include <signal.h>
import Maximus.Socket;

#define MAXDATASIZE 100

volatile sig_atomic_t got_usr1;

void sigint_handler (int sig) {
	/* using a char[] so that sizeof will work */
	const char msg[] = "Ahhh! SIGINT!\n";
	write(0, msg, sizeof(msg));
	got_usr1 = 1;
}

auto main (int argc, char** argv) -> int {

	struct sigaction sa = {
		
	};

	sa.sa_handler = sigint_handler;
	sa.sa_flags = 0; // or SA_RESTART
	sa.sa_mask = 0;

	if (sigaction (SIGINT, &sa, NULL) == -1) {
		perror("sigaction");
		exit(1);
	}

	

	// auto sa = sigaction ()


	if (argc != 3) {
		fprintf(stderr, "usage: hostname port\n");
		exit(1);
	}
	
	char* p_end{};
	char* pp = argv [2];
	long const port = std::strtol(pp, &p_end, 10);
    if (pp == p_end) {
		fprintf(stderr, "usage: hostname port\n");
		exit(1);
	}
	
	auto sockfd = connect_to (argv [1], port);

	auto input = std::string {};

	while (not got_usr1) {
		std::cin >> input;
		send_to (sockfd, input.c_str ());
		char * msg = receive_from (sockfd);
		std::cout << msg << std::endl;
		std::free (msg);
	}

	// send_to (sockfd, "Hello World");
	// auto msg = recieve_from (sockfd);
	// printf("client: received '%s'\n", msg);
	close (sockfd);
	// std::free (msg);
	std::cout << "END" << std::endl;
	return 0;
}