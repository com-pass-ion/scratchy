# Thin CMake wrapper: `make' drives the CMake backbone and exports
# build/compile_commands.json for clangd.
BUILD_DIR ?= build
BUILD_TYPE ?= Debug
EXEC ?= debug_demo

.PHONY: all build run clean

all: build

build:
	cmake -S . -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake --build $(BUILD_DIR)

run: build
	./$(BUILD_DIR)/$(EXEC)

clean:
	rm -rf $(BUILD_DIR)
