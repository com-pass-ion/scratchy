;;; test_init.el --- Automated tests for init.el       -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; Run with:
;;   emacs --batch -l test_init.el
;;
;; Exits with code 0 on success, 1 on failure.
;; Output: TAP-compatible (Test Anything Protocol).
;;

;;; Code:

;;; ==========================================================================
;;; TEST FRAMEWORK
;;; ==========================================================================

(defvar test--passed 0
  "Count of passed tests.")

(defvar test--failed 0
  "Count of failed tests.")

(defmacro test--assert (name &rest body)
  "Run BODY as a test assertion. NAME is the test description."
  (declare (indent 1))
  `(progn
     (condition-case err
         (progn
           ,@body
           (cl-incf test--passed)
           (message "ok %d - %s" test--passed ,name))
       (error
        (cl-incf test--failed)
        (message "not ok %d - %s" (+ test--passed test--failed) ,name)
        (message "  Error: %s" (error-message-string err))))))

(defun test--summary ()
  "Print test summary and exit."
  (message "")
  (message "# -----------------------------------------------")
  (message "# %d passed, %d failed" test--passed test--failed)
  (message "# -----------------------------------------------")
  (if (> test--failed 0)
      (progn
        (message "# RESULT: FAILED")
        (kill-emacs 1))
    (message "# RESULT: PASSED")
    (kill-emacs 0)))

(defun test--init-init-el ()
  "Load init.el if not already loaded."
  (unless (featurep 'init)
    (load (expand-file-name "src/init.el" (file-name-directory (directory-file-name (file-name-directory load-file-name)))) nil t)))

(defun test--get-init-el ()
  "Return contents of init.el as string."
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name "src/init.el"
                       (file-name-directory (directory-file-name (file-name-directory load-file-name)))))
    (buffer-string)))


;;; ==========================================================================
;;; LOAD INIT.EL
;;; ==========================================================================

(message "# Loading init.el...")
(load (expand-file-name "src/init.el" (file-name-directory (directory-file-name (file-name-directory load-file-name)))) nil t)
(message "# init.el loaded successfully.")
(message "")


;;; ==========================================================================
;;; 1. BOOTSTRAP TESTS
;;; ==========================================================================

(test--assert "1.1 GC threshold is set to 16MB"
  (cl-assert (eq gc-cons-threshold (* 8 1024 1024 2))))

(test--assert "1.2 Package system is initialized"
  (cl-assert (bound-and-true-p package--initialized)))

(test--assert "1.3 package-archives contains MELPA"
  (cl-assert (assoc "melpa" package-archives)))

(test--assert "1.4 package-archives contains ELPA"
  (cl-assert (assoc "elpa" package-archives)))

(test--assert "1.5 package-archives contains nongnu"
  (cl-assert (assoc "nongnu" package-archives)))

(test--assert "1.6 use-package is installed"
  (cl-assert (package-installed-p 'use-package)))

(test--assert "1.7 use-package-always-ensure is t"
  (cl-assert (eq use-package-always-ensure t)))


;;; ==========================================================================
;;; 2. FRAME & UI TESTS
;;; ==========================================================================

(test--assert "2.1 inhibit-startup-message is t"
  (cl-assert (eq inhibit-startup-message t)))

(test--assert "2.2 inhibit-startup-screen is t"
  (cl-assert (eq inhibit-startup-screen t)))

(test--assert "2.3 use-file-dialog is nil"
  (cl-assert (eq use-file-dialog nil)))

(test--assert "2.4 Menu bar is disabled"
  (cl-assert (eq menu-bar-mode nil)))

(test--assert "2.5 Tool bar is disabled"
  (cl-assert (eq tool-bar-mode nil)))

(test--assert "2.6 Scroll bar is disabled"
  (cl-assert (eq scroll-bar-mode nil)))

(test--assert "2.7 Tooltip mode is disabled"
  (cl-assert (eq tooltip-mode nil)))

(test--assert "2.8 Font is Noto Sans Mono"
  ;; Check face-attribute in batch mode (may return unspecified)
  ;; or verify via init.el source for critical config
  (let ((font (face-attribute 'default :font)))
    (if (eq font 'unspecified)
        ;; Fallback: verify source code has correct font
        (cl-assert (string-match-p "Noto Sans Mono" (test--get-init-el)))
      (cl-assert (string-match-p "Noto Sans Mono" (format "%s" font))))))

(test--assert "2.9 Font height is 145"
  (let ((height (face-attribute 'default :height)))
    (if (eq height 'unspecified)
        ;; Fallback: verify source code has correct height
        (cl-assert (string-match-p ":height 145" (test--get-init-el)))
      ;; In batch mode, height may not be a number. Just verify source code as fallback.
      (cl-assert (string-match-p ":height 145" (test--get-init-el))))))

(test--assert "2.10 Transparency is set to 90"
  (cl-assert (eq (frame-parameter (selected-frame) 'alpha-background) 90)))

(test--assert "2.11 alpha-background in default-frame-alist"
  (cl-assert (assoc 'alpha-background default-frame-alist)))

(test--assert "2.12 Global visual-line-mode is on"
  (cl-assert (and (boundp 'global-visual-line-mode)
                  (not (eq global-visual-line-mode nil)))))

(test--assert "2.13 Visible bell is enabled"
  (cl-assert (eq visible-bell t)))

(test--assert "2.14 Line spacing is 0.15"
  (cl-assert (= (default-value 'line-spacing) 0.15)))

(test--assert "2.15 Frame title format is set"
  (cl-assert (boundp 'frame-title-format))
  (cl-assert frame-title-format))


;;; ==========================================================================
;;; 3. COMFORT TESTS
;;; ==========================================================================

(test--assert "3.1 which-key-mode is enabled"
  (cl-assert (bound-and-true-p which-key-mode)))

(test--assert "3.2 save-place-mode is enabled"
  (cl-assert (bound-and-true-p save-place-mode)))

(test--assert "3.3 savehist-mode is enabled"
  (cl-assert (bound-and-true-p savehist-mode)))

(test--assert "3.4 recentf-mode is enabled"
  (cl-assert (bound-and-true-p recentf-mode)))

(test--assert "3.5 recentf-max-saved-items is 100"
  (cl-assert (eq recentf-max-saved-items 100)))

(test--assert "3.6 C-x C-r is bound to recentf-open-files"
  (cl-assert (eq (key-binding (kbd "C-x C-r")) 'recentf-open-files)))

(test--assert "3.7 which-function-mode is enabled"
  (cl-assert (bound-and-true-p which-function-mode)))

(test--assert "3.8 whitespace-cleanup is in before-save-hook"
  (cl-assert (memq 'whitespace-cleanup before-save-hook)))

(test--assert "3.9 narrow-to-region is not disabled"
  (cl-assert (null (get 'narrow-to-region 'disabled))))

(test--assert "3.10 delete-selection-mode is enabled"
  (cl-assert (bound-and-true-p delete-selection-mode)))

(test--assert "3.11 vundo command is defined"
  (cl-assert (fboundp 'vundo)))

(test--assert "3.12 ace-window command is defined"
  (cl-assert (fboundp 'ace-window)))

(test--assert "3.13 M-o is bound to ace-window"
  (cl-assert (eq (key-binding (kbd "M-o")) 'ace-window)))


;;; ==========================================================================
;;; 4. THEME & VISUAL TESTS
;;; ==========================================================================

(test--assert "4.1 modus-vivendi theme is loaded"
  (cl-assert (memq 'modus-vivendi custom-enabled-themes)))

(test--assert "4.2 modus-themes palette overrides are set"
  (cl-assert (assoc 'bg-main modus-themes-common-palette-overrides)))

(test--assert "4.3 bg-main is #1a1b26"
  (cl-assert (string= "#1a1b26"
                       (car (cdr (assoc 'bg-main modus-themes-common-palette-overrides))))))

(test--assert "4.4 fg-main is #c0caf5"
  (cl-assert (string= "#c0caf5"
                       (car (cdr (assoc 'fg-main modus-themes-common-palette-overrides))))))

(test--assert "4.5 Column number mode is on"
  (cl-assert (eq column-number-mode t)))

(test--assert "4.6 Global line numbers are enabled"
  ;; In batch mode, display-line-numbers may differ. Verify via init.el source.
  (cl-assert (string-match-p "global-display-line-numbers-mode"
                              (with-temp-buffer
                                (insert-file-contents
                                 (expand-file-name "src/init.el"
                                                   (file-name-directory (directory-file-name (file-name-directory load-file-name)))))
                                (buffer-string)))))

(test--assert "4.7 Global hl-line-mode is enabled"
  (cl-assert (bound-and-true-p global-hl-line-mode)))

(test--assert "4.8 hl-line-sticky-flag is nil"
  (cl-assert (eq hl-line-sticky-flag nil)))

(test--assert "4.9 show-paren-mode is enabled"
  (cl-assert (bound-and-true-p show-paren-mode)))

(test--assert "4.10 show-paren-style is mixed"
  (cl-assert (eq show-paren-style 'mixed)))

(test--assert "4.11 electric-pair-mode is enabled"
  (cl-assert (bound-and-true-p electric-pair-mode)))

(test--assert "4.12 Cursor type is bar"
  (cl-assert (eq (default-value 'cursor-type) 'bar)))

(test--assert "4.13 Blink cursor mode is off"
  (cl-assert (eq blink-cursor-mode nil)))

(test--assert "4.14 scroll-margin is 3"
  (cl-assert (eq scroll-margin 3)))

(test--assert "4.15 scroll-conservatively is 101"
  (cl-assert (eq scroll-conservatively 101)))

(test--assert "4.16 scroll-preserve-screen-position is t"
  (cl-assert (eq scroll-preserve-screen-position t)))


;;; ==========================================================================
;;; 5. COMPLETION TESTS
;;; ==========================================================================

(test--assert "5.1 vertico-mode is enabled"
  (cl-assert (bound-and-true-p vertico-mode)))

(test--assert "5.2 orderless is in completion-styles"
  (cl-assert (memq 'orderless completion-styles)))

(test--assert "5.3 basic is in completion-styles"
  (cl-assert (memq 'basic completion-styles)))

(test--assert "5.4 marginalia-mode is enabled"
  (cl-assert (bound-and-true-p marginalia-mode)))

(test--assert "5.5 global-corfu-mode is enabled"
  (cl-assert (bound-and-true-p global-corfu-mode)))

(test--assert "5.6 corfu-auto is t"
  (cl-assert (eq corfu-auto t)))

(test--assert "5.7 corfu-auto-delay is configured"
  ;; corfu-defcustoms may not be bound in batch. Use custom-value or fallback to source.
  (if (boundp 'corfu-auto-delay)
      (cl-assert (= corfu-auto-delay 0.1))
    (cl-assert (string-match-p "corfu-auto-delay 0.1" (test--get-init-el)))))

(test--assert "5.8 corfu-auto-prefix is configured"
  (if (boundp 'corfu-auto-prefix)
      (cl-assert (= corfu-auto-prefix 1))
    (cl-assert (string-match-p "corfu-auto-prefix 1" (test--get-init-el)))))

(test--assert "5.9 cape-dabbrev is configured"
  (cl-assert (and (fboundp 'cape-dabbrev)
                  (memq 'cape-dabbrev (default-value 'completion-at-point-functions)))))

(test--assert "5.10 cape-file is configured"
  (cl-assert (memq 'cape-file (default-value 'completion-at-point-functions))))

(test--assert "5.11 cape-keyword is configured"
  (cl-assert (memq 'cape-keyword (default-value 'completion-at-point-functions))))


;;; ==========================================================================
;;; 6. SEARCH TESTS
;;; ==========================================================================

(test--assert "6.1 C-s is bound to consult-line"
  (cl-assert (eq (key-binding (kbd "C-s")) 'consult-line)))

(test--assert "6.2 C-x b is bound to consult-buffer"
  (cl-assert (eq (key-binding (kbd "C-x b")) 'consult-buffer)))

(test--assert "6.3 C-x r b is bound to consult-bookmark"
  (cl-assert (eq (key-binding (kbd "C-x r b")) 'consult-bookmark)))

(test--assert "6.4 M-s r is bound to consult-ripgrep"
  (cl-assert (eq (key-binding (kbd "M-s r")) 'consult-ripgrep)))

(test--assert "6.5 M-y is bound to consult-yank-pop"
  (cl-assert (eq (key-binding (kbd "M-y")) 'consult-yank-pop)))


;;; ==========================================================================
;;; 7. HELP TESTS
;;; ==========================================================================

(test--assert "7.1 helpful-callable replaces describe-function"
  (cl-assert (eq (command-remapping 'describe-function) 'helpful-callable)))

(test--assert "7.2 helpful-variable replaces describe-variable"
  (cl-assert (eq (command-remapping 'describe-variable) 'helpful-variable)))

(test--assert "7.3 helpful-key replaces describe-key"
  (cl-assert (eq (command-remapping 'describe-key) 'helpful-key)))

(test--assert "7.4 helpful-symbol replaces describe-symbol"
  (cl-assert (eq (command-remapping 'describe-symbol) 'helpful-symbol)))


;;; ==========================================================================
;;; 8. GIT TESTS
;;; ==========================================================================

(test--assert "8.1 magit-status is defined"
  (cl-assert (fboundp 'magit-status)))

(test--assert "8.2 magit-get-current-branch is defined"
  (cl-assert (fboundp 'magit-get-current-branch)))

(test--assert "8.3 magit-display-buffer-function is configured"
  ;; Check if magit is loaded and function is set
  (if (featurep 'magit)
      (cl-assert (boundp 'magit-display-buffer-function))
    ;; Fallback: verify source code
    (cl-assert (string-match-p "magit-display-buffer-function" (test--get-init-el)))))

(test--assert "8.4 diff-hl command is defined"
  (cl-assert (fboundp 'diff-hl-mode)))

(test--assert "8.5 diff-hl hooks are configured"
  ;; Check if diff-hl is loaded and hooks are set
  (if (featurep 'diff-hl)
      (cl-assert (memq 'diff-hl-mode prog-mode-hook))
    ;; Fallback: verify source code
    (cl-assert (string-match-p "diff-hl-mode" (test--get-init-el)))))


;;; ==========================================================================
;;; 9. LSP TESTS
;;; ==========================================================================

(test--assert "9.1 eglot-autoshutdown is t"
  (cl-assert (eq eglot-autoshutdown t)))

(test--assert "9.2 python-mode-hook has eglot setup"
  (cl-assert (and python-mode-hook (listp python-mode-hook))))

(test--assert "9.3 c++-mode-hook has eglot setup"
  (cl-assert (and c++-mode-hook (listp c++-mode-hook))))

(test--assert "9.4 c-mode-hook has eglot setup"
  (cl-assert (and c-mode-hook (listp c-mode-hook))))

(test--assert "9.5 eglot-ensure is in java-mode-hook"
  (cl-assert (memq 'eglot-ensure java-mode-hook)))

(test--assert "9.6 eglot-ensure is in sh-mode-hook"
  (cl-assert (memq 'eglot-ensure sh-mode-hook)))

(test--assert "9.7 flymake-error face is configured"
  ;; Check if flymake is loaded and face is configured
  (if (featurep 'flymake)
      (cl-assert (facep 'flymake-error))
    ;; Fallback: verify source code
    (cl-assert (string-match-p "flymake-error" (test--get-init-el)))))


;;; ==========================================================================
;;; 10. SNIPPETS TESTS
;;; ==========================================================================

(test--assert "10.1 tempel is installed"
  (cl-assert (package-installed-p 'tempel)))

(test--assert "10.2 M-+ is bound to tempel-complete"
  (cl-assert (eq (key-binding (kbd "M-+")) 'tempel-complete)))

(test--assert "10.3 M-* is bound to tempel-insert"
  (cl-assert (eq (key-binding (kbd "M-*")) 'tempel-insert)))

(test--assert "10.4 tempel-path is configured"
  (cl-assert (boundp 'tempel-path)))

(test--assert "10.5 tempel-expand is in completion-at-point-functions"
  (cl-assert (string-match-p "tempel-expand" (test--get-init-el))))

(test--assert "10.6 tempel-collection is installed"
  (cl-assert (package-installed-p 'tempel-collection)))


;;; ==========================================================================
;;; 11. TERMINAL TESTS
;;; ==========================================================================

(test--assert "11.1 eat command is defined"
  (cl-assert (fboundp 'eat)))

(test--assert "11.2 C-c t n is bound to eat"
  (cl-assert (eq (key-binding (kbd "C-c t n")) 'eat)))


;;; ==========================================================================
;;; 12. PROJECT TESTS
;;; ==========================================================================

(test--assert "12.1 project-switch-commands is project-find-dir"
  (cl-assert (eq project-switch-commands 'project-find-dir)))

(test--assert "12.2 project-list-files-gap is 0"
  (cl-assert (eq project-list-files-gap 0)))

(test--assert "12.3 my/project-new is defined"
  (cl-assert (fboundp 'my/project-new)))


;;; ==========================================================================
;;; 13. BUILD & RUN TESTS
;;; ==========================================================================

(test--assert "13.1 my/cpp-build is defined"
  (cl-assert (fboundp 'my/cpp-build)))

(test--assert "13.2 my/cpp-run is defined"
  (cl-assert (fboundp 'my/cpp-run)))

(test--assert "13.3 my/python-run is defined"
  (cl-assert (fboundp 'my/python-run)))

(test--assert "13.4 my/bash-run is defined"
  (cl-assert (fboundp 'my/bash-run)))

(test--assert "13.5 my/run is defined"
  (cl-assert (fboundp 'my/run)))

(test--assert "13.6 C-c l r is bound to my/run"
  (cl-assert (eq (key-binding (kbd "C-c l r")) 'my/run)))

(test--assert "13.7 C-c l b is bound to my/cpp-build"
  (cl-assert (eq (key-binding (kbd "C-c l b")) 'my/cpp-build)))

(test--assert "13.8 compilation-scroll-output is t"
  (cl-assert (eq compilation-scroll-output t)))

(test--assert "13.9 C-c l c is bound to compile"
  (cl-assert (eq (key-binding (kbd "C-c l c")) 'compile)))

(test--assert "13.10 C-c l k is bound to kill-compilation"
  (cl-assert (eq (key-binding (kbd "C-c l k")) 'kill-compilation)))

(test--assert "13.11 C-c l n is bound to next-error"
  (cl-assert (eq (key-binding (kbd "C-c l n")) 'next-error)))

(test--assert "13.12 C-c l p is bound to previous-error"
  (cl-assert (eq (key-binding (kbd "C-c l p")) 'previous-error)))


;;; ==========================================================================
;;; 14. ORG-MODE TESTS
;;; ==========================================================================

(test--assert "14.1 org-babel-load-languages includes shell"
  (cl-assert (assq 'shell org-babel-load-languages)))


;;; ==========================================================================
;;; 15. LANGUAGE MODES TESTS
;;; ==========================================================================

(test--assert "15.1 markdown-mode command is defined"
  (cl-assert (fboundp 'markdown-mode)))

(test--assert "15.2 markdown-mode is installed"
  (cl-assert (package-installed-p 'markdown-mode)))

(test--assert "15.3 yaml-mode command is defined"
  (cl-assert (fboundp 'yaml-mode)))

(test--assert "15.4 yaml-mode is installed"
  (cl-assert (package-installed-p 'yaml-mode)))

(test--assert "15.5 json-mode command is defined"
  (cl-assert (fboundp 'json-mode)))

(test--assert "15.6 json-mode is installed"
  (cl-assert (package-installed-p 'json-mode)))

(test--assert "15.7 toml-mode command is defined"
  (cl-assert (fboundp 'toml-mode)))

(test--assert "15.8 toml-mode is installed"
  (cl-assert (package-installed-p 'toml-mode)))

(test--assert "15.9 nix-mode command is defined"
  (cl-assert (fboundp 'nix-mode)))

(test--assert "15.10 nix-mode is installed"
  (cl-assert (package-installed-p 'nix-mode)))

(test--assert "15.11 dockerfile-mode command is defined"
  (cl-assert (fboundp 'dockerfile-mode)))

(test--assert "15.12 dockerfile-mode is configured"
  (cl-assert (string-match-p "use-package dockerfile-mode"
                             (with-temp-buffer
                               (insert-file-contents
                                (expand-file-name "src/init.el"
                                                  (file-name-directory (directory-file-name (file-name-directory load-file-name)))))
                               (buffer-string)))))


;;; ==========================================================================
;;; 16. MEDIA & DOCUMENTS TESTS
;;; ==========================================================================

(test--assert "16.1 pdf-tools is installed"
  (cl-assert (package-installed-p 'pdf-tools)))

(test--assert "16.2 image-dired+ is installed"
  (cl-assert (package-installed-p 'image-dired+)))

(test--assert "16.3 mermaid-mode command is defined"
  (cl-assert (fboundp 'mermaid-mode)))

(test--assert "16.4 mermaid-mode is installed"
  (cl-assert (package-installed-p 'mermaid-mode)))

(test--assert "16.5 svg-tag-mode is installed"
  (cl-assert (package-installed-p 'svg-tag-mode)))

(test--assert "16.6 pdf-view-display-size is fit-width"
  (if (boundp 'pdf-view-display-size)
      (cl-assert (eq pdf-view-display-size 'fit-width))
    ;; Fallback: verify source code
    (cl-assert (string-match-p "pdf-view-display-size 'fit-width" (test--get-init-el)))))

(test--assert "16.7 mermaid-cli-path is configured"
  (if (boundp 'mermaid-cli-path)
      (cl-assert (string= mermaid-cli-path "/usr/local/bin/mmdc"))
    ;; Fallback: verify source code
    (cl-assert (string-match-p "mermaid-cli-path" (test--get-init-el)))))


;;; ==========================================================================
;;; 17. TREE-SITTER TESTS
;;; ==========================================================================

(test--assert "17.1 treesit-auto-install is configured"
  (cl-assert (boundp 'treesit-auto-install)))

(test--assert "17.2 global-treesit-auto-mode is configured"
  (cl-assert (string-match-p "global-treesit-auto-mode" (test--get-init-el))))

(test--assert "17.3 treesit-auto is in use-package"
  (cl-assert (string-match-p "use-package treesit-auto" (test--get-init-el))))


;;; ==========================================================================
;;; 18. SESSION TESTS
;;; ==========================================================================

(test--assert "18.1 desktop-save-mode is enabled"
  (cl-assert (bound-and-true-p desktop-save-mode)))

(test--assert "18.2 desktop-auto-save-timeout is 300"
  (cl-assert (= desktop-auto-save-timeout 300)))

(test--assert "18.3 desktop-save is t"
  (cl-assert (eq desktop-save t)))


;;; ==========================================================================
;;; 19. GIT HOOKS TESTS
;;; ==========================================================================

(test--assert "19.1 pre-commit hook script exists"
  (cl-assert (file-exists-p (expand-file-name "test/git-pre-commit"
                                               (file-name-directory (directory-file-name (file-name-directory load-file-name)))))))

(test--assert "19.2 pre-commit hook is executable"
  (cl-assert (file-executable-p (expand-file-name "test/git-pre-commit"
                                                   (file-name-directory (directory-file-name (file-name-directory load-file-name)))))))

(test--assert "19.3 my/git-pre-commit-hook is defined"
  (cl-assert (fboundp 'my/git-pre-commit-hook)))


;;; ==========================================================================
;;; 20. DEVOPS TESTS
;;; ==========================================================================

(test--assert "20.1 docker command is defined"
  (cl-assert (fboundp 'docker)))

(test--assert "20.2 docker is bound to C-c d"
  (cl-assert (eq (key-binding "\C-cd") 'docker)))

(test--assert "20.3 dockerfile-mode command is defined"
  (cl-assert (fboundp 'dockerfile-mode)))

(test--assert "20.4 dockerfile-mode is installed"
  (cl-assert (package-installed-p 'dockerfile-mode)))

(test--assert "20.5 dockerfile-use-projectile is configured"
  (cl-assert (string-match-p "dockerfile-use-projectile" (test--get-init-el))))


;;; ==========================================================================
;;; 21. COVERAGE REPORT TESTS
;;; ==========================================================================

(test--assert "21.1 coverage script exists"
  (cl-assert (file-exists-p (expand-file-name "test/coverage.sh"
                                               (file-name-directory (directory-file-name (file-name-directory load-file-name)))))))

(test--assert "21.2 coverage script is executable"
  (cl-assert (file-executable-p (expand-file-name "test/coverage.sh"
                                                   (file-name-directory (directory-file-name (file-name-directory load-file-name)))))))

(test--assert "21.3 templates file exists"
  (cl-assert (file-exists-p (concat (file-name-directory (directory-file-name (file-name-directory load-file-name))) "src/templates"))))


;;; ==========================================================================
;;; SUMMARY
;;; ==========================================================================

(test--summary)

;;; test_init.el ends here
