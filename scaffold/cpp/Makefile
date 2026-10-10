# Scratchy basic C++ build system.
# Provided by scaffold/adopt-cpp-project.sh when a project has no build system.
# `make` builds the executable and writes build/compile_commands.json (clangd).

CXX       ?= g++
CXXFLAGS  ?= -std=c++17 -O2 -Wall -Wextra -g
BUILD_DIR ?= build
EXEC      ?= $(notdir $(CURDIR))

SRCS := $(wildcard *.cpp) $(wildcard src/*.cpp)
OBJS := $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(SRCS))

.PHONY: all build run clean compdb

all: build

build: $(BUILD_DIR)/compile_commands.json $(BUILD_DIR)/$(EXEC)

$(BUILD_DIR)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -MMD -MP -c $< -o $@

$(BUILD_DIR)/$(EXEC): $(OBJS)
	$(CXX) $(CXXFLAGS) $^ -o $@

# Compile database for clangd: emitted from the same sources and flags used to
# build, so the build system owns indexing (no bear, no CMake).
compdb: $(BUILD_DIR)/compile_commands.json

$(BUILD_DIR)/compile_commands.json: $(SRCS)
	@mkdir -p $(BUILD_DIR)
	@printf '[\n' > $@
	@first=1; \
	for f in $(SRCS); do \
	  [ $$first -eq 1 ] || printf ',\n' >> $@; \
	  first=0; \
	  printf '  {"directory": "%s", "file": "%s", "command": "%s %s -c %s"}' \
	    "$(CURDIR)" "$$f" "$(CXX)" "$(CXXFLAGS)" "$$f" >> $@; \
	done
	@printf '\n]\n' >> $@

run: build
	./$(BUILD_DIR)/$(EXEC)

clean:
	rm -rf $(BUILD_DIR)


