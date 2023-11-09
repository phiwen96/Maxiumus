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
TESTS_DST := $(BUILD_DIR)/tests
TESTS_SRC := $(PROJ_DIR)/tests
INT_DST := $(OBJ_DIR)/interfaces
IMPL_DST := $(OBJ_DIR)/implementations
INT_SRC := interfaces
IMPL_SRC := implementations

_BUILD_DIRS := obj docs tests obj/interfaces obj/implementations
BUILD_DIRS := $(foreach dir, $(_BUILD_DIRS), $(addprefix $(BUILD_DIR)/, $(dir)))

directories := $(foreach dir, $(BUILD_DIRS), $(shell [ -d $(dir) ] || mkdir -p $(dir)))


# apps:= main
tests:= $(TESTS_DST)/Test.WebBrowser#Test.Concepts.Char Test.Crypto.Base64#Test.Crypto.Symmetric.DES # Test.Async Test.App
# all: $(tests) $(apps)
all: $(TESTS_DST)/Maximus

$(INT_DST)/Bytes.o: $(INT_SRC)/Bytes.cpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Bytes.o: $(IMPL_SRC)/Bytes.cpp $(INT_DST)/Bytes.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@


$(INT_DST)/Maximus.o: $(INT_SRC)/Maximus.cpp $(IMPL_DST)/Bytes.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Maximus.o: $(IMPL_SRC)/Maximus.cpp $(INT_DST)/Maximus.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@


Maximus_MODULES := $(IMPL_DST)/Maximus.o $(IMPL_DST)/Bytes.o


$(TESTS_DST)/Bytes: $(TESTS_SRC)/Bytes.cpp $(IMPL_DST)/Bytes.o
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

$(TESTS_DST)/Maximus: $(TESTS_SRC)/Maximus.cpp $(Maximus_MODULES) $(TESTS_DST)/Bytes
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