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
import Maximus.TLS;

#define MAXDATASIZE 100

auto main (int argc, char** argv) -> int {
	int sockfd, numbytes;
	char buf[MAXDATASIZE];
	struct addrinfo hints, *servinfo, *p;
	int rv;
	char s[INET6_ADDRSTRLEN];
	if (argc != 3) {
		fprintf(stderr, "usage: hostname port\n");
		exit(1);
	}
	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	char* p_end{};
	char* pp = argv [2];
	long const port = std::strtol(pp, &p_end, 10);
    if (pp == p_end) {
		fprintf(stderr, "usage: hostname port\n");
		exit(1);
	}
	if ((rv = getaddrinfo(argv [1], argv [2], &hints, &servinfo)) != 0) {
		fprintf(stderr, "getaddrinfo: %s\n", gai_strerror(rv));
		return 1;
	}
	// loop through all the results and connect to the first we can
	for (p = servinfo; p != NULL; p = p->ai_next) {
		if ((sockfd = socket(p->ai_family, p->ai_socktype, p->ai_protocol)) == -1) {
			perror("client: socket");
			continue;
		}
		if (connect(sockfd, p->ai_addr, p->ai_addrlen) == -1) {
			close(sockfd);
			perror("client: connect");
			continue;
		}
		break;
	}
	if (p == NULL) {
		fprintf(stderr, "client: failed to connect\n");
		return 2;
	}
	// get sockaddr, IPv4 or IPv6:
	auto const get_in_addr = [](struct sockaddr * sa) -> void * {
		if (sa->sa_family == AF_INET) {
			return &(((struct sockaddr_in *)sa)->sin_addr);
		}
		return &(((struct sockaddr_in6 *)sa)->sin6_addr);
	};
	inet_ntop(p->ai_family, get_in_addr((struct sockaddr *)p->ai_addr), s, sizeof s);
	printf("client: connecting to %s\n", s);
	freeaddrinfo(servinfo); // all done with this structure
	if ((numbytes = recv(sockfd, buf, MAXDATASIZE - 1, 0)) == -1) {
		perror("recv");
		exit(1);
	}
	buf[numbytes] = '\0';
	printf("client: received '%s'\n", buf);
	close(sockfd);
	return 0;
}