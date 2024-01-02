#include <iostream>
#include <fstream>
#include <filesystem>
#include <string>
#include <string_view>
#include <regex>
#include <sstream>
#include <signal.h>

using std::cout, std::cin, std::endl, std::cerr, std::string, std::string_view, std::getline, std::ifstream, std::ofstream, std::fstream, std::regex, std::smatch;
using namespace std::filesystem;
using namespace std::literals::string_literals;
using namespace std::literals::string_view_literals; 

constexpr auto USE_REGEX = false;




// auto try_get_saves (char const* filename) -> ofstream {
// 	// auto file = ofstream {};
// 	// // file.open (filename);
// 	// file.open (filename, std::ios_base::app);
// 	// if (not file.open ()) {
// 	// 	cerr << "internal error >> no save file named \"" << filename << "\"" << endl;
// 	// 	exit (0);
// 	// }
	
// 	return file;
// }

constexpr auto saves_file_name = "saves.toml";
auto saves = fstream {};

void sigint_handler(int sig) {
	/* using a char[] so that sizeof will work */
	// const char msg[] = "Ahhh! SIGINT!\n";
	// write(0, msg, sizeof(msg));
	saves.close ();
	exit (0);
}



auto main () -> int {
	struct sigaction sa = {};
	sa.sa_handler = sigint_handler;
	sa.sa_flags = 0;

	if (sigaction (SIGINT, &sa, NULL) == -1) {
		cerr << "internal error >> sigaction" << endl;
		exit(1);
	}

	// saves.open (saves_file_name, std::ios_base::app);
	saves.open (saves_file_name);
	if (not saves.is_open ()) {
		cerr << "internal error >> no save file named \"" << saves_file_name << "\"" << endl;
		exit (0);
	}
	auto pattern = regex {R"(\[questions*\])"};
	auto matches = smatch {};
	auto content = string {std::istreambuf_iterator<char> {saves}, std::istreambuf_iterator<char> {}};
	saves.close ();
	
	auto iter = std::sregex_iterator {content.begin (), content.end (), pattern};
	if (iter == std::sregex_iterator {}) {
		cerr << "internal error >> no toml table with name \"questions\" found" << endl;
		exit (1);
	}
	pattern = regex {R"(\"\w*\")"};
	iter = std::sregex_iterator {content.begin () + iter -> position (), content.end (), pattern};
	// cout << iter -> str () << endl;
	// if (regex_search (saves, matches, pattern)) {
	// 	cout << "yay" << endl;
	// }
	// while ()
	
	

	


	
	// return 0;
	auto input = string {};
	// auto pattern = regex {R"([a-z])"};
	// auto matches = smatch {};
	cout << "Lets Learn!" << endl;
	cout << "intro >> enter \"fastmode\" to create new questions" << endl;
	cout << "intro >> enter \"learn\" to play" << endl;
	MODE:
	cout << "choose mode >> ";
	cin >> input;
	if (input == "fastmode") {
		while (true) {
			saves.open (saves_file_name, std::ios_base::app);
			cout << "question >> ";
			cin >> input;
			saves << "\"" << input << "\"";
			cout << "answer >> ";
			cin >> input;
			saves << " = \"" << input << "\"\n\n";
			saves.close ();
		};
	} else if (input == "learn") {
		cout << "error >> mode not yet implemented" << endl;
		exit (1);
	} else {
		cout << "error >> no mode named \"" << input << "\"" << endl;
		goto MODE;
	}
	
	// do {
	// 	pattern = regex {""}
	// } while (regex_search (input, matches, pattern));
	
	
	
	// for (; ;) {
		

		

	// 	if constexpr (USE_REGEX) {
	// 		auto pattern = regex {R"([a-z])"};
	// 		auto matches = smatch {};
			// if (regex_search (input, matches, pattern)) {
			// 	cout << "yay" << endl;
			// }
	// 	}
		
	// }
	// cout << "question >> ";
	// cin >> input;



	// auto input = getline (cin, input);

	// cout << "answer >> ";
	// input = 
	
	

	// auto input = ""s;

	// do {

	// 	cin >> input;

	// } while (input != "exit");

	
	
	return 0;
}

