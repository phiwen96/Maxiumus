#include <cstdlib>
#include <cstring>
#include <functional>
#include <iostream>
#include <boost/asio.hpp>
#include <boost/asio/ssl.hpp>
#include <boost/beast.hpp>

// using namespace boost::beast;
// using namespace boost::asio;

using std::string;
using std::cout;


int main(int argc, char* argv[]) {
	const string host = "github.com";//"www.google.com";
    const string path = "/";
    const string port = "443";

    boost::asio::io_service svc;

    auto ctx = boost::asio::ssl::context {boost::asio::ssl::context::sslv23_client};
    auto ssocket = boost::asio::ssl::stream<boost::asio::ip::tcp::socket> { svc, ctx };
    auto resolver = boost::asio::ip::tcp::resolver {svc};
    auto it = resolver.resolve(host, port);
    connect (ssocket.lowest_layer(), it);
    ssocket.handshake (boost::asio::ssl::stream_base::handshake_type::client);
    auto req = boost::beast::http::request<boost::beast::http::string_body> { boost::beast::http::verb::get, path, 11 };
    req.set(boost::beast::http::field::host, host);
    boost::beast::http::write(ssocket, req);
    auto res = boost::beast::http::response<boost::beast::http::string_body> {};
    auto buffer = boost::beast::flat_buffer {};
    boost::beast::http::read (ssocket, buffer, res);
    cout << "Headers" << std::endl;
    // cout << res.base() << std::endl << std::endl;
    // cout << "Body" << std::endl;
    // cout << res.body() << std::endl << std::endl;

	return 0;
}








// #include <iostream>
// #include <stdlib.h>
// #include <stdio.h>
// #include <string.h>
// // #include <openssl/bio.h>
// // #include <openssl/ssl.h>
// // #include <openssl/err.h>
// #include <boost/asio.hpp>
// #include <boost/bind/bind.hpp>
// #include <boost/asio/ssl.hpp>
// // #include <boost/url/src.hpp>
// #include <boost/url/url.hpp>
// #include <boost/url/url_view.hpp>

// using boost::asio::ip::tcp;
// // namespace asio = boost::asio;
// // namespace ssl = boost::asio::ssl;
// // using tcp = boost::asio::ip::tcp;

// using std::placeholders::_1;
// using std::placeholders::_2;

// // void handle_read(const boost::system::error_code& error,
// //                  size_t bytes_transferred,
// //                  std::string& response) {
// //     if (!error) {
// //         response.resize(bytes_transferred);
// //         std::cout << "Response Payload:" << std::endl << response << std::endl;
// //     } else {
// //         std::cerr << "Error reading response: " << error.message() << std::endl;
// //     }
// // }

// enum { max_length = 1024 };

// class client {
// public:
// 	client(boost::asio::io_service &io_service,
// 		   boost::asio::ssl::context &ssl_context,
// 		   boost::urls::url const &url)
// 		: resolver_(io_service),
// 		  socket_(io_service, ssl_context)
// 	{

// 		const std::string server = url.host();
// 		const std::string path = url.path();
// 		const std::string scheme = url.scheme();
// 		// Form the request. We specify the "Connection: close" header so that the
// 		// server will close the socket after transmitting the response. This will
// 		// allow us to treat all data up until the EOF as the content.
// 		std::ostream request_stream(&request_);
// 		request_stream << "GET " << path << " HTTP/1.0\r\n";
// 		request_stream << "Host: " << server << "\r\n";
// 		request_stream << "Accept: */*\r\n";
// 		request_stream << "Connection: close\r\n\r\n";

// 		// Start an asynchronous resolve to translate the server and service names
// 		// into a list of endpoints.
// 		// std::cout << "client: resolving " << server << " (scheme " << scheme << ") ...\n";
// 		// Always use https for resolving. If the server really is on http only,
// 		// the resolver will manage it anyways.
// 		// If your system doesn't define service https (in /etc/services)
// 		// simply use the port number 443 here.
// 		tcp::resolver::query query(server, "https");
// 		resolver_.async_resolve(query,
// 								boost::bind(&client::handle_resolve, this,
// 											boost::asio::placeholders::error,
// 											boost::asio::placeholders::iterator));
// 	}

