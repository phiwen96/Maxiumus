#include <string>
#include <iostream>
#include <fstream>
#include <filesystem>
#include <string_view>
#include <regex>
#include <sstream>
#include <signal.h>
#include <vector>
#include <utility>
#include <random>
#include <assert.h>
#include <openssl/bio.h>
#include <openssl/err.h>
#include <openssl/ssl.h>
#include <nlohmann/json.hpp>
using namespace nlohmann;

using std::cout, std::wcout, std::cin, std::wcin, std::endl, std::cerr, std::string, std::wstring, std::string_view, std::vector, std::pair, std::getline, std::ifstream, std::ofstream, std::fstream, std::regex, std::wregex, std::smatch, std::wsmatch, std::sregex_iterator, std::wsregex_iterator, std::istreambuf_iterator;
using namespace std::filesystem;
using namespace std::literals::string_literals;
using namespace std::literals::string_view_literals; 

auto main (int argc, char** argv) -> int {
	// return 0;
	// const char* hostname           = "example.org";
	// const char* hostname           = "www.google.com";//"github.com";
	// const char* hostname = "rapidapi.com";
	const char* hostname = "api.met.no"; // /compact?lat=51.5&lon=0
    const char* port               = "443";
    // const char* trusted_cert_fname = argv[3];
	const size_t BUF_SIZE = /*16*/20 * 1024;
	char* in_buf = (char*) malloc (BUF_SIZE);
	assert(in_buf);
	char* out_buf = (char*) malloc (BUF_SIZE);
	assert(out_buf);
	SSL_CTX* ctx = SSL_CTX_new (TLS_client_method ());
	// const char* trusted_cert_fname = argv[3];

    BIO* ssl_bio = NULL;
    SSL* ssl = NULL;



    ERR_clear_error();

    ctx = SSL_CTX_new(TLS_client_method());
    assert(ctx);

	if (SSL_CTX_set_default_verify_paths (ctx) <= 0) {
		cerr << "Could not load trusted certificates" << endl;
		exit (1);
	}

	SSL_CTX_set_verify (ctx, SSL_VERIFY_PEER, NULL);
    SSL_CTX_set_mode (ctx, SSL_MODE_AUTO_RETRY);

    ssl_bio = BIO_new_ssl_connect (ctx);
    assert (ssl_bio);
    // Set hostname for connection.
    BIO_set_conn_hostname (ssl_bio, hostname);
    BIO_set_conn_port (ssl_bio, port);

	if (BIO_get_ssl(ssl_bio, &ssl) <= 0) {
		cerr << "BIO_get_ssl" << endl;
		exit (1);
	}

	if (SSL_set_tlsext_host_name(ssl, hostname) <= 0) {
		cerr << "SSL_set_tlsext_host_name" << endl;
		exit (1);
	}

	if (SSL_set1_host(ssl, hostname) <= 0) {
		cerr << "SSL_set1_host" << endl;
		exit (1);
	}

	if (BIO_do_connect(ssl_bio) <= 0) {
		cerr << "BIO_do_connect" << endl;
	}

	// snprintf (out_buf, BUF_SIZE,
	// 	"GET /weatherapi/locationforecast/2.0/compact?lat=51.5&lon=0 HTTP/1.1\r\n"
	// 	"Host: www.api.met.no\r\n"
	// 	"User-Agent: 13284\r\n"
	// 	"Accept: application/json\r\n\r\n");

	snprintf (out_buf, BUF_SIZE,
		"GET /weatherapi/locationforecast/2.0/compact?lat=51.5&lon=0 HTTP/1.1\r\n"
		"Host: www.api.met.no\r\n"
		"User-Agent: 13284\r\n"
		"Accept: application/json\r\n\r\n");

	// fd8d133207msh8d184e1f76d3a4fp1c01f6jsnf4c60039c78d
	// snprintf(
    //     out_buf,
    //     BUF_SIZE,
        // "POST /translate HTTP/1.1\r\n"
		// "Content-Type: application/x-www-form-urlencoded\r\n"
		// "X-Rapidapi-Key: fd8d133207msh8d184e1f76d3a4fp1c01f6jsnf4c60039c78d\r\n"
		// "X-Rapidapi-Host: text-translator2.p.rapidapi.com\r\n"
		// "Host: text-translator2.p.rapidapi.com\r\n"
		// "Content-Length: 48\r\n\r\n"
		// "source_language=en&target_language=id&text=hello",
// 		"GET /v1/find/?query=brad HTTP/1.1\r\n",
// "X-Rapidapi-Key: fd8d133207msh8d184e1f76d3a4fp1c01f6jsnf4c60039c78d\r\n",
// "X-Rapidapi-Host: imdb146.p.rapidapi.com\r\n"
// "Host: imdb146.p.rapidapi.com\r\n\r\n",
// hostname);
	// snprintf(
    //     out_buf,
    //     BUF_SIZE,
    //     "GET / HTTP/1.1\r\n"
    //     "Host: %s\r\n"
    //     "Connection: close\r\n"
    //     "User-Agent: Example TLS client\r\n"
    //     "\r\n",
    //     hostname);

    int request_length = strlen (out_buf);

	int nbytes_written = BIO_write (ssl_bio, out_buf, request_length);
    if (nbytes_written != request_length) {
        cerr << "Could not send all data to the server" << endl;
    }
	// int nbytes_read = 1;
	// while ((nbytes_read = BIO_read (ssl_bio, in_buf, BUF_SIZE)), nbytes_read > 0 or BIO_should_retry (ssl_bio)) {
    //     if (nbytes_read <= 0) {
	// 		break;
    //         // int ssl_error = SSL_get_error (ssl, nbytes_read);
    //         // if (ssl_error == SSL_ERROR_ZERO_RETURN)
    //         //     break;

    //         // if (stderr) {

    //         //     fprintf (stderr, "Error %i while reading data from the server\n", ssl_error);
	// 		// 	exit (1);
	// 		// }
    //         // // goto failure;
	// 		// // cerr << "error" << endl;
	// 		// exit (1);
    //     }
    //     fwrite (in_buf, 1, nbytes_read, stdout);
	// 	// cout << "GOOD" << endl;
    // };
	auto data = string {};
	// auto nbytes_read = 0;
	// do {
	// 	nbytes_read = BIO_read (ssl_bio, in_buf, BUF_SIZE);
	// 	data += (char const*) in_buf;
	// } while (nbytes_read > 0 or BIO_should_retry (ssl_bio));
	while ((SSL_get_shutdown(ssl) & SSL_RECEIVED_SHUTDOWN) != SSL_RECEIVED_SHUTDOWN) {
		int nbytes_read = BIO_read(ssl_bio, in_buf, BUF_SIZE);
		cout << "yay" << endl;

	}
	cout << "no" << endl;
	// cout << data << endl;
	cout << (char const*) in_buf << endl;

	auto weather = json::parse ((char const*) in_buf);
	cout << weather.dump (4) << endl;

	if (ssl_bio) BIO_free_all(ssl_bio);
    if (ctx) SSL_CTX_free(ctx);
    free (out_buf);
    free (in_buf);

    // if (ERR_peek_error ()) {
    //     if (stderr) {
    //         cerr << "Errors from the OpenSSL error queue:" << endl;
    //     }
    //     ERR_clear_error();
    // }

	return 0;
}