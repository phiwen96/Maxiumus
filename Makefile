# make && ./build/tests/Test.WebBrowser

# sudo apt -y install liburing-dev

# GCC=g++-12 -std=gnu++2a -fcoroutines -fmodules-ts -fconcepts-diagnostics-depth=1
CXX = clang++
# --verbose
############### C++ compiler flags ###################
CXX_FLAGS = -D DEBUG -std=gnu++23 -fmodules-ts -fcompare-debug-second -O2 -fno-trapping-math -fno-math-errno -fno-signed-zeros #-fconcepts-diagnostics-depth=2
CXX_MODULES = -fmodules-ts -fmodules -fbuiltin-module-map -fimplicit-modules -fimplicit-module-maps -fprebuilt-module-path=.

CXX_APP_FLAGS = -lpthread 


ifeq ($(OS),Windows_NT) 
    detected_OS := Windows
else
    detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
	CXX_INCLUDES = -I/usr/local/include -I/opt/homebrew/Cellar/glm/0.9.9.8/include -I/opt/homebrew/Cellar/freetype/2.12.1/include/freetype2 #-I/Users/philipwenkel/VulkanSDK/1.3.216.0/macOS/include
endif
ifeq ($(detected_OS),Windows)
	GCC = g++
	CXX_FLAGS += -D WINDOWS
	VULKAN_DIR = C:\VulkanSDK\1.3.224.1
	CXX_LIBS = -L$(VULKAN_DIR)\Lib #-lvulkan
	CXX_INCLUDES += -I$(VULKAN_DIR)\Include
endif
ifeq ($(detected_OS),Darwin)
	VULKAN_VERSION = 1.3.236.0
	VULKAN_SDK = /Users/philipwenkel/VulkanSDK/$(VULKAN_VERSION)
	LIB_NLOHMANN := /opt/homebrew/Cellar/nlohmann-json/3.11.2
	LIB_OPENSSL := /opt/homebrew/Cellar/openssl@3/3.1.2
	GLSLC_COMPILER = $(VULKAN_SDK)/macOS/bin/glslc
	GCC = /opt/homebrew/Cellar/gcc/13.2.0/bin/g++-13
	CXX_FLAGS += -D MACOS -D FONTS_DIR=\"/System/Library/Fonts/Supplemental\"
	CXX_LIBS = -L$(LIB_OPENSSL)/lib -lssl -lcrypto -L/opt/homebrew/lib -L/opt/homebrew/Cellar/glfw/3.3.8/lib -lglfw -L$(VULKAN_SDK)/macOS/lib -lvulkan.1.3.236 -lSDL2 -L/opt/homebrew/Cellar/freetype/2.13.2/lib -lfreetype
	CXX_INCLUDES += -I$(LIB_OPENSSL)/include -I$(LIB_NLOHMANN) -I$(VULKAN_SDK)/macOS/include
endif
ifeq ($(detected_OS),Linux)
	# LIB_OPENSSL := /usr/include/openssl
	GLSLC_COMPILER = /usr/bin/glslc
	GCC = /usr/bin/g++-12
	CXX_FLAGS += -D LINUX
	# CXX_LIBS += -lglfw 
    CXX_APP_FLAGS += -lrt
	CXX_LIBS = -lrt -lglfw -lvulkan -luring -lfreetype -lssl -lcrypto
	CXX_INCLUDES += -I/usr/include/freetype2 
endif

PROJ_DIR := $(CURDIR)
DOCS_DIR := $(PROJ_DIR)/docs
# LIB_DIR := $(PROJ_DIR)/libs/$(PROJ)
# interfaces_DIR := $(LIB_DIR)/interfaces
BUILD_DIR := $(PROJ_DIR)/build
OBJ_DIR := $(BUILD_DIR)/obj
TESTS_DST_DIR := $(BUILD_DIR)/tests
TESTS_SRC_DIR := $(PROJ_DIR)/tests
INT_DST := $(OBJ_DIR)/interfaces
IMPL_DST := $(OBJ_DIR)/implementations