// private:
// 	void handle_resolve(const boost::system::error_code &err,
// 						tcp::resolver::iterator endpoint_iterator)
// 	{
// 		if (!err)
// 		{
// 			std::cout << "Resolve OK"
// 					  << "\n";
// 			socket_.set_verify_mode(boost::asio::ssl::verify_peer);
// 			socket_.set_verify_callback(
// 				boost::bind(&client::verify_certificate, this, _1, _2));

// 			boost::asio::async_connect(socket_.lowest_layer(), endpoint_iterator,
// 									   boost::bind(&client::handle_connect, this,
// 												   boost::asio::placeholders::error));
// 		}
// 		else
// 		{
// 			std::cout << "Error resolve: " << err.message() << "\n";
// 		}
// 	}

// 	bool verify_certificate(bool preverified,
// 							boost::asio::ssl::verify_context &ctx)
// 	{
// 		std::cout << "verify_certificate (preverified " << preverified << " ) ...\n";
// 		// The verify callback can be used to check whether the certificate that is
// 		// being presented is valid for the peer. For example, RFC 2818 describes
// 		// the steps involved in doing this for HTTPS. Consult the OpenSSL
// 		// documentation for more details. Note that the callback is called once
// 		// for each certificate in the certificate chain, starting from the root
// 		// certificate authority.

// 		// In this example we will simply print the certificate's subject name.
// 		char subject_name[256];
// 		X509 *cert = X509_STORE_CTX_get_current_cert(ctx.native_handle());
// 		X509_NAME_oneline(X509_get_subject_name(cert), subject_name, 256);
// 		std::cout << "Verifying " << subject_name << "\n";

// 		// dummy verification
// 		return true;
// 	}

// 	void handle_connect(const boost::system::error_code &err)
// 	{
// 		std::cout << "handle_connect\n";
// 		if (!err)
// 		{
// 			std::cout << "Connect OK "
// 					  << "\n";
// 			socket_.async_handshake(boost::asio::ssl::stream_base::client,
// 									boost::bind(&client::handle_handshake, this,
// 												boost::asio::placeholders::error));
// 		}
// 		else
// 		{
// 			std::cout << "Connect failed: " << err.message() << "\n";
// 		}
// 	}

// 	void handle_handshake(const boost::system::error_code &error)
// 	{
// 		std::cout << "handle_handshake start \n";
// 		if (!error)
// 		{
// 			std::cout << "Handshake OK "
// 					  << "\n";
// 			std::cout << "Request: "
// 					  << "\n";
// 			const char *header = boost::asio::buffer_cast<const char *>(request_.data());
// 			std::cout << header << "\n";

// 			// The handshake was successful. Send the request.
// 			boost::asio::async_write(socket_, request_,
// 									 boost::bind(&client::handle_write_request, this,
// 												 boost::asio::placeholders::error));
// 		}
// 		else
// 		{
// 			std::cout << "Handshake failed: " << error.message() << "\n";
// 		}
// 	}

// 	void handle_write_request(const boost::system::error_code &err)
// 	{
// 		std::cout << "handle_write_request start \n";
// 		if (!err)
// 		{
// 			// Read the response status line. The response_ streambuf will
// 			// automatically grow to accommodate the entire line. The growth may be
// 			// limited by passing a maximum size to the streambuf constructor.
// 			boost::asio::async_read_until(socket_, response_, "\r\n",
// 										  boost::bind(&client::handle_read_status_line, this,
// 													  boost::asio::placeholders::error));
// 		}
// 		else
// 		{
// 			std::cout << "Error write req: " << err.message() << "\n";
// 		}
// 	}

// 	void handle_read_status_line(const boost::system::error_code &err)
// 	{
// 		std::cout << "handle_read_status_line start \n";
// 		if (!err)
// 		{
// 			std::string myString;  

