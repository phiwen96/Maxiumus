# make && ./build/tests/Test.WebBrowser

# sudo apt -y install liburing-dev

# GCC=g++-12 -std=gnu++2a -fcoroutines -fmodules-ts -fconcepts-diagnostics-depth=1
CXX = clang++
# --verbose
############### C++ compiler flags ###################
CXX_FLAGS = -D DEBUG -std=gnu++23 -fmodules-ts -fcompare-debug-second -O2 -fno-trapping-math -fno-math-errno -fno-signed-zeros #-fconcepts-diagnostics-depth=2
CXX_MODULES = -fmodules-ts -fmodules -fbuiltin-module-map -fimplicit-modules -fimplicit-module-maps -fprebuilt-module-path=.

CXX_APP_FLAGS = -lpthread 

USE_GLFW := FALSE
USE_VULKAN := FALSE
USE_BOOST := FALSE
USE_OPENSSL := FALSE
USE_NLOHMANN := FALSE

ifeq ($(OS),Windows_NT) 
    detected_OS := Windows
else
    detected_OS := $(shell sh -c 'uname 2>/dev/null || echo Unknown')
	# CXX_INCLUDES = -I/usr/local/include -I/opt/homebrew/Cellar/glm/0.9.9.8/include -I/opt/homebrew/Cellar/freetype/2.12.1/include/freetype2 #-I/Users/philipwenkel/VulkanSDK/1.3.216.0/macOS/include
endif
ifeq ($(detected_OS),Windows)
	GCC = g++
	CXX_FLAGS += -D WINDOWS
	VULKAN_DIR = C:\VulkanSDK\1.3.224.1
	CXX_LIBS = -L$(VULKAN_DIR)\Lib #-lvulkan
	CXX_INCLUDES += -I$(VULKAN_DIR)\Include
endif
ifeq ($(detected_OS),Darwin)
	
	ifeq ($(USE_GLFW), TRUE) 
		# $(info $$USE_GLFW is [${USE_GLFW}])
		CXX_LIBS += -L$(LIB_GLFW)/lib -lglfw 
		CXX_INCLUDES += -I$(LIB_GLFW)/include 
	endif
	ifeq ($(USE_VULKAN), TRUE)
		CXX_LIBS += -L$(VULKAN_SDK)/macOS/lib -lvulkan.1.3.236 
		CXX_INCLUDES += -I$(VULKAN_SDK)/macOS/include 
	endif
	ifeq ($(USE_BOOST), TRUE)
		CXX_LIBS += -L$(LIB_BOOST)/lib -lboost_system -lboost_url 
		CXX_INCLUDES += -I$(LIB_BOOST)/include 
	endif
	ifeq ($(USE_OPENSSL), TRUE)
		CXX_LIBS += -L$(LIB_OPENSSL)/lib -lssl -lcrypto
		CXX_INCLUDES += -I$(LIB_OPENSSL)/include
	endif
	ifeq ($(USE_NLOHMANN), TRUE)
		CXX_INCLUDES += -I$(LIB_NLOHMANN)/include
	endif
	
	VULKAN_VERSION = 1.3.236.0
	VULKAN_SDK = /Users/philipwenkel/VulkanSDK/$(VULKAN_VERSION)
	LIB_NLOHMANN := /opt/homebrew/Cellar/nlohmann-json/3.11.3
	LIB_OPENSSL := /opt/homebrew/Cellar/openssl@3/3.2.0_1
	LIB_BOOST := /opt/homebrew/Cellar/boost/1.83.0
	LIB_GLFW := /opt/homebrew/Cellar/glfw/3.3.9
	GLSLC_COMPILER = $(VULKAN_SDK)/macOS/bin/glslc
	GCC = /opt/homebrew/Cellar/gcc/13.2.0/bin/g++-13
	CXX_FLAGS += -D MACOS #-D FONTS_DIR=\"/System/Library/Fonts/Supplemental\"
	# CXX_LIBS = -L/opt/homebrew/lib
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
tests:= $(TESTS_DST)/Test.Coro $(TESTS_DST)/Test.WebBrowser#Test.Concepts.Char Test.Crypto.Base64#Test.Crypto.Symmetric.DES # Test.Async Test.App
# all: $(tests) $(apps)
all: $(TESTS_DST)/SyncWaitTask #$(TESTS_DST)/Task $(TESTS_DST)/Coro #$(TESTS_DST)/Maximus $(APPS_DST)/Learn $(APPS_DST)/UseAPI $(APPS_DST)/Tasks


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

