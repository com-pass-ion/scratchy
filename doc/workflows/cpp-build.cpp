/**
 * Workflow Test: Build + Run (C++)
 *
 * INSTRUCTIONS:
 * 1. Open this file in Emacs (should auto-start eglot with clangd)
 * 2. Test LSP features:
 *    - Wait for [eglot] in mode line
 *    - M-. on function to jump to definition
 *    - M-? to find references
 * 3. Test build:
 *    - C-c l b to build (requires CMakeLists.txt in project)
 *    - Check *compilation* buffer for output
 * 4. Test run:
 *    - C-c l r to run the program
 *    - Output appears in *compilation* buffer
 * 5. Test error navigation:
 *    - Add intentional error (e.g., missing semicolon)
 *    - C-c l n / C-c l p to navigate errors
 * 6. Test snippets:
 *    - Type "if" then M-+ to expand
 *    - Type "for" then M-+ to expand
 *    - Type "main" then M-+ to expand
 */

#include <iostream>
#include <string>
#include <vector>

// Test 1: Basic function (verify LSP starts)
void hello_world() {
    std::cout << "Hello, World!" << std::endl;
}

// Test 2: Class definition (verify completion)
class Calculator {
public:
    int add(int a, int b) {
        return a + b;
    }

    int subtract(int a, int b) {
        return a - b;
    }

    int multiply(int a, int b) {
        return a * b;
    }
};

// Test 3: Templates (verify Tempel works)
// Type "if" then M-+ to expand
// if

// Type "for" then M-+ to expand
// for

// Test 4: STL usage (verify completion)
void test_vector() {
    std::vector<int> numbers = {1, 2, 3, 4, 5};

    // Type "numbers." and wait for completion
    // numbers.

    for (const auto& num : numbers) {
        std::cout << num << " ";
    }
    std::cout << std::endl;
}

// Test 5: Navigation (verify xref works)
int factorial(int n) {
    if (n <= 1) return 1;
    return n * factorial(n - 1);
}

// Test 6: Error handling (verify diagnostics)
void test_errors() {
    // Uncomment to see error:
    // int x = undefined_variable;

    // Missing semicolon test (uncomment):
    // int y = 5
}

// Main function (type "main" then M-+ to expand)
int main() {
    hello_world();

    Calculator calc;
    std::cout << "5 + 3 = " << calc.add(5, 3) << std::endl;
    std::cout << "5 - 3 = " << calc.subtract(5, 3) << std::endl;
    std::cout << "5 * 3 = " << calc.multiply(5, 3) << std::endl;

    test_vector();

    std::cout << "5! = " << factorial(5) << std::endl;

    return 0;
}

// VERIFICATION:
// - [ ] Eglot starts (check mode line for [eglot])
// - [ ] Completion appears (Corfu popup)
// - [ ] Build works (C-c l b)
// - [ ] Run works (C-c l r)
// - [ ] Errors navigate (C-c l n/p)
// - [ ] Jump to definition works (M-.)
// - [ ] Snippets expand (M-+)
