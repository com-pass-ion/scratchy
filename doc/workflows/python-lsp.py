"""
Workflow Test: LSP + Completion (Python)

INSTRUCTIONS:
1. Open this file in Emacs (should auto-start eglot)
2. Wait for LSP to initialize (check mode line for [eglot])
3. Test autocompletion:
   - Type "import os" then press Enter
   - Type "os." and wait for completion popup
   - Use M-TAB to cycle through options
4. Test diagnostics:
   - Add invalid code: "x = undefined_variable"
   - See error underline appear
   - M-n / M-p to navigate errors
5. Test navigation:
   - M-. on a function to jump to definition
   - M-, to go back
   - M-? to find references
6. Test snippets:
   - Type "def" then M-+ to expand
   - Select "def" snippet for function template
"""

# Test 1: Basic Python (verify LSP starts)
def hello_world():
    """Test function for LSP."""
    print("Hello, World!")

# Test 2: Autocompletion (verify Corfu appears)
import os
# Type "os." below and wait for completion
# os.

# Test 3: Diagnostics (verify flymake shows errors)
# Uncomment the line below to see error:
# x = undefined_variable

# Test 4: Snippets (verify Tempel works)
# Type "def" then M-+ to expand
# def

# Test 5: Navigation (verify xref works)
def calculate_sum(a, b):
    """Calculate sum of two numbers."""
    return a + b

def calculate_product(a, b):
    """Calculate product of two numbers."""
    return a * b

# Test using functions (M-. on calculate_sum to jump)
result_sum = calculate_sum(5, 3)
result_product = calculate_product(5, 3)

# Test 6: Run buffer (C-c C-c to send to shell)
if __name__ == "__main__":
    hello_world()
    print(f"Sum: {result_sum}")
    print(f"Product: {result_product}")

# VERIFICATION:
# - [ ] Eglot starts (check mode line)
# - [ ] Completion appears (Corfu popup)
# - [ ] Errors show (flymake underline)
# - [ ] Jump to definition works (M-.)
# - [ ] Snippets expand (M-+)
# - [ ] Buffer runs (C-c C-c)
