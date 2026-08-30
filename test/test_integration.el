;;; test_integration.el --- Integration Tests for Scratchy  -*- lexical-binding: t; -*-

;;; Commentary:

;; Integration tests to verify workflows and package interactions.
;; These tests check that packages work together correctly.

;;; Code:

;;; ==========================================================================
;;; INTEGRATION TEST FRAMEWORK
;;; ==========================================================================

(defvar integration-test-count 0)
(defvar integration-test-passed 0)
(defvar integration-test-failed 0)
(defvar integration-test-failures '())

(defun integration-test--assert (name condition)
  "Assert CONDITION with NAME."
  (setq integration-test-count (1+ integration-test-count))
  (if condition
      (progn
        (setq integration-test-passed (1+ integration-test-passed))
        (format "ok %d - %s" integration-test-count name))
    (progn
      (setq integration-test-failed (1+ integration-test-failed))
      (push name integration-test-failures)
      (format "not ok %d - %s" integration-test-count name))))

(defun integration-test--summary ()
  "Print integration test summary."
  (princ (format "\n# -----------------------------------------------\n"))
  (princ (format "# %d passed, %d failed\n" integration-test-passed integration-test-failed))
  (unless (null integration-test-failures)
    (princ "\n# Failed Tests:\n")
    (dolist (fail integration-test-failures)
      (princ (format "# - %s\n" fail))))
  (princ (format "# -----------------------------------------------\n"))
  (princ (format "# RESULT: %s\n" (if (= integration-test-failed 0) "PASSED" "FAILED"))))

;;; ==========================================================================
;;; 1. LSP + COMPLETION INTEGRATION
;;; ==========================================================================

(integration-test--assert "1.1 Eglot and Corfu both active"
  (and (bound-and-true-p eglot-autoshutdown)
       (bound-and-true-p global-corfu-mode)))

(integration-test--assert "1.2 Cape is configured for completion"
  (and (fboundp 'cape-dabbrev)
       (fboundp 'cape-file)
       (fboundp 'cape-keyword)))

(integration-test--assert "1.3 Vertico is active for minibuffer"
  (bound-and-true-p vertico-mode))

(integration-test--assert "1.4 Orderless is in completion styles"
  (member 'orderless completion-styles))

(integration-test--assert "1.5 Marginalia is active for annotations"
  (bound-and-true-p marginalia-mode))


;;; ==========================================================================
;;; 2. GIT + DIFF INTEGRATION
;;; ==========================================================================

(integration-test--assert "2.1 Magit and diff-hl both loaded"
  (and (fboundp 'magit-status)
       (fboundp 'diff-hl)))

(integration-test--assert "2.2 diff-hl hooks are configured"
  (member 'diff-hl-mode prog-mode-hook))

(integration-test--assert "2.3 Magit display function is configured"
  (boundp 'magit-display-buffer-function))


;;; ==========================================================================
;;; 3. PROJECT + BUILD INTEGRATION
;;; ==========================================================================

(integration-test--assert "3.1 Project.el is configured"
  (boundp 'project-switch-commands))

(integration-test--assert "3.2 Build functions are defined"
  (and (fboundp 'my/cpp-build)
       (fboundp 'my/cpp-run)
       (fboundp 'my/python-run)
       (fboundp 'my/bash-run)))

(integration-test--assert "3.3 Compile settings are configured"
  (eq compilation-scroll-output t))


;;; ==========================================================================
;;; 4. SNIPPETS + COMPLETION INTEGRATION
;;; ==========================================================================

(integration-test--assert "4.1 Tempel is installed"
  (package-installed-p 'tempel))

(integration-test--assert "4.2 Tempel keybindings are set"
  (and (eq (key-binding (kbd "M-+")) 'tempel-complete)
       (eq (key-binding (kbd "M-*")) 'tempel-insert)))

(integration-test--assert "4.3 Tempel path is configured"
  (and (boundp 'tempel-path)
       (file-exists-p tempel-path)))


;;; ==========================================================================
;;; 5. SEARCH + NAVIGATION INTEGRATION
;;; ==========================================================================

(integration-test--assert "5.1 Consult keybindings are set"
  (and (eq (key-binding (kbd "C-s")) 'consult-line)
       (eq (key-binding (kbd "C-x b")) 'consult-buffer)
       (eq (key-binding (kbd "M-s r")) 'consult-ripgrep)
       (eq (key-binding (kbd "M-y")) 'consult-yank-pop)))

(integration-test--assert "5.2 Which-key is active for discoverability"
  (bound-and-true-p which-key-mode))


;;; ==========================================================================
;;; 6. COMFORT + UX INTEGRATION
;;; ==========================================================================

(integration-test--assert "6.1 Save-place, savehist, recentf active"
  (and (bound-and-true-p save-place-mode)
       (bound-and-true-p savehist-mode)
       (bound-and-true-p recentf-mode)))

(integration-test--assert "6.2 Delete-selection and vundo are available"
  (and (bound-and-true-p delete-selection-mode)
       (fboundp 'vundo)))

(integration-test--assert "6.3 Ace-window is bound to M-o"
  (eq (key-binding (kbd "M-o")) 'ace-window))


;;; ==========================================================================
;;; 7. THEME + VISUAL INTEGRATION
;;; ==========================================================================

(integration-test--assert "7.1 Modus-vivendi theme is loaded"
  (bound-and-true-p modus-vivendi-mode))

(integration-test--assert "7.2 Line numbers are enabled"
  (bound-and-true-p display-line-numbers-mode))

(integration-test--assert "7.3 hl-line is active"
  (bound-and-true-p hl-line-mode))


;;; ==========================================================================
;;; 8. TERMINAL + SHELL INTEGRATION
;;; ==========================================================================

(integration-test--assert "8.1 Eat is available"
  (fboundp 'eat))

(integration-test--assert "8.2 Eat keybinding is set"
  (eq (key-binding (kbd "C-c t n")) 'eat))


;;; ==========================================================================
;;; 9. HELP + DOCUMENTATION INTEGRATION
;;; ==========================================================================

(integration-test--assert "9.1 Helpful replaces describe functions"
  (and (eq (command-remapping 'describe-function) 'helpful-callable)
       (eq (command-remapping 'describe-variable) 'helpful-variable)
       (eq (command-remapping 'describe-key) 'helpful-key)))


;;; ==========================================================================
;;; 10. DOCKER + DEVOPS INTEGRATION
;;; ==========================================================================

(integration-test--assert "10.1 Docker is available"
  (fboundp 'docker))

(integration-test--assert "10.2 Dockerfile-mode is configured"
  (and (fboundp 'dockerfile-mode)
       (package-installed-p 'dockerfile-mode)))


;;; ==========================================================================
;;; 11. TREE-SITTER INTEGRATION
;;; ==========================================================================

(integration-test--assert "11.1 treesit-auto is configured"
  (boundp 'treesit-auto-install))

(integration-test--assert "11.2 global-treesit-auto-mode is set"
  (string-match-p "global-treesit-auto-mode" (with-temp-buffer
                                                (insert-file-contents
                                                 (expand-file-name "src/init.el"
                                                                    (file-name-directory
                                                                     (directory-file-name
                                                                      (file-name-directory load-file-name)))))
                                                (buffer-string))))


;;; ==========================================================================
;;; 12. SESSION + DESKTOP INTEGRATION
;;; ==========================================================================

(integration-test--assert "12.1 Desktop-save-mode is active"
  (bound-and-true-p desktop-save-mode))

(integration-test--assert "12.2 Desktop settings are configured"
  (and (eq desktop-auto-save-timeout 300)
       (eq desktop-save t)))


;;; ==========================================================================
;;; SUMMARY
;;; ==========================================================================

(integration-test--summary)

;;; test_integration.el ends here
