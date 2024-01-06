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

using std::cout, std::wcout, std::cin, std::wcin, std::endl, std::cerr, std::string, std::wstring, std::string_view, std::vector, std::pair, std::getline, std::ifstream, std::ofstream, std::fstream, std::regex, std::wregex, std::smatch, std::wsmatch, std::sregex_iterator, std::wsregex_iterator, std::istreambuf_iterator;
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
	{
		struct sigaction sa = {};
		sa.sa_handler = sigint_handler;
		sa.sa_flags = 0;

		if (sigaction (SIGINT, &sa, NULL) == -1) {
			cerr << "internal error >> sigaction" << endl;
			exit(1);
		}
	}

	// saves.open (saves_file_name, std::ios_base::app);
	// ifstream in{"table.txt"}; // input file
	// if (!in)
	// 	error("no input file\n");
	saves.open (saves_file_name);
	if (not saves.is_open ()) {
		cerr << "internal error >> no save file named \"" << saves_file_name << "\"" << endl;
		exit (0);
	}

	auto pattern = regex {R"(\[questions\])"};
	auto matches = smatch {};
	auto const content = string {istreambuf_iterator<char> {saves}, istreambuf_iterator<char> {}};
	saves.close ();
	// cout << content << endl;
	
	{
		auto iter = sregex_iterator {content.begin (), content.end (), pattern};
		if (iter == sregex_iterator {}) {
			cerr << "internal error >> no toml table with name \"questions\" found" << endl;
			exit (1);
		}
	}
	// auto inp = string {};
	// getline (cin, inp);
	// auto patt = regex {R"([åäö]+)"};
	// auto pattern1 = regex {R"(=)"};
	// for (auto iter = sregex_iterator {content.begin (), content.end (), pattern1}; iter != sregex_iterator {}; ++iter) {
	// 	auto iter2 = sregex_iterator {};
	// 	// cout << "hihihi" << endl;
	// 	cout << iter -> str () << endl;
	// }

	auto qst = vector <pair <string, string>> {};
	pattern = regex {R"(\"+([åäöÅÄÖ,.\(\)\[\]/\-|]*\w*[åäöÅÄÖ,.\(\)\[\]/-|]*\w*\s*\?*)+\"+)"};
	for (auto iter = sregex_iterator {content.begin (), content.end (), pattern}; iter != sregex_iterator {}; ++iter) {
		qst.push_back ({iter -> str (), (++iter) -> str ()});
		qst.back().first.erase(0, 1);
		qst.back().first.pop_back();
		qst.back().second.erase(0, 1);
		qst.back().second.pop_back();

		// cout << "hihihi" << endl;
		// cout << iter -> str () << endl;
	}

	static thread_local auto engine = std::default_random_engine{std::random_device{}()};
	
	// return dist(engine);

	for (auto i = 0; i < qst.size (); ++i) {
		auto dist = std::uniform_int_distribution<> {0, (int) qst.size ()};
		auto r = dist (engine);
		auto iter = qst.begin () + r;
		cout << iter->first << endl;
		auto input = string {};
		getline (cin, input);
		cout << iter->second << endl << endl;
		qst.erase (iter);
		getline (cin, input);
	}

	// for (auto& i : qst) {
	// 	cout << i.first << endl;
	// 	cout << i.second << endl;
	// }

	// for (auto iter = sregex_iterator {inp.begin (), inp.end (), patt}; iter != sregex_iterator {}; ++iter) {
	// 	cout << "match! " << iter -> str () << endl;
	// }
	// return 0;
	// cout << iter -> str () << endl;

	// pattern = regex {R"(\"{1,3}[\w\W]+\s*[\w\W]*\"{1,3})"};
	// pattern = wregex {LR"(\"+(\w+\s*\w*\?*)+\"+)"};
	// varför funkar inte regex på å ä ö ?
	// pattern = wregex {LR"(\"+(\w*[åäöÅÄÖ]*\s*\w*[åäöÅÄÖ]*\?*)+\"+)"};
	// auto pattern2 = regex {R"(\"+\w+\"+)"};
	// pattern = "\"+w+\"+";
	// cout << content << endl;
	// iter = sregex_iterator {content.begin ()/* + iter -> position ()*/, content.end (), pattern};

	// auto test_string = string {"\"Vad står OSI för?\" = \"Open Systems Interconnection\""};
	// test_string = "\"hej\"";
	// test_string = "\"hej jag?\"";
	// cout << test_string << endl;
	// auto pattern2 = regex {R"(\"\w+\s*\w*\?*\")"};
	// auto matches2 = smatch {};
	// saves.open(saves_file_name);
	// if (regex_search (test_string, matches2, pattern2)) {
	// 	for (auto i = 0; i < matches2.length (); ++i) {
	// 		cout << "yay" << endl;
	// 		cout << matches2 [i].str () << endl;
	// 	}
	// }
		
	// if (regex_match (content, matches2, pattern2)) {
	// 	cout << "yay" << endl;
	// 	for (auto i = 0; i < matches.length (); ++i) {
	// 		cout << matches [i].str () << endl;
	// 	}
	// }
	
	// cout << iter -> str () << endl;
	// for (auto iter = wsregex_iterator {content.begin (), content.end (), pattern}; iter != wsregex_iterator {}; ++iter) {
	// 	cout << "hihihi" << endl;
	// 	wcout << iter -> str () << endl;
	// }
	
	// for (; iter != sregex_iterator {}; ++iter) {
	// 	cout << iter -> prefix().str() << ":" << iter -> str () << endl;
	// }
	return 0;
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
	// MODE:
	// cout << "choose mode >> ";
	// cin >> input;
	// if (input == "fastmode") {

	// auto const get_input = [&] () -> void {
	// 	getline (cin, input);
	// };

	// while (true) {
	// 	saves.open (saves_file_name, std::ios_base::app);
	// 	cout << 
	// }

	while (true) {
		saves.open(saves_file_name, std::ios_base::app);
		QUESTION:
		cout << "question >> ";
		getline (cin, input);
		if (input.length () == 0) {
			goto QUESTION;
		}
		// cin >> input;
		saves << "\"" << input << "\"";
		ANSWER:
		cout << "answer >> ";
		getline (cin, input);
		if (input.length () == 0) {
			goto ANSWER;
		}
		// cin >> input;
		saves << " = \"" << input << "\"\n\n";
		saves.close();
	}
	// } else if (input == "learn") {
	// 	cout << "error >> mode not yet implemented" << endl;
	// 	exit (1);
	// } else {
	// 	cout << "error >> no mode named \"" << input << "\"" << endl;
	// 	goto MODE;
	// }
	
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