_BUILD_DIRS := obj docs tests obj/interfaces obj/implementations
BUILD_DIRS := $(foreach dir, $(_BUILD_DIRS), $(addprefix $(BUILD_DIR)/, $(dir)))

directories := $(foreach dir, $(BUILD_DIRS), $(shell [ -d $(dir) ] || mkdir -p $(dir)))


# apps:= main
tests:= $(TESTS_DST_DIR)/Test.WebBrowser#Test.Concepts.Char Test.Crypto.Base64#Test.Crypto.Symmetric.DES # Test.Async Test.App
# all: $(tests) $(apps)
all: $(TESTS_DST_DIR)/Maximus

std_headers:
	$(GCC) -std=c++2b -fmodules-ts -x c++-header /usr/include/GLFW/glfw3.h
	$(GCC) -std=c++2b -fmodules-ts -x c++-header /usr/include/glm/glm.hpp
	$(GCC) -std=c++2b -fmodules-ts -x c++-header /usr/include/vulkan/vulkan_core.h
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header array
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header vector
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header iostream
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header tuple
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header utility
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header coroutine
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header type_traits
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header string
	$(GCC) -std=c++2b -fmodules-ts -x c++-system-header algorithm


# Awaitable.o: Awaitable.cpp
# 	$(GCC) $(CXX_FLAGS) -c $<

# Coro.o: Coro.cpp
# 	$(GCC) $(CXX_FLAGS) -c $<

# Overload.o: Overload.cpp 
# 	$(GCC) $(CXX_FLAGS) -c $<

# Bool.o: Bool.cpp 
# 	$(GCC) $(CXX_FLAGS) -c $<

# Mector.o: Mector.cpp 
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

# Vulkan.o: Vulkan.cpp Mector.o 
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

# Xashi.o: Xashi.cpp Vulkan.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)
# server_keypair.pem: 

ca_cert.pem:
	openssl req -newkey ED448 -x509 -subj "/CN=Root CA" -addext "basicConstraints=critical,CA:TRUE" -days 3650 -noenc -keyout ca_keypair.pem -out ca_cert.pem

server_csr.pem:
	openssl req -newkey ED448 -subj "/CN=localhost" -addext "basicConstraints=critical,CA:FALSE" -noenc -keyout server_keypair.pem -out server_csr.pem

server_cert.pem: server_csr.pem ca_cert.pem 
	openssl x509 -req -in server_csr.pem -copy_extensions copyall -CA ca_cert.pem -CAkey ca_keypair.pem -days 3650 -out server_cert.pem

Concepts.Reference.LValue.o: Concepts.Reference.LValue.cpp 
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Concepts.Reference.RValue.o: Concepts.Reference.RValue.cpp 
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Concepts.Reference.o: Concepts.Reference.cpp Concepts.Reference.RValue.o Concepts.Reference.LValue.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Concepts.Same.o: Concepts.Same.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Concepts.Convertible.o: Concepts.Convertible.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Types.Predicate.o: Types.Predicate.cpp Concepts.Same.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Types.IfElse.o: Types.IfElse.cpp 
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Types.List.o: Types.List.cpp Types.IfElse.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Types.AnyOf.o: Types.AnyOf.cpp Types.Predicate.o Types.List.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Types.AllOf.o: Types.AllOf.cpp Types.Predicate.o Types.List.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Types.o: Types.cpp Types.AllOf.o Types.AnyOf.o Types.List.o Types.IfElse.o Types.Predicate.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Types := Types.o Types.AllOf.o Types.AnyOf.o Types.List.o Types.IfElse.o Types.Predicate.o Concepts.Convertible.o Concepts.Same.o

Concepts.Char.o: Concepts.Char.cpp Types.o Concepts.Convertible.o Concepts.Same.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Concepts.o: Concepts.cpp Concepts.Char.o Concepts.Convertible.o Concepts.Same.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Concepts := Concepts.o Concepts.Char.o $(Types)

