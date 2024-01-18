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
	LIB_NLOHMANN := /opt/homebrew/Cellar/nlohmann-json/3.11.3
	LIB_OPENSSL := /opt/homebrew/Cellar/openssl@3/3.2.0_1
	LIB_BOOST := /opt/homebrew/Cellar/boost/1.83.0
	LIB_GLFW := /opt/homebrew/Cellar/glfw/3.3.9
	GLSLC_COMPILER = $(VULKAN_SDK)/macOS/bin/glslc
	GCC = /opt/homebrew/Cellar/gcc/13.2.0/bin/g++-13
	CXX_FLAGS += -D MACOS -D FONTS_DIR=\"/System/Library/Fonts/Supplemental\"
	CXX_LIBS = -L$(LIB_BOOST)/lib -lboost_system -lboost_url -L$(LIB_OPENSSL)/lib -lssl -lcrypto -L/opt/homebrew/lib -L$(LIB_GLFW)/lib -lglfw -L$(VULKAN_SDK)/macOS/lib -lvulkan.1.3.236 -lSDL2 -L/opt/homebrew/Cellar/freetype/2.13.2/lib -lfreetype
	CXX_INCLUDES += -I$(LIB_GLFW)/include -I$(LIB_BOOST)/include -I$(LIB_OPENSSL)/include -I$(LIB_NLOHMANN)/include -I$(VULKAN_SDK)/macOS/include
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
TESTS_DST := $(BUILD_DIR)/tests
TESTS_SRC := $(PROJ_DIR)/tests
APPS_DST := $(BUILD_DIR)/apps
APPS_SRC := $(PROJ_DIR)/apps
INT_DST := $(OBJ_DIR)/interfaces
IMPL_DST := $(OBJ_DIR)/implementations
INT_SRC := interfaces
IMPL_SRC := implementations

_BUILD_DIRS := obj docs tests apps obj/interfaces obj/implementations
BUILD_DIRS := $(foreach dir, $(_BUILD_DIRS), $(addprefix $(BUILD_DIR)/, $(dir)))

directories := $(foreach dir, $(BUILD_DIRS), $(shell [ -d $(dir) ] || mkdir -p $(dir)))


# apps:= main
tests:= $(TESTS_DST)/Test.WebBrowser#Test.Concepts.Char Test.Crypto.Base64#Test.Crypto.Symmetric.DES # Test.Async Test.App
# all: $(tests) $(apps)
all: $(TESTS_DST)/Concurrency #$(TESTS_DST)/Maximus $(APPS_DST)/Learn $(APPS_DST)/UseAPI $(APPS_DST)/Tasks

###################################################################################################
############### Modules ###########################################################################

############### Same ##############################################################################

Same_MODULES := 