############### Any ##############################################################################

Any_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/Any.o: $(INT_SRC)/Coro/Any.cpp $(Any_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Any.o: $(IMPL_SRC)/Coro/Any.cpp $(INT_DST)/Any.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Any_MODULES := $(IMPL_DST)/Any.o $(INT_DST)/Any.o $(Any_MODULES)

$(TESTS_DST)/Any: $(TESTS_SRC)/Coro/Any.cpp $(Any_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Any.o $(INT_DST)/Any.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Coro/Any $(Maximus_TESTS)

# ############### IsAwaiter ##############################################################################

# IsAwaiter_MODULES := $(IMPL_DST)/Same.o

# $(INT_DST)/IsAwaiter.o: $(INT_SRC)/Coro/IsAwaiter.cpp $(IsAwaiter_MODULES)
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# $(IMPL_DST)/IsAwaiter.o: $(IMPL_SRC)/Coro/IsAwaiter.cpp $(INT_DST)/IsAwaiter.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# IsAwaiter_MODULES := $(IMPL_DST)/IsAwaiter.o $(INT_DST)/IsAwaiter.o $(IsAwaiter_MODULES)

# $(TESTS_DST)/IsAwaiter: $(TESTS_SRC)/Coro/IsAwaiter.cpp $(IsAwaiter_MODULES)
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

# Maximus_MODULES := $(IMPL_DST)/IsAwaiter.o $(INT_DST)/IsAwaiter.o $(Maximus_MODULES)

# Maximus_TESTS := $(TESTS_DST)/Coro/IsAwaiter $(Maximus_TESTS)

# ############### Any ##############################################################################

# Any_MODULES := $(IMPL_DST)/Same.o

# $(INT_DST)/Any.o: $(INT_SRC)/Coro/Any.cpp $(Any_MODULES)
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# $(IMPL_DST)/Any.o: $(IMPL_SRC)/Coro/Any.cpp $(INT_DST)/Any.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# Any_MODULES := $(IMPL_DST)/Any.o $(INT_DST)/Any.o $(Any_MODULES)

# $(TESTS_DST)/Any: $(TESTS_SRC)/Coro/Any.cpp $(Any_MODULES)
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

# Maximus_MODULES := $(IMPL_DST)/Any.o $(INT_DST)/Any.o $(Maximus_MODULES)

# Maximus_TESTS := $(TESTS_DST)/Coro/Any $(Maximus_TESTS)

############### IsAwaiter ##############################################################################

IsAwaiter_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/IsAwaiter.o: $(INT_SRC)/Coro/IsAwaiter.cpp $(IsAwaiter_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/IsAwaiter.o: $(IMPL_SRC)/Coro/IsAwaiter.cpp $(INT_DST)/IsAwaiter.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

IsAwaiter_MODULES := $(IMPL_DST)/IsAwaiter.o $(INT_DST)/IsAwaiter.o $(IsAwaiter_MODULES)

$(TESTS_DST)/IsAwaiter: $(TESTS_SRC)/Coro/IsAwaiter.cpp $(IsAwaiter_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/IsAwaiter.o $(INT_DST)/IsAwaiter.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Coro/IsAwaiter $(Maximus_TESTS)

############### GetAwaiter ##############################################################################

GetAwaiter_MODULES := $(IMPL_DST)/IsAwaiter.o $(IMPL_DST)/Any.o $(IMPL_DST)/Same.o

$(INT_DST)/GetAwaiter.o: $(INT_SRC)/Coro/GetAwaiter.cpp $(GetAwaiter_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/GetAwaiter.o: $(IMPL_SRC)/Coro/GetAwaiter.cpp $(INT_DST)/GetAwaiter.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

GetAwaiter_MODULES := $(IMPL_DST)/GetAwaiter.o $(INT_DST)/GetAwaiter.o $(GetAwaiter_MODULES)

$(TESTS_DST)/GetAwaiter: $(TESTS_SRC)/Coro/GetAwaiter.cpp $(GetAwaiter_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/GetAwaiter.o $(INT_DST)/GetAwaiter.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Coro/GetAwaiter $(Maximus_TESTS)

############### AwaitableTraits ##############################################################################

AwaitableTraits_MODULES := $(IMPL_DST)/GetAwaiter.o $(IMPL_DST)/Same.o

$(INT_DST)/AwaitableTraits.o: $(INT_SRC)/Coro/AwaitableTraits.cpp $(AwaitableTraits_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/AwaitableTraits.o: $(IMPL_SRC)/Coro/AwaitableTraits.cpp $(INT_DST)/AwaitableTraits.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

AwaitableTraits_MODULES := $(IMPL_DST)/AwaitableTraits.o $(INT_DST)/AwaitableTraits.o $(AwaitableTraits_MODULES)

$(TESTS_DST)/AwaitableTraits: $(TESTS_SRC)/Coro/AwaitableTraits.cpp $(AwaitableTraits_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/AwaitableTraits.o $(INT_DST)/AwaitableTraits.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Coro/AwaitableTraits $(Maximus_TESTS)

############### BrokenPromise ##############################################################################

BrokenPromise_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/BrokenPromise.o: $(INT_SRC)/Coro/BrokenPromise.cpp $(BrokenPromise_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/BrokenPromise.o: $(IMPL_SRC)/Coro/BrokenPromise.cpp $(INT_DST)/BrokenPromise.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

BrokenPromise_MODULES := $(IMPL_DST)/BrokenPromise.o $(INT_DST)/BrokenPromise.o $(BrokenPromise_MODULES)

$(TESTS_DST)/BrokenPromise: $(TESTS_SRC)/Coro/BrokenPromise.cpp $(BrokenPromise_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/BrokenPromise.o $(INT_DST)/BrokenPromise.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Coro/BrokenPromise $(Maximus_TESTS)

############### Config ##############################################################################

# Config_MODULES := $(IMPL_DST)/Same.o

# $(INT_DST)/Config.o: $(INT_SRC)/Coro/Config.cpp $(Config_MODULES)
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# $(IMPL_DST)/Config.o: $(IMPL_SRC)/Coro/Config.cpp $(INT_DST)/Config.o
# 	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

# Config_MODULES := $(IMPL_DST)/Config.o $(INT_DST)/Config.o $(Config_MODULES)

# $(TESTS_DST)/Config: $(TESTS_SRC)/Coro/Config.cpp $(Config_MODULES)
# 	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

# Maximus_MODULES := $(IMPL_DST)/Config.o $(INT_DST)/Config.o $(Maximus_MODULES)

# Maximus_TESTS := $(TESTS_DST)/Coro/Config $(Maximus_TESTS)

############### RemoveRValueReference ##############################################################################

RemoveRValueReference_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/RemoveRValueReference.o: $(INT_SRC)/Coro/RemoveRValueReference.cpp $(RemoveRValueReference_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/RemoveRValueReference.o: $(IMPL_SRC)/Coro/RemoveRValueReference.cpp $(INT_DST)/RemoveRValueReference.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

RemoveRValueReference_MODULES := $(IMPL_DST)/RemoveRValueReference.o $(INT_DST)/RemoveRValueReference.o $(RemoveRValueReference_MODULES)

$(TESTS_DST)/RemoveRValueReference: $(TESTS_SRC)/Coro/RemoveRValueReference.cpp $(RemoveRValueReference_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/RemoveRValueReference.o $(INT_DST)/RemoveRValueReference.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Coro/RemoveRValueReference $(Maximus_TESTS)

############### LightweightManualResetEvent ##############################################################################

LightweightManualResetEvent_MODULES := $(IMPL_DST)/Same.o

$(INT_DST)/LightweightManualResetEvent.o: $(INT_SRC)/Coro/LightweightManualResetEvent.cpp $(LightweightManualResetEvent_MODULES) $(INT_SRC)/Coro/Config.hpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/LightweightManualResetEvent.o: $(IMPL_SRC)/Coro/LightweightManualResetEvent.cpp $(INT_DST)/LightweightManualResetEvent.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

LightweightManualResetEvent_MODULES := $(IMPL_DST)/LightweightManualResetEvent.o $(INT_DST)/LightweightManualResetEvent.o $(LightweightManualResetEvent_MODULES)

$(TESTS_DST)/LightweightManualResetEvent: $(TESTS_SRC)/Coro/LightweightManualResetEvent.cpp $(LightweightManualResetEvent_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/LightweightManualResetEvent.o $(INT_DST)/LightweightManualResetEvent.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/LightweightManualResetEvent $(Maximus_TESTS)

############### SyncWaitTask ##############################################################################

SyncWaitTask_MODULES := $(IMPL_DST)/LightweightManualResetEvent.o $(IMPL_DST)/AwaitableTraits.o $(IMPL_DST)/Same.o

$(INT_DST)/SyncWaitTask.o: $(INT_SRC)/Coro/SyncWaitTask.cpp $(SyncWaitTask_MODULES) $(INT_SRC)/Coro/Config.hpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/SyncWaitTask.o: $(IMPL_SRC)/Coro/SyncWaitTask.cpp $(INT_DST)/SyncWaitTask.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

SyncWaitTask_MODULES := $(IMPL_DST)/SyncWaitTask.o $(INT_DST)/SyncWaitTask.o $(SyncWaitTask_MODULES)

$(TESTS_DST)/SyncWaitTask: $(TESTS_SRC)/Coro/SyncWaitTask.cpp $(SyncWaitTask_MODULES) $(INT_SRC)/Coro/Config.hpp
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/SyncWaitTask.o $(INT_DST)/SyncWaitTask.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/SyncWaitTask $(Maximus_TESTS)

############### SyncWait ##############################################################################

SyncWait_MODULES := $(IMPL_DST)/SyncWaitTask.o $(IMPL_DST)/AwaitableTraits.o $(IMPL_DST)/LightweightManualResetEvent.o $(IMPL_DST)/Same.o

$(INT_DST)/SyncWait.o: $(INT_SRC)/Coro/SyncWait.cpp $(SyncWait_MODULES) $(INT_SRC)/Coro/Config.hpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/SyncWait.o: $(IMPL_SRC)/Coro/SyncWait.cpp $(INT_DST)/SyncWait.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

SyncWait_MODULES := $(IMPL_DST)/SyncWait.o $(INT_DST)/SyncWait.o $(SyncWait_MODULES)

$(TESTS_DST)/SyncWait: $(TESTS_SRC)/Coro/SyncWait.cpp $(SyncWait_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/SyncWait.o $(INT_DST)/SyncWait.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/SyncWait $(Maximus_TESTS)

############### Coro ##############################################################################

Coro_MODULES := $(IMPL_DST)/Task.o $(IMPL_DST)/Same.o

$(INT_DST)/Coro.o: $(INT_SRC)/Coro.cpp $(Coro_MODULES)
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Coro.o: $(IMPL_SRC)/Coro.cpp $(INT_DST)/Coro.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Coro_MODULES := $(IMPL_DST)/Coro.o $(INT_DST)/Coro.o $(Coro_MODULES)

$(TESTS_DST)/Coro: $(TESTS_SRC)/Coro.cpp $(Coro_MODULES)
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Coro.o $(INT_DST)/Coro.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Coro $(Maximus_TESTS)

############### Task ##############################################################################

Task_MODULES := $(IMPL_DST)/RemoveRValueReference.o $(IMPL_DST)/BrokenPromise.o $(IMPL_DST)/AwaitableTraits.o $(IMPL_DST)/Same.o

$(INT_DST)/Task.o: $(INT_SRC)/Task.cpp $(Task_MODULES) $(INT_SRC)/Coro/Config.hpp
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

$(IMPL_DST)/Task.o: $(IMPL_SRC)/Task.cpp $(INT_DST)/Task.o
	$(GCC) $(CXX_FLAGS) -c $< $(CXX_INCLUDES) -o $@

Task_MODULES := $(IMPL_DST)/Task.o $(INT_DST)/Task.o $(Task_MODULES)

$(TESTS_DST)/Task: $(TESTS_SRC)/Task.cpp $(Task_MODULES) $(IMPL_DST)/SyncWait.o
	$(GCC) $(CXX_FLAGS) -Werror=unused-result -o $@ $^ $(CXX_LIBS) $(CXX_INCLUDES)

Maximus_MODULES := $(IMPL_DST)/Task.o $(INT_DST)/Task.o $(Maximus_MODULES)

Maximus_TESTS := $(TESTS_DST)/Task $(Maximus_TESTS)

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