# Byte.o: Byte.cpp 
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

# File.o: File.cpp Concepts.Char.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Digest.o: Crypto.Digest.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.HMAC.o: Crypto.HMAC.cpp Crypto.Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.MD5.o: Crypto.MD5.cpp Crypto.Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.SHA.o: Crypto.SHA.cpp Crypto.Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.PRF.o: Crypto.PRF.cpp Crypto.Digest.o Crypto.HEX.o Crypto.HMAC.o Crypto.Digest.o Crypto.MD5.o Crypto.SHA.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.ECC_int.o: Crypto.ECC_int.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Huge.o: Crypto.Huge.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.HEX.o: Crypto.HEX.cpp Concepts.Char.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.ECC.o: Crypto.ECC.cpp Crypto.Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.DSA.o: Crypto.DSA.cpp Crypto.HEX.o Crypto.Huge.o Crypto.SHA.o Crypto.Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Symmetric.DES.o: Crypto.Symmetric.DES.cpp Byte.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Symmetric.AES.o: Crypto.Symmetric.AES.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Symmetric.RC4.o: Crypto.Symmetric.RC4.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Public.RSA.o: Crypto.Public.RSA.cpp Crypto.HEX.o Crypto.Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Public.DH.o: Crypto.Public.DH.cpp Crypto.Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Base64.o: Crypto.Base64.cpp Concepts.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.ASN1.o: Crypto.ASN1.cpp Crypto.Base64.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.X509.o: Crypto.X509.cpp Crypto.SHA.o Crypto.MD5.o Crypto.Digest.o Crypto.ASN1.o Crypto.Public.RSA.o Crypto.DSA.o Crypto.ECC.o Crypto.HEX.o Crypto.Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.ECDSA.o: Crypto.ECDSA.cpp Crypto.Huge.o Crypto.Digest.o Crypto.SHA.o Crypto.HEX.o Crypto.DSA.o Crypto.ECC.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Crypto.Privkey.o: Crypto.Privkey.cpp Crypto.Huge.o Crypto.Public.RSA.o Crypto.HEX.o File.o Crypto.Symmetric.DES.o Crypto.ASN1.o Crypto.Digest.o Crypto.MD5.o Crypto.SHA.o 
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Net.TLS.o: Net.TLS.cpp Crypto.Privkey.o File.o Crypto.ECDSA.o Crypto.X509.o Crypto.ASN1.o Crypto.Base64.o Crypto.Public.DH.o Crypto.Public.RSA.o Crypto.Symmetric.RC4.o Crypto.Symmetric.AES.o Crypto.Symmetric.DES.o Crypto.DSA.o Crypto.ECC.o Crypto.HEX.o Crypto.Huge.o Crypto.ECC_int.o Crypto.PRF.o Crypto.SHA.o Crypto.MD5.o Crypto.HMAC.o Crypto.Digest.o Byte.o $(Concepts)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

TLS := Net.TLS.o Crypto.Privkey.o File.o Crypto.ECDSA.o Crypto.X509.o Crypto.ASN1.o Crypto.Base64.o Crypto.Public.DH.o Crypto.Public.RSA.o Crypto.Symmetric.RC4.o Crypto.Symmetric.AES.o Crypto.Symmetric.DES.o Crypto.DSA.o Crypto.ECC.o Crypto.HEX.o Crypto.Huge.o Crypto.ECC_int.o Crypto.PRF.o Crypto.SHA.o Crypto.MD5.o Crypto.HMAC.o Crypto.Digest.o Byte.o $(Concepts)

Net.HTTP.o: Net.HTTP.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Net.HTTPS.o: Net.HTTPS.cpp Net.TLS.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Net := Net.HTTPS.o $(TLS)