// 			// Convert streambuf to std::string  
// 			std::istream(&response_) >> myString;
// 			std::cout << myString << std::endl;
// 			// Check that response is OK.
// 			std::istream response_stream(&response_);
// 			std::string http_version;
// 			response_stream >> http_version;
// 			unsigned int status_code;
// 			response_stream >> status_code;
// 			std::string status_message;
// 			std::getline(response_stream, status_message);
// 			if (!response_stream || http_version.substr(0, 5) != "HTTP/")
// 			{
// 				std::cout << "Invalid response\n";
// 				return;
// 			}
// 			if (status_code != 200)
// 			{
// 				std::cout << "Response returned with status code ";
// 				std::cout << status_code << "\n";
// 				return;
// 			}
// 			std::cout << "Status code: " << status_code << "\n";

// 			// Read the response headers, which are terminated by a blank line.
// 			boost::asio::async_read_until(socket_, response_, "\r\n\r\n",
// 										  boost::bind(&client::handle_read_headers, this,
// 													  boost::asio::placeholders::error));
// 		}
// 		else
// 		{
// 			std::cout << "Error: " << err.message() << "\n";
// 		}
// 	}

// 	void handle_read_headers(const boost::system::error_code &err)
// 	{
// 		std::cout << "handle_read_headers\n";
// 		if (!err)
// 		{
// 			// Process the response headers.
// 			std::istream response_stream(&response_);
// 			std::string header;
// 			while (std::getline(response_stream, header) && header != "\r")
// 				std::cout << header << "\n";
// 			std::cout << "\n";

// 			// Write whatever content we already have to output.
// 			if (response_.size() > 0)
// 				std::cout << &response_;

// 			// Start reading remaining data until EOF.
// 			boost::asio::async_read(socket_, response_,
// 									boost::asio::transfer_at_least(1),
// 									boost::bind(&client::handle_read_content, this,
// 												boost::asio::placeholders::error));
// 		}
// 		else
// 		{
// 			std::cout << "Error: " << err << "\n";
// 		}
// 	}

// 	void handle_read_content(const boost::system::error_code &err)
// 	{
// 		std::cout << "handle_read_content\n";
// 		if (!err)
// 		{
// 			// Write all of the data that has been read so far.
// 			std::cout << &response_;

// 			// Continue reading remaining data until EOF.
// 			boost::asio::async_read(socket_, response_,
// 									boost::asio::transfer_at_least(1),
// 									boost::bind(&client::handle_read_content, this,
// 												boost::asio::placeholders::error));
// 		}
// 		else if (err != boost::asio::error::eof)
// 		{
// 			std::cout << "Error: " << err << "\n";
// 		}
// 	}

// 	tcp::resolver resolver_;
// 	boost::asio::ssl::stream<boost::asio::ip::tcp::socket> socket_;
// 	boost::asio::streambuf request_;
// 	boost::asio::streambuf response_;
// };

// auto main (int argc, char** argv) -> int {
// 	std::cout << "Running test Net." << std::endl;

// 	std::string host = "https://www.google.com"; // Replace with actual Hostname and Port
//     std::string path = "";

// 	auto uv = boost::urls::url_view {argv [1]};
// 	auto url = uv;


// 	auto io_context = boost::asio::io_context {};
// 	// auto resolver = tcp::resolver {io_context};
// 	// auto endpoints = resolver.resolve(argv[1], argv[2]);
	
// 	auto ctx = boost::asio::ssl::context {boost::asio::ssl::context::sslv23};
//     ctx.set_default_verify_paths();

//     auto c = client {io_context, ctx, url};

//     io_context.run();

// 	// asio::io_context io_context;
    
//     // tcp::socket socket(io_context);
//     // ssl::stream<tcp::socket> ssl_socket(io_context, ctx);

// 	// tcp::resolver::results_type endpoints = resolver.resolve(host, "https");
//     // asio::connect(ssl_socket.lowest_layer(), endpoints);

// 	// ssl_socket.handshake(ssl::stream_base::client);

// 	// std::string request = "GET / HTTP/1.1\r\n\r\n";

// 	// asio::write(ssl_socket, asio::buffer(request));

//     // // Read the response asynchronously
//     // std::string response;
//     // asio::async_read(ssl_socket, asio::dynamic_buffer(response), std::bind(&handle_read, std::placeholders::_1, std::placeholders::_2, std::ref(response)));
// 	// std::cout << response << std::endl;
//     // // Run the asio event loop
//     // io_context.run();


// 	return 0;
// }