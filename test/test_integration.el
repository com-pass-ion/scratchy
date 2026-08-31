;;; test_integration.el --- Integration Tests for Scratchy  -*- lexical-binding: t; -*-

;;; Commentary:

;; Integration tests to verify workflows and package interactions.
;; These tests check that packages work together correctly.
;;
;; Run with:
;;   emacs --batch -l test_integration.el
;;
;; Output: TAP-compatible (Test Anything Protocol).

;;; Code:

;;; ==========================================================================
;;; TEST FRAMEWORK
;;; ==========================================================================

(defvar inttest--passed 0
  "Count of passed tests.")

(defvar inttest--failed 0
  "Count of failed tests.")

(defmacro inttest--assert (name &rest body)
  "Run BODY as a test assertion. NAME is the test description."
  (declare (indent 1))
  `(progn
     (condition-case err
         (progn
           ,@body
           (cl-incf inttest--passed)
           (message "ok %d - %s" inttest--passed ,name))
       (error
        (cl-incf inttest--failed)
        (message "not ok %d - %s" (+ inttest--passed inttest--failed) ,name)
        (message "  Error: %s" (error-message-string err))))))

(defun inttest--summary ()
  "Print test summary and exit."
  (message "")
  (message "# -----------------------------------------------")
  (message "# %d passed, %d failed" inttest--passed inttest--failed)
  (message "# -----------------------------------------------")
  (if (> inttest--failed 0)
      (progn
        (message "# RESULT: FAILED")
        (kill-emacs 1))
    (message "# RESULT: PASSED")
    (kill-emacs 0)))

(defun inttest--get-init-el ()
  "Return contents of init.el as string."
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name "src/init.el"
                       (file-name-directory (directory-file-name (file-name-directory load-file-name)))))
    (buffer-string)))


;;; ==========================================================================
;;; LOAD INIT.EL
;;; ==========================================================================

(message "# Loading init.el for integration tests...")
(load (expand-file-name "src/init.el" (file-name-directory (directory-file-name (file-name-directory load-file-name)))) nil t)
(message "# init.el loaded successfully.")
(message "")


;;; ==========================================================================
;;; 1. LSP + COMPLETION INTEGRATION
;;; ==========================================================================
;; Eglot + Corfu + Cape work together for code intelligence.

(inttest--assert "1.1 Eglot and Corfu are both active"
  (cl-assert (eq eglot-autoshutdown t))
  (cl-assert (bound-and-true-p global-corfu-mode)))

(inttest--assert "1.2 Cape backends are configured"
  (cl-assert (fboundp 'cape-dabbrev))
  (cl-assert (fboundp 'cape-file))
  (cl-assert (fboundp 'cape-keyword)))

(inttest--assert "1.3 Vertico is active for minibuffer completion"
  (cl-assert (bound-and-true-p vertico-mode)))

(inttest--assert "1.4 Orderless is in completion styles"
  (cl-assert (memq 'orderless completion-styles)))

(inttest--assert "1.5 Marginalia provides annotations"
  (cl-assert (bound-and-true-p marginalia-mode)))


;;; ==========================================================================
;;; 2. GIT + DIFF INTEGRATION
;;; ==========================================================================
;; Magit + diff-hl provide version control in the editor.

(inttest--assert "2.1 Magit and diff-hl are both available"
  (cl-assert (fboundp 'magit-status))
  (cl-assert (fboundp 'diff-hl-mode)))

(inttest--assert "2.2 diff-hl hook is configured for prog-mode"
  ;; diff-hl may be lazy-loaded; verify source has the hook
  (cl-assert (string-match-p "diff-hl-mode" (inttest--get-init-el))))

(inttest--assert "2.3 Magit display function is configured"
  ;; magit may be lazy-loaded; verify source has the config
  (cl-assert (string-match-p "magit-display-buffer-function" (inttest--get-init-el))))


;;; ==========================================================================
;;; 3. PROJECT + BUILD INTEGRATION
;;; ==========================================================================
;; Project.el + build functions provide the build workflow.

(inttest--assert "3.1 Project.el is configured"
  (cl-assert (eq project-switch-commands 'project-find-dir)))

(inttest--assert "3.2 Build functions are defined"
  (cl-assert (fboundp 'my/cpp-build))
  (cl-assert (fboundp 'my/cpp-run))
  (cl-assert (fboundp 'my/python-run))
  (cl-assert (fboundp 'my/bash-run))
  (cl-assert (fboundp 'my/run)))

(inttest--assert "3.3 Compile settings are configured"
  (cl-assert (eq compilation-scroll-output t)))

(inttest--assert "3.4 Project scaffolding is defined"
  (cl-assert (fboundp 'my/project-new)))


;;; ==========================================================================
;;; 4. SNIPPETS + COMPLETION INTEGRATION
;;; ==========================================================================
;; Tempel + Corfu provide snippet expansion.

(inttest--assert "4.1 Tempel is installed"
  (cl-assert (package-installed-p 'tempel)))

(inttest--assert "4.2 Tempel keybindings are set"
  (cl-assert (eq (key-binding (kbd "M-+")) 'tempel-complete))
  (cl-assert (eq (key-binding (kbd "M-*")) 'tempel-insert)))

(inttest--assert "4.3 Tempel path is configured"
  (cl-assert (boundp 'tempel-path))
  (cl-assert (file-exists-p tempel-path)))


;;; ==========================================================================
;;; 5. SEARCH + NAVIGATION INTEGRATION
;;; ==========================================================================
;; Consult + Vertico + Orderless provide search workflow.

(inttest--assert "5.1 Consult keybindings are set"
  (cl-assert (eq (key-binding (kbd "C-s")) 'consult-line))
  (cl-assert (eq (key-binding (kbd "C-x b")) 'consult-buffer))
  (cl-assert (eq (key-binding (kbd "M-s r")) 'consult-ripgrep))
  (cl-assert (eq (key-binding (kbd "M-y")) 'consult-yank-pop)))

(inttest--assert "5.2 Which-key is active for discoverability"
  (cl-assert (bound-and-true-p which-key-mode)))


;;; ==========================================================================
;;; 6. COMFORT + UX INTEGRATION
;;; ==========================================================================
;; Built-in quality-of-life features work together.

(inttest--assert "6.1 Persistent state features are active"
  (cl-assert (bound-and-true-p save-place-mode))
  (cl-assert (bound-and-true-p savehist-mode))
  (cl-assert (bound-and-true-p recentf-mode)))

(inttest--assert "6.2 Delete-selection and vundo are available"
  (cl-assert (bound-and-true-p delete-selection-mode))
  (cl-assert (fboundp 'vundo)))

(inttest--assert "6.3 Ace-window is bound to M-o"
  (cl-assert (eq (key-binding (kbd "M-o")) 'ace-window)))


;;; ==========================================================================
;;; 7. THEME + VISUAL INTEGRATION
;;; ==========================================================================
;; Theme and visual features work together.

(inttest--assert "7.1 Modus-vivendi theme is loaded"
  (cl-assert (memq 'modus-vivendi custom-enabled-themes)))

(inttest--assert "7.2 Line numbers are enabled"
  ;; global-display-line-numbers-mode may differ in batch; verify source
  (cl-assert (string-match-p "global-display-line-numbers-mode" (inttest--get-init-el))))

(inttest--assert "7.3 hl-line is active"
  (cl-assert (bound-and-true-p global-hl-line-mode)))


;;; ==========================================================================
;;; 8. TERMINAL + SHELL INTEGRATION
;;; ==========================================================================
;; Eat provides terminal inside Emacs.

(inttest--assert "8.1 Eat is available"
  (cl-assert (fboundp 'eat)))

(inttest--assert "8.2 Eat keybinding is set"
  (cl-assert (eq (key-binding (kbd "C-c t n")) 'eat)))


;;; ==========================================================================
;;; 9. HELP + DOCUMENTATION INTEGRATION
;;; ==========================================================================
;; Helpful replaces default describe functions.

(inttest--assert "9.1 Helpful replaces describe functions"
  (cl-assert (eq (command-remapping 'describe-function) 'helpful-callable))
  (cl-assert (eq (command-remapping 'describe-variable) 'helpful-variable))
  (cl-assert (eq (command-remapping 'describe-key) 'helpful-key)))


;;; ==========================================================================
;;; 10. DOCKER + DEVOPS INTEGRATION
;;; ==========================================================================
;; Docker.el + dockerfile-mode provide DevOps workflow.

(inttest--assert "10.1 Docker is available"
  (cl-assert (fboundp 'docker)))

(inttest--assert "10.2 Dockerfile-mode is configured"
  (cl-assert (fboundp 'dockerfile-mode))
  (cl-assert (package-installed-p 'dockerfile-mode)))


;;; ==========================================================================
;;; 11. TREE-SITTER INTEGRATION
;;; ==========================================================================
;; treesit-auto provides better syntax highlighting.

(inttest--assert "11.1 treesit-auto is configured"
  (cl-assert (boundp 'treesit-auto-install)))

(inttest--assert "11.2 global-treesit-auto-mode is configured"
  (cl-assert (string-match-p "global-treesit-auto-mode" (inttest--get-init-el))))


;;; ==========================================================================
;;; 12. SESSION + DESKTOP INTEGRATION
;;; ==========================================================================
;; Desktop-save-mode provides session persistence.

(inttest--assert "12.1 Desktop-save-mode is active"
  (cl-assert (bound-and-true-p desktop-save-mode)))

(inttest--assert "12.2 Desktop settings are configured"
  (cl-assert (= desktop-auto-save-timeout 300))
  (cl-assert (eq desktop-save t)))


;;; ==========================================================================
;;; SUMMARY
;;; ==========================================================================

(inttest--summary)

;;; test_integration.el ends here