$(INT_DST)/Same.o: $(INT_SRC)/Same.cpp $(Same_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Same.o: $(IMPL_SRC)/Same.cpp $(INT_DST)/Same.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Same_MODULES := $(IMPL_DST)/Same.o $(INT_DST)/Same.o $(Same_MODULES)

$(TESTS_DST)/Same: $(TESTS_SRC)/Same.cpp $(Same_MODULES) #$(IMPL_DST)/Same.o
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Same.o $(INT_DST)/Same.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Same $(Maximus_TESTS)

############### Bytes ##############################################################################

Bytes_MODULES :=

$(INT_DST)/Bytes.o: $(INT_SRC)/Bytes.cpp $(Bytes_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Bytes.o: $(IMPL_SRC)/Bytes.cpp $(INT_DST)/Bytes.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Bytes_MODULES := $(IMPL_DST)/Bytes.o $(INT_DST)/Bytes.o $(Bytes_MODULES)

$(TESTS_DST)/Bytes: $(TESTS_SRC)/Bytes.cpp $(Bytes_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Bytes.o $(INT_DST)/Bytes.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Bytes $(Maximus_TESTS)

############### Bool ##############################################################################

Bool_MODULES :=

$(INT_DST)/Bool.o: $(INT_SRC)/Bool.cpp $(Bool_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Bool.o: $(IMPL_SRC)/Bool.cpp $(INT_DST)/Bool.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Bool_MODULES := $(IMPL_DST)/Bool.o $(INT_DST)/Bool.o $(Bool_MODULES)

$(TESTS_DST)/Bool: $(TESTS_SRC)/Bool.cpp $(Bool_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Bool.o $(INT_DST)/Bool.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Bool $(Maximus_TESTS)

############### EqualityComparable ##############################################################################

EqualityComparable_MODULES := $(IMPL_DST)/Bool.o

$(INT_DST)/EqualityComparable.o: $(INT_SRC)/EqualityComparable.cpp $(EqualityComparable_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/EqualityComparable.o: $(IMPL_SRC)/EqualityComparable.cpp $(INT_DST)/EqualityComparable.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

EqualityComparable_MODULES := $(IMPL_DST)/EqualityComparable.o $(INT_DST)/EqualityComparable.o $(EqualityComparable_MODULES)

$(TESTS_DST)/EqualityComparable: $(TESTS_SRC)/EqualityComparable.cpp $(EqualityComparable_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/EqualityComparable.o $(INT_DST)/EqualityComparable.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/EqualityComparable $(Maximus_TESTS)

############### Number ##############################################################################

Number_MODULES :=

$(INT_DST)/Number.o: $(INT_SRC)/Number.cpp $(Number_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Number.o: $(IMPL_SRC)/Number.cpp $(INT_DST)/Number.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Number_MODULES := $(IMPL_DST)/Number.o $(INT_DST)/Number.o $(Number_MODULES)

$(TESTS_DST)/Number: $(TESTS_SRC)/Number.cpp $(Number_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Number.o $(INT_DST)/Number.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Number $(Maximus_TESTS)

############### Sequence ##############################################################################

Sequence_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/Sequence.o: $(INT_SRC)/Sequence.cpp $(Sequence_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Sequence.o: $(IMPL_SRC)/Sequence.cpp $(INT_DST)/Sequence.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Sequence_MODULES := $(IMPL_DST)/Sequence.o $(INT_DST)/Sequence.o $(Sequence_MODULES)

$(TESTS_DST)/Sequence: $(TESTS_SRC)/Sequence.cpp $(Sequence_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Sequence.o $(INT_DST)/Sequence.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Sequence $(Maximus_TESTS)

############### Console ##############################################################################

Console_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/Console.o: $(INT_SRC)/Console.cpp $(Console_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Console.o: $(IMPL_SRC)/Console.cpp $(INT_DST)/Console.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Console_MODULES := $(IMPL_DST)/Console.o $(INT_DST)/Console.o $(Console_MODULES)

$(TESTS_DST)/Console: $(TESTS_SRC)/Console.cpp $(Console_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Console.o $(INT_DST)/Console.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Console $(Maximus_TESTS)

############### Console ##############################################################################

Concurrency_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/Concurrency.o: $(INT_SRC)/Concurrency.cpp $(Concurrency_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Concurrency.o: $(IMPL_SRC)/Concurrency.cpp $(INT_DST)/Concurrency.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Concurrency_MODULES := $(IMPL_DST)/Concurrency.o $(INT_DST)/Concurrency.o $(Concurrency_MODULES)

$(TESTS_DST)/Concurrency: $(TESTS_SRC)/Concurrency.cpp $(Concurrency_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Concurrency.o $(INT_DST)/Concurrency.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Concurrency $(Maximus_TESTS)

############### Net ##############################################################################

Net_MODULES :=

$(INT_DST)/Net.o: $(INT_SRC)/Net.cpp $(Net_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Net.o: $(IMPL_SRC)/Net.cpp $(INT_DST)/Net.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Net_MODULES := $(IMPL_DST)/Net.o $(INT_DST)/Net.o $(Net_MODULES)

$(TESTS_DST)/Net: $(TESTS_SRC)/Net.cpp $(Net_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Net.o $(INT_DST)/Net.o $(Maximus_MODULES)

# Maximus_TESTS := $(TESTS_DST)/Net $(Maximus_TESTS)

############### Maximus ##############################################################################

$(INT_DST)/Maximus.o: $(INT_SRC)/Maximus.cpp $(Maximus_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Maximus.o: $(IMPL_SRC)/Maximus.cpp $(INT_DST)/Maximus.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Maximus_MODULES := $(IMPL_DST)/Maximus.o $(INT_DST)/Maximus.o $(Maximus_MODULES)

$(TESTS_DST)/Maximus: $(TESTS_SRC)/Maximus.cpp $(Maximus_MODULES) $(Maximus_TESTS) #$(TESTS_DST)/Console $(TESTS_DST)/Bytes $(TESTS_DST)/TLS $(TESTS_DST)/Socket $(TESTS_DST)/Bool
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Maximus_MODULES) $(CXX_LIBS) $(CXX_INCLUDES)

############### APPs ##############################################################################

$(APPS_DST)/Learn: $(APPS_SRC)/Learn.cpp $(Maximus_MODULES) $(Maximus_TESTS) #$(TESTS_DST)/Console $(TESTS_DST)/Bytes $(TESTS_DST)/TLS $(TESTS_DST)/Socket $(TESTS_DST)/Bool
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Maximus_MODULES) $(CXX_LIBS) $(CXX_INCLUDES)

$(APPS_DST)/UseAPI: $(APPS_SRC)/UseAPI.cpp $(Maximus_MODULES) $(Maximus_TESTS) #$(TESTS_DST)/Console $(TESTS_DST)/Bytes $(TESTS_DST)/TLS $(TESTS_DST)/Socket $(TESTS_DST)/Bool
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Maximus_MODULES) $(CXX_LIBS) $(CXX_INCLUDES)

$(APPS_DST)/Tasks: $(APPS_SRC)/Tasks.cpp $(Maximus_MODULES) $(Maximus_TESTS) #$(TESTS_DST)/Console $(TESTS_DST)/Bytes $(TESTS_DST)/TLS $(TESTS_DST)/Socket $(TESTS_DST)/Bool
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Maximus_MODULES) $(CXX_LIBS) $(CXX_INCLUDES)


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
	@rm -rf $(BUILD_DIR)

# $(info $$var is [${var}])

# $(info $$Maximus_MODULES is [${Maximus_MODULES}])


# Socket_DEPENDENT_MODULES := $(IMPL_DST)/Same.o

# $(INT_DST)/Socket.o: $(INT_SRC)/Socket.cpp $(IMPL_DST)/Same.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# $(IMPL_DST)/Socket.o: $(IMPL_SRC)/Socket.cpp $(INT_DST)/Socket.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# Socket_MODULES := $(IMPL_DST)/Socket.o $(INT_DST)/Socket.o $(Socket_DEPENDENT_MODULES)

# $(TESTS_DST)/Socket: $(TESTS_SRC)/Socket.cpp $(Socket_MODULES)
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $< $(Socket_MODULES) $(CXX_LIBS) $(CXX_INCLUDES)




# TLS_DEPENDENT_MODULES := $(IMPL_DST)/Socket.o $(IMPL_DST)/Bytes.o $(IMPL_DST)/Same.o

# $(INT_DST)/TLS.o: $(INT_SRC)/TLS.cpp $(TLS_DEPENDENT_MODULES)
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# $(IMPL_DST)/TLS.o: $(IMPL_SRC)/TLS.cpp $(INT_DST)/TLS.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# TLS_MODULES := $(IMPL_DST)/TLS.o $(INT_DST)/TLS.o $(TLS_DEPENDENT_MODULES)