# Net.o: Net.cpp Net.HTTPS.o Net.HTTP.o Net.TLS.o Crypto.X509.o Crypto.ASN1.o Crypto.Public.DH.o Crypto.Public.RSA.o Crypto.Symmetric.RC4.o Crypto.Symmetric.AES.o Crypto.Symmetric.DES.o Crypto.Base64.o Crypto.Huge.o Crypto.ECC_int.o Crypto.PRF.o Crypto.SHA.o Crypto.MD5.o Crypto.HMAC.o Crypto.HEX.o Crypto.Digest.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

# Net := Net.o Net.HTTPS.o Net.HTTP.o Net.TLS.o Crypto.X509.o Crypto.ASN1.o Crypto.Public.DH.o Crypto.Public.RSA.o Crypto.Symmetric.RC4.o Crypto.Symmetric.AES.o Crypto.Symmetric.DES.o Crypto.Base64.o Crypto.Huge.o Crypto.ECC_int.o Crypto.PRF.o Crypto.SHA.o Crypto.MD5.o Crypto.HMAC.o Crypto.HEX.o Crypto.Digest.o

Server.o: Server.cpp Net.o#server_cert.pem server_keypair.pem
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) #-D SERVER_CERT="\"$(CURDIR)/server_cert.pem\"" -D SERVER_KEYPAIR="\"$(CURDIR)/server_keypair.pem\""

Client.o: Client.cpp Net.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

MyBox.o: MyBox.cpp Client.o Server.o Net.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

MyBox := MyBox.o Client.o Server.o Net.o Net.HTTPS.o Net.HTTP.o Net.TLS.o Crypto.X509.o Crypto.ASN1.o Crypto.Public.DH.o Crypto.Public.RSA.o Crypto.Symmetric.RC4.o Crypto.Symmetric.AES.o Crypto.Symmetric.DES.o Crypto.Base64.o Crypto.Huge.o Crypto.ECC_int.o Crypto.PRF.o Crypto.SHA.o Crypto.MD5.o Crypto.HMAC.o Crypto.HEX.o Crypto.Digest.o

# Delta := Delta.o Xashi.o Vulkan.o Mector.o Overload.o

# Array.o: Array.cpp 
# 	$(GCC) $(CXX_FLAGS) -c $<

Same.o: interfaces/Same.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Convertible.o: interfaces/Convertible.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Byte.o: interfaces/Byte.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Char.o: interfaces/Char.cpp Convertible.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Float.o: interfaces/Float.cpp Convertible.o Byte.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Integer.o: interfaces/Integer.cpp Convertible.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Number.o: interfaces/Number.cpp Integer.o Float.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

# SSL.o: interfaces/SSL.cpp Number.o Char.o Byte.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

# TLS.o: interfaces/TLS.cpp Number.o Char.o Byte.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

HTTP.o: interfaces/HTTP.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

File.o: interfaces/File.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

HEX.o: interfaces/HEX.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

ASN1.o: interfaces/ASN1.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

RC4.o: interfaces/RC4.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

DES.o: interfaces/DES.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

AES_imp.o: implementations/AES.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

AES.o: interfaces/AES.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Huge.o: interfaces/Huge.cpp ASN1.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

RSA_imp.o: implementations/RSA.cpp Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

RSA.o: interfaces/RSA.cpp Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

DH.o: interfaces/DH.cpp Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

DSA.o: interfaces/DSA.cpp Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

X509.o: interfaces/X509.cpp DSA.o RSA.o ASN1.o Huge.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Digest.o: interfaces/Digest.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

HMAC.o: interfaces/HMAC.cpp Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

MD5.o: interfaces/MD5.cpp Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

SHA.o: interfaces/SHA.cpp Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

Privkey.o: interfaces/Privkey.cpp RSA.o DES.o MD5.o ASN1.o Digest.o Huge.o ASN1.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

PRF.o: interfaces/PRF.cpp SHA.o MD5.o HMAC.o Digest.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

TLS_imp.o: implementations/TLS.cpp PRF.o Privkey.o SHA.o MD5.o Digest.o X509.o DSA.o DH.o RSA.o AES.o DES.o RC4.o ASN1.o File.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

