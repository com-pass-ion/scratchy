;;; elisp-test.el --- Workflow Test: Eval + Debug (Emacs Lisp)  -*- lexical-binding: t; -*-

;;; Commentary:

;; INSTRUCTIONS:
;; 1. Open this file in Emacs
;; 2. Test evaluation:
;;    - C-x C-e after any S-expression to eval
;;    - C-c C-c to eval entire buffer
;;    - M-x eval-buffer to eval entire buffer
;; 3. Test debugging:
;;    - M-x toggle-debug-on-error to enable
;;    - Cause an error to see backtrace
;;    - M-x toggle-debug-on-error to disable
;; 4. Test ERT testing:
;;    - C-c C-e to eval buffer (runs tests)
;;    - M-x ert to run all tests
;; 5. Test snippets:
;;    - Type "defun" then M-+ to expand
;;    - Type "defvar" then M-+ to expand
;;    - Type "when" then M-+ to expand
;; 6. Test helpful:
;;    - C-h f on any function
;;    - C-h v on any variable
;;    - C-h k on any keybinding

;;; Code:

;; Test 1: Basic evaluation (verify C-x C-e works)
(+ 2 3)  ; C-x C-e should show 5 in echo area

;; Test 2: String operations
(string-upcase "hello")  ; Should return "HELLO"
(string-prefix-p "hel" "hello")  ; Should return t

;; Test 3: List operations
(car '(1 2 3))  ; Should return 1
(cdr '(1 2 3))  ; Should return (2 3)
(length '(1 2 3 4 5))  ; Should return 5

;; Test 4: Defun (type "defun" then M-+ to expand)
(defun my-add (a b)
  "Add A and B."
  (+ a b))

;; Test 5: Defvar (type "defvar" then M-+ to expand)
(defvar my-counter 0
  "Counter for testing.")

;; Test 6: Defconst
(defconst my-version "1.0.0"
  "Version of test package.")

;; Test 7: When/Unless (type "when" then M-+ to expand)
(when (> 5 3)
  (message "5 is greater than 3"))

(unless (< 5 3)
  (message "5 is not less than 3"))

;; Test 8: Let binding
(let ((x 10)
      (y 20))
  (message "x + y = %d" (+ x y)))

;; Test 9: Lambda
(mapcar (lambda (x) (* x x))
        '(1 2 3 4 5))

;; Test 10: Interactive function
(defun my-greet (name)
  "Greet NAME interactively."
  (interactive "sEnter name: ")
  (message "Hello, %s!" name))

;; Test 11: Conditional
(defun my-check-number (n)
  "Check if N is positive, negative, or zero."
  (cond
   ((> n 0) "positive")
   ((< n 0) "negative")
   (t "zero")))

;; Test 12: Error handling
(defun my-safe-divide (a b)
  "Safely divide A by B."
  (if (= b 0)
      (error "Division by zero")
    (/ a b)))

;; Test 13: Package feature check
(defun my-check-packages ()
  "Check if required packages are installed."
  (interactive)
  (let ((packages '(vertico orderless corfu consult magit)))
    (dolist (pkg packages)
      (if (package-installed-p pkg)
          (message "%s: installed" pkg)
        (message "%s: NOT installed" pkg)))))

;; Test 14: Buffer operations
(defun my-buffer-info ()
  "Show current buffer information."
  (interactive)
  (message "Buffer: %s, Mode: %s, Size: %d"
           (buffer-name)
           (major-mode)
           (buffer-size)))

;; Test 15: ERT Tests
(ert-deftest my-test-add ()
  "Test my-add function."
  (should (= (my-add 2 3) 5))
  (should (= (my-add -1 1) 0))
  (should (= (my-add 0 0) 0)))

(ert-deftest my-test-check-number ()
  "Test my-check-number function."
  (should (string= (my-check-number 5) "positive"))
  (should (string= (my-check-number -5) "negative"))
  (should (string= (my-check-number 0) "zero")))

(ert-deftest my-test-safe-divide ()
  "Test my-safe-divide function."
  (should (= (my-safe-divide 10 2) 5))
  (should (= (my-safe-divide 9 3) 3))
  (should-error (my-safe-divide 10 0)))

;; VERIFICATION:
;; - [ ] Evaluation works (C-x C-e)
;; - [ ] Buffer eval works (C-c C-c)
;; - [ ] Error debug works (toggle-debug-on-error)
;; - [ ] ERT tests pass (C-c C-e)
;; - [ ] Snippets expand (M-+)
;; - [ ] Helpful works (C-h f, C-h v)
;; - [ ] No byte-compile warnings

;;; elisp-test.el ends here
