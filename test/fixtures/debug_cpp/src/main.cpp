// Hermetic GDB fixture (no network deps, iostream only).
// Mirrors ~/debug_cpp line layout so test_gdb_workflow.sh recipes work:
//   line 100 -> unique_ptr<Resource> res (id 42)
//   demonstrate_variant -> variant with "variant demo"
//   line 139 -> std::optional<int*> safe_null
#include <iostream>
#include <memory>
#include <optional>
#include <string>
#include <variant>
#include <vector>

struct Resource {
    explicit Resource(int id) : id_(id) { std::cout << "Resource " << id_ << " acquired\n"; }
    ~Resource() { std::cout << "Resource " << id_ << " destroyed\n"; }
    int id_;
};

void demonstrate_format() {
    std::cout << "format demo\n";
}

void demonstrate_optional() {
    std::optional<int> o = 7;
    if (o) {
        std::cout << "optional holds: " << *o << "\n";
    }
}

void demonstrate_variant(std::variant<std::string, int, double> v) {
    if (std::holds_alternative<std::string>(v)) {
        std::cout << "variant holds: " << std::get<std::string>(v) << "\n";
    } else {
        std::cout << "variant holds non-string\n";
    }
}

// Padding to align unique_ptr creation on line 100.
// Each comment below occupies exactly one line.
// pad-01
// pad-02
// pad-03
// pad-04
// pad-05
// pad-06
// pad-07
// pad-08
// pad-09
// pad-10
// pad-11
// pad-12
// pad-13
// pad-14
// pad-15
// pad-16
// pad-17
// pad-18
// pad-19
// pad-20
// pad-21
// pad-22
// pad-23
// pad-24
// pad-25
// pad-26
// pad-27
// pad-28
// pad-29
// pad-30
// pad-31
// pad-32
// pad-33
// pad-34
// pad-35
// pad-36
// pad-37
// pad-38
// pad-39
// pad-40
// pad-41
// pad-42
// pad-43
// pad-44
// pad-45
// pad-46
// pad-47
// pad-48
// pad-49
// pad-50
// pad-51
// pad-52
// pad-53
// pad-54
// pad-55
// pad-56
// pad-57
// Function demonstrating unique_ptr and shared_ptr debugging
void demonstrate_smart_ptr() {
    // Create unique_ptr owning a Resource with id=42 (heap allocation)
    std::unique_ptr<Resource> res = std::make_unique<Resource>(42);
    // Print resource id through unique_ptr
    std::cout << "unique_ptr owns resource with id: " << res->id_ << "\n";

    // shared_ptr demonstration
    // Create shared_ptr owning a Resource with id=99
    std::shared_ptr<Resource> res2 = std::make_shared<Resource>(99);
    // Print the current reference count (should be 1 after creation)
    std::cout << "shared_ptr use_count: " << res2.use_count() << "\n";
}

// Main entry point of the program
int main() {
    // Print program header with decorative formatting
    std::cout << "=== Modern C++ Debugging Demo ===\n\n";

    // Call format demonstration function
    demonstrate_format();
    // Call optional demonstration function
    demonstrate_optional();

    // Create variant initialized with a string
    std::variant<std::string, int, double> v = std::string("variant demo");
    // Call variant demonstration function
    demonstrate_variant(v);

    // Call smart pointer demonstration function
    demonstrate_smart_ptr();

    // Initialize vector with 3 elements: {10, 20, 30}
    std::vector<int> off_by_one = {10, 20, 30};
    // Print first element (index 0): "First element: 10"
    std::cout << "First element: " << off_by_one[0] << "\n";
    // Print second element (index 1): "Second element: 20"
    std::cout << "Second element: " << off_by_one[1] << "\n";
    // Print third element (index 2): "Third element: 30"
    std::cout << "Third element: " << off_by_one[2] << "\n";

    // Create optional<int*> initialized to null (no pointer value)
    std::optional<int*> safe_null = std::nullopt;
    // Check if optional holds a value (this will be false)
    if (safe_null) {
        // This branch won't execute - demonstrates safe null for gdb
        std::cout << "Pointer address: " << static_cast<void*>(*safe_null) << "\n";
    } else {
        // If optional does not hold a value (expected case)
        std::cout << "safe_null is empty (expected)\n";
    }

    // Keep console open for debugging inspection
    std::cout << "Demo complete\n";
    return 0;
}
