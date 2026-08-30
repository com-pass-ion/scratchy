"""
Workflow Test: Snippets (Tempel)

INSTRUCTIONS:
1. Open this file in Emacs
2. Test snippet expansion:
   - Type a snippet name (see list below)
   - Press M-+ (tempel-complete) or M-* (tempel-insert)
   - Select snippet from popup
   - Fill in fields with TAB
3. Test snippet navigation:
   - After expansion, use M-{ / M-} to jump between fields
   - Press q to finish snippet
4. Test snippet in different contexts:
   - Try snippets at top level (class, def)
   - Try snippets inside functions (if, for, while)
   - Try snippets in strings (f-string)

AVAILABLE SNIPPETS (Python):
- def      : Function definition
- defm     : Method definition (with self)
- cls      : Class definition
- init     : __init__ method
- main     : if __name__ == '__main__' block
- if       : if statement
- ife      : if/else statement
- elif     : elif statement
- for      : for loop
- while    : while loop
- try      : try/except block
- trye     : try/except with as
- print    : print() function
- return   : return statement
- fstr     : f-string
- spr      : format() string

GENERIC SNIPPETS (any mode):
- today    : Current date (YYYY-MM-DD)
- now      : Current time (HH:MM:SS)
- timestamp: ISO timestamp
- fixme    : FIXME comment
- todo     : TODO comment
- bug      : BUG comment
- hack     : HACK comment
"""

# Test 1: Function (type "def" then M-+)
# def

# Test 2: Class (type "cls" then M-+)
# cls

# Test 3: Method (type "defm" then M-+)
# defm

# Test 4: __init__ (type "init" then M-+)
# init

# Test 5: Main block (type "main" then M-+)
# main

# Test 6: Control flow (type "if" then M-+)
# if

# Test 7: For loop (type "for" then M-+)
# for

# Test 8: While loop (type "while" then M-+)
# while

# Test 9: Try/except (type "try" then M-+)
# try

# Test 10: Print (type "print" then M-+)
# print

# Test 11: Return (type "return" then M-+)
# return

# Test 12: F-string (type "fstr" then M-+)
# fstr

# Test 13: Date snippet (type "today" then M-+)
# today

# Test 14: TODO comment (type "todo" then M-+)
# todo

# VERIFICATION:
# - [ ] M-+ opens completion popup
# - [ ] Snippets appear in list
# - [ ] Selection inserts snippet
# - [ ] Fields are editable
# - [ ] M-{ / M-} navigates fields
# - [ ] q finishes snippet
# - [ ] Snippets work in different contexts