TLS.o: interfaces/TLS.cpp TLS_imp.o PRF.o Privkey.o SHA.o MD5.o Digest.o X509.o DSA.o DH.o RSA.o AES.o DES.o RC4.o ASN1.o File.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Networking.o: interfaces/Networking.cpp TLS.o TLS_imp.o PRF.o Privkey.o SHA.o MD5.o HMAC.o Digest.o X509.o DSA.o DH.o RSA.o RSA_imp.o Huge.o AES.o AES_imp.o DES.o RC4.o ASN1.o File.o HTTP.o 
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

WebBrowser_MODULES := Networking.o TLS.o TLS_imp.o PRF.o Privkey.o SHA.o MD5.o HMAC.o Digest.o X509.o DSA.o DH.o RSA.o RSA_imp.o Huge.o AES.o AES_imp.o DES.o RC4.o ASN1.o File.o HTTP.o Number.o Integer.o Float.o Char.o Byte.o Convertible.o Same.o

WebBrowser.o: WebBrowser.cpp $(WebBrowser_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES)

WebBrowser := WebBrowser.o $(WebBrowser_MODULES)

$(TESTS_DST_DIR)/Test.WebBrowser: $(TESTS_SRC_DIR)/Test.WebBrowser.cpp $(WebBrowser)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

$(TESTS_DST_DIR)/Test.Huge: $(TESTS_SRC_DIR)/Test.Huge.cpp Huge.o ASN1.o
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

# $(TESTS_DST_DIR)/Test.RSA: $(TESTS_SRC_DIR)/Test.RSA.cpp RSA_imp.o RSA.o Huge.o ASN1.o HEX.o
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)



$(INT_DST)/Maximus.o: interfaces/Maximus.cpp #Maximus_imp.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Maximus.o: implementations/Maximus.cpp $(INT_DST)/Maximus.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

 

Maximus_MODULES := $(IMPL_DST)/Maximus.o

$(TESTS_DST_DIR)/Maximus: tests/Maximus.cpp $(Maximus_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES) -o $@

# Test_Huge: $(TESTS_SRC_DIR)/Test.Huge.cpp Huge.o ASN1.o
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

# Test_RSA: $(TESTS_SRC_DIR)/Test.RSA.cpp RSA.o RSA_imp.o Huge.o ASN1.o HEX.o
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

main: main.cpp $(Net)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Net) $(CXX_LIBS) $(CXX_INCLUDES) -D SERVER_CERT="\"$(CURDIR)/server_cert.pem\"" -D SERVER_KEYPAIR="\"$(CURDIR)/server_keypair.pem\""

Test.Concepts.Char: Test.Concepts.Char.cpp $(Concepts)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Test.Crypto.Base64: Test.Crypto.Base64.cpp Crypto.Base64.o $(Concepts)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Test.Crypto.Symmetric.DES: Test.Crypto.Symmetric.DES.cpp Crypto.Symmetric.DES.o Byte.o Crypto.HEX.o $(Concepts)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)



# Test.Compute.Shader.spv: Test.Compute.Shader.comp
# 	$(GLSLC_COMPILER) $< -o $@

# Test.Compute: Test.Compute.cpp Delta.o Test.Compute.Shader.spv
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Delta) $(CXX_LIBS) $(CXX_INCLUDES)

# Test.Graphics: Test.Graphics.cpp Delta.o
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Delta) $(CXX_LIBS) $(CXX_INCLUDES)


%.vert.spv: %.vert 
	$(GLSLC_COMPILER) $< -o $@

%.frag.spv: %.frag 
	$(GLSLC_COMPILER) $< -o $@

clean:
	@rm -f Vulkan.Pipeline.Cache
	@rm -f libDelta.a
	@rm -rf gcm.cache
	@rm -f *.o
	@rm -f *.pcm 
	@rm -f *.spv
	@rm -f *.pem
	@rm -f $(apps)
	@rm -f $(tests)
	rm -rf $(BUILD_DIR)
	@rm -f Test_Huge
	@rm -f Test_RSA
# $(info $$var is [${var}])