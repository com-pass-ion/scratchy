;;; init.el --- Emacs from scratch                   -*- lexical-binding: t; -*-

;; Copyright (C) 2026
;; Author:  njh

;;; Commentary:
;;
;; Minimal, Emacs-native IDE config.
;; Zero external C dependencies — LSP via built-in eglot.
;; Packages: only MELPA/ELPA/nongnu, managed via use-package.
;;
;; Structure:
;;   1. Bootstrap        — GC, package system, use-package
;;   2. Frame & UI       — No chrome, font, transparency, bell, frame title
;;   3. Comfort          — Built-in quality-of-life, vundo, ace-window, delete-selection
;;   4. Theme & Visual   — Colors, line numbers, highlighting
;;   5. Completion       — Vertico, Orderless, Corfu, Cape
;;   6. Search           — Consult
;;   7. Help             — Helpful
;;   8. Git              — Magit, diff-hl
;;   9. LSP              — Eglot (Python, C/C++, Java, Bash)
;;  10. Snippets         — Tempel templates
;;  11. Terminal         — Eat
;;  12. Project          — Project.el, templates
;;  13. Build & Run      — Language-specific compile commands
;;  14. Org-Mode         — Babel integration
;;  15. Language Modes   — markdown, yaml, json, toml, nix, dockerfile
;;  16. Media & Documents — PDF, images, mermaid, SVG
;;  17. Tree-sitter      — Better syntax highlighting
;;  18. Session          — Desktop save
;;  19. Git Hooks        — Pre-commit
;;  20. DevOps           — Docker
;;

;;; Code:

;;; ==========================================================================
;;; 1. BOOTSTRAP — GC, package system, use-package
;;; ==========================================================================

;; Increase GC threshold to 16MB for faster startup.
;; Normal threshold is restored after init via `startup-friendly-gc'.
(setq gc-cons-threshold (* 8 1024 1024 2))

;; --- Package system -------------------------------------------------------

(require 'package)
(setq package-archives
      '(("nongnu" . "https://elpa.nongnu.org/nongnu/")   ;; nongnu ELPA
	("elpa"   . "https://elpa.gnu.org/packages/")     ;; GNU ELPA
	("melpa"  . "https://melpa.org/packages/")))      ;; MELPA
(package-initialize)

;; Bootstrap use-package if not installed.
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)  ;; auto-install missing packages


;;; ==========================================================================
;;; 2. FRAME & UI — No chrome, font, transparency, bell
;;; ==========================================================================

;; --- Disable UI chrome ----------------------------------------------------

(setq inhibit-startup-message t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t
      use-file-dialog nil)

(menu-bar-mode -1)       ;; no menu bar
(tool-bar-mode -1)       ;; no tool bar
(scroll-bar-mode -1)     ;; no scroll bar
(tooltip-mode -1)        ;; no tooltips

;; --- Font -----------------------------------------------------------------

(set-face-attribute 'default nil
		    :font "Noto Sans Mono"
		    :weight 'normal
		    :height 145)

;; --- Transparency ---------------------------------------------------------

(set-frame-parameter (selected-frame) 'alpha-background 90)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; --- Frame title -----------------------------------------------------------
;; Show buffer name and path in the frame title.

(setq frame-title-format
      '(:eval (if (buffer-file-name)
		  (abbreviate-file-name (buffer-file-name))
		"%b")))

;; --- Visual comfort -------------------------------------------------------

(global-visual-line-mode 1)      ;; soft line wrap (no hard wrap)
(set-fringe-mode '(12 . 0))      ;; left fringe 12px, right 0
(setq-default line-spacing 0.15) ;; breathing room between lines

;; --- Bell -----------------------------------------------------------------
;; Visual bell flashes the mode-line instead of beeping.

(setq visible-bell t)
(setq ring-bell-function
      (lambda ()
	(let ((orig-bg (face-background 'mode-line)))
	  (set-face-background 'mode-line "#3b4261")
	  (run-with-idle-timer 0.1 nil
			      (lambda (bg) (set-face-background 'mode-line bg))
			      orig-bg))))


;;; ==========================================================================
;;; 3. COMFORT — Built-in quality-of-life features
;;; ==========================================================================

;; --- Keybinding discoverability -------------------------------------------
;; Shows available keys after a prefix in a popup.

(which-key-mode)

;; --- Persistent state across sessions -------------------------------------

(save-place-mode)    ;; remember cursor position per file
(savehist-mode)      ;; persist minibuffer history (M-x, etc.)

;; --- Recent files ---------------------------------------------------------
;; `C-x C-r' opens a list of recently opened files.

(recentf-mode)
(setq recentf-max-saved-items 100)
(global-set-key (kbd "C-x C-r") 'recentf-open-files)

;; --- Which function -------------------------------------------------------
;; Display current function/block name in the mode-line.

(which-function-mode)

;; --- Whitespace cleanup ---------------------------------------------------
;; Remove trailing whitespace and normalize blank lines on save.

(add-hook 'before-save-hook 'whitespace-cleanup)

;; --- Delete selection mode --------------------------------------------------
;; Typing replaces the selected region (like modern editors).

(delete-selection-mode 1)

;; --- Narrowing enabled ----------------------------------------------------
;; Allow `C-x n n' (narrow-to-region) without confirmation.

(put 'narrow-to-region 'disabled nil)

;; --- Visual Undo -----------------------------------------------------------
;; `C-c u' opens a visual undo tree. Navigate with arrow keys, RET to jump.

(use-package vundo
  :commands vundo
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols))

;; --- Window Switching ------------------------------------------------------
;; `M-o' shows numbers over each window. Type the number to jump there.

(use-package ace-window
  :bind ("M-o" . ace-window)
  :config
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))


;;; ==========================================================================
;;; 4. THEME & VISUAL — Colors, line numbers, highlighting
;;; ==========================================================================

;; --- Theme ----------------------------------------------------------------
;; modus-vivendi is built-in. Colors are overridden to match Tokyo Night.

(setq modus-themes-common-palette-overrides
      '((bg-main  "#1a1b26")   ;; dark background
	(fg-main  "#c0caf5")   ;; light foreground
	(bg-region "#24283b")  ;; selection/region
	(cursor   "#7aa2f7"))) ;; blue cursor

(load-theme 'modus-vivendi t)

;; --- Line numbers ---------------------------------------------------------

(column-number-mode t)                ;; show column in mode-line
(global-display-line-numbers-mode t)  ;; enable line numbers everywhere

;; Disable line numbers in specific modes where they don't make sense.
(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook
		shell-mode-hook))
  (add-hook mode (lambda () (display-line-numbers-mode 0))))

;; --- Highlight current line ------------------------------------------------

(global-hl-line-mode 1)
(setq hl-line-sticky-flag nil)  ;; only highlight in active window

;; --- Paren matching -------------------------------------------------------

(show-paren-mode 1)
(setq show-paren-style 'mixed
      show-paren-when-point-inside-paren t)

;; --- Electric pair ---------------------------------------------------------
;; Auto-close brackets, quotes, etc.

(electric-pair-mode 1)

;; --- Cursor ----------------------------------------------------------------

(setq-default cursor-type 'bar)  ;; thin bar cursor
(blink-cursor-mode -1)           ;; no blinking

;; --- Scrolling ------------------------------------------------------------

(setq scroll-margin 3
      scroll-conservatively 101
      scroll-preserve-screen-position t)


;;; ==========================================================================
;;; 5. COMPLETION — Vertico + Orderless + Marginalia + Corfu + Cape
;;; ==========================================================================

;; --- Minibuffer completion (Vertico) -------------------------------------
;; Vertical minibuffer for M-x, C-x C-f, C-x b, etc.

(use-package vertico
  :init (vertico-mode))

;; --- Matching (Orderless) ------------------------------------------------
;; Type any order: "mrg" matches "magit-status".

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles partial-completion)))))

;; --- Annotations (Marginalia) --------------------------------------------
;; Shows extra info (file size, permissions, etc.) in minibuffer.

(use-package marginalia
  :bind (:map minibuffer-local-map
	 ("M-A" . marginalia-cycle))
  :init (marginalia-mode))

;; --- In-buffer completion (Corfu) ----------------------------------------
;; Popup completion at point (like VS Code autocomplete).

(use-package corfu
  :custom
  (corfu-auto t)            ;; auto-popup
  (corfu-auto-delay 0.1)    ;; show after 100ms
  (corfu-auto-prefix 1)     ;; start after 1 char
  :init (global-corfu-mode))

;; --- Completion backends (Cape) ------------------------------------------
;; Adds more completion sources to completion-at-point.

(use-package cape
  :init
  ;; dabbrev: complete from other buffers
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  ;; file: complete file paths
  (add-hook 'completion-at-point-functions #'cape-file)
  ;; keyword: complete language keywords
  (add-hook 'completion-at-point-functions #'cape-keyword)
  ;; elisp: complete elisp symbols
  (add-hook 'emacs-lisp-mode-hook
	    (lambda ()
	      (add-hook 'completion-at-point-functions #'cape-elisp-block nil t))))


;;; ==========================================================================
;;; 6. SEARCH — Consult
;;; ==========================================================================

;; Consult provides enhanced search/navigation commands.

(use-package consult
  :bind (;; C-s: search in current buffer (like isearch, but better)
	 ("C-s" . consult-line)
	 ;; C-x b: switch buffer (with preview)
	 ("C-x b" . consult-buffer)
	 ;; C-x r b: jump to bookmark
	 ("C-x r b" . consult-bookmark)
	 ;; M-s r: ripgrep search across project
	 ("M-s r" . consult-ripgrep)
	 ;; M-y: browse kill ring (paste history)
	 ("M-y" . consult-yank-pop)
	 ;; C-r in minibuffer: search command history
	 :map minibuffer-local-map
	 ("C-r" . consult-history)))


;;; ==========================================================================
;;; 7. HELP — Helpful
;;; ==========================================================================

;; Helpful replaces *Help* buffer with a more informative version.

(use-package helpful
  :ensure t
  :custom
  (helpful-switch-buffer-function #'helpful--switch-buffer)
  :bind
  ;; Override default describe-* commands with helpful versions.
  ([remap describe-function] . helpful-callable)
  ([remap describe-command]   . helpful-command)
  ([remap describe-variable]  . helpful-variable)
  ([remap describe-key]       . helpful-key)
  ([remap describe-symbol]    . helpful-symbol))


;;; ==========================================================================
;;; 8. GIT — Magit
;;; ==========================================================================

;; Magit: the git interface. `M-x magit-status' or `C-x g'.

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  ;; Open magit in the current window, not a new one.
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

;; --- Git Gutter (diff-hl) -------------------------------------------------
;; Shows added/modified/deleted lines in the fringe (green/red/blue marks).
;; C-x v = to diff, C-x v n/p to jump between changes.

(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
	 (magit-post-refresh . diff-hl-magit-post-refresh))
  :config
  (setq diff-hl-side 'left)
  (setq diff-hl-margin-mode nil))


;;; ==========================================================================
;;; 9. LSP — Eglot (built-in Language Server Protocol)
;;; ==========================================================================

;; Eglot connects to language servers for code intelligence.
;; Servers: pyright (Python), clangd (C/C++), jdtls (Java), bash-ls.

(setq eglot-autoshutdown t)  ;; kill server when last buffer closes

;; --- Python (pyright) -----------------------------------------------------
;; Type checking in "basic" mode, run buffer with C-c C-c.

(add-hook 'python-mode-hook
	  (lambda ()
	    (setq-local eglot-workspace-configuration
			'((:pyright . (:typeCheckingMode "basic"))))
	    (local-set-key (kbd "C-c C-c") 'python-shell-send-buffer)
	    (eglot-ensure)))

;; --- C++ (clangd) ---------------------------------------------------------

(add-hook 'c++-mode-hook
	  (lambda ()
	    (setq-local eglot-workspace-configuration
			'(:clangd (:fallbackFlags ["-std=c++17"])))
	    (eglot-ensure)))

;; --- C (clangd) -----------------------------------------------------------

(add-hook 'c-mode-hook
	  (lambda ()
	    (setq-local eglot-workspace-configuration
			'(:clangd (:fallbackFlags ["-std=c11"])))
	    (eglot-ensure)))

;; --- Java (jdtls) ---------------------------------------------------------
;; Vanilla eglot — jdtls is auto-detected.

(add-hook 'java-mode-hook 'eglot-ensure)

;; --- Bash (bash-language-server) ------------------------------------------

(add-hook 'sh-mode-hook 'eglot-ensure)

;; --- Flymake navigation (built-in) ----------------------------------------
;; M-n / M-p to jump between errors/warnings.

(with-eval-after-load 'flymake
  (define-key flymake-mode-map (kbd "M-n") 'flymake-goto-next-error)
  (define-key flymake-mode-map (kbd "M-p") 'flymake-goto-prev-error)

  ;; --- Flymake error faces ---------------------------------------------------
  ;; Distinct colors for errors vs warnings in the fringe and underlines.
  (set-face-attribute 'flymake-error nil
		      :underline '(:style wave :color "ff6b6b")
		      :foreground "ff6b6b")
  (set-face-attribute 'flymake-warning nil
		      :underline '(:style wave :color "e0af68")
		      :foreground "e0af68"))


;;; ==========================================================================
;;; 10. SNIPPETS — Tempel (modern templates)
;;; ==========================================================================

;; Tempel provides lightweight template expansion with full Elisp support.
;; Templates defined in ~/.emacs.d/templates (single file).
;; Usage: type snippet name, then M-+ (tempel-complete) or M-* (tempel-insert).

(use-package tempel
  :bind (("M-+" . tempel-complete)
         ("M-*" . tempel-insert))
  :init
  (setq tempel-path (expand-file-name "templates" (file-name-directory load-file-name)))
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions
                (cons #'tempel-expand completion-at-point-functions)))
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

;; Community snippet collection (more IDE templates beyond our custom set).

(use-package tempel-collection
  :ensure t
  :after tempel)


;;; ==========================================================================
;;; 11. TERMINAL — Eat (pure Elisp terminal emulator)
;;; ==========================================================================

;; Eat: lightweight terminal inside Emacs. `C-c t n' to open.

(use-package eat
  :ensure t
  :commands eat
  :config
  (setq eat-shell "/bin/bash"))

(define-key global-map (kbd "C-c t n") 'eat)


;;; ==========================================================================
;;; 12. PROJECT — Project.el + Templates
;;; ==========================================================================

;; Project.el: built-in project management (like projectile, but lighter).

(setq project-switch-commands 'project-find-dir)
(setq project-list-files-gap 0)

;; --- New project scaffolding ----------------------------------------------
;; `M-x my/project-new' creates a C++ or Python project in ~/Projects/
;; with Git init, .gitignore, and appropriate boilerplate.

(defun my/project-new ()
  "Create a new C++ or Python project with Git and Venv integration."
  (interactive)
  (let* ((lang (completing-read "Language: " '("cpp" "python")))
	 (name (read-string "Project Name: "))
	 (proj-root (expand-file-name (concat "~/Projects/" name))))
    (if (file-exists-p proj-root)
	(error "Project directory already exists!")
      (progn
	(make-directory proj-root t)

	;; Create marker file for project.el detection.
	(with-current-buffer (find-file-noselect (expand-file-name ".projectile" proj-root))
	  (insert "")
	  (save-buffer))

	(cond
	 ;; --- C++ project ------------------------------------------------
	 ((string= lang "cpp")
	  (let ((src-dir (expand-file-name "src" proj-root)))
	    (make-directory src-dir t)

	    ;; main.cpp with hello world.
	    (with-current-buffer (find-file-noselect (expand-file-name "main.cpp" src-dir))
	      (insert "#include <iostream>\n\nint main() {\n    std::cout << \"Hello from new Project!\" << std::endl;\n    return 0;\n}\n")
	      (save-buffer))

	    ;; CMakeLists.txt for C++17 build.
	    (with-current-buffer (find-file-noselect (expand-file-name "CMakeLists.txt" proj-root))
	      (insert (format "cmake_minimum_required(VERSION 3.10)\nproject(%s)\nset(CMAKE_CXX_STANDARD 17)\nadd_executable(${PROJECT_NAME} src/main.cpp)\n" name))
	      (save-buffer))

	    ;; .gitignore for build artifacts.
	    (with-current-buffer (find-file-noselect (expand-file-name ".gitignore" proj-root))
	      (insert "build/\n")
	      (save-buffer))

	    (find-file (expand-file-name "main.cpp" src-dir))))

	 ;; --- Python project ---------------------------------------------
	 ((string= lang "python")
	  (let ((main-py (expand-file-name "main.py" proj-root)))

	    ;; main.py with boilerplate.
	    (with-current-buffer (find-file-noselect main-py)
	      (insert "def main():\n    print('Hello from new Project!')\n\nif __name__ == '__main__':\n    main()\n")
	      (save-buffer))

	    ;; .gitignore for Python.
	    (with-current-buffer (find-file-noselect (expand-file-name ".gitignore" proj-root))
	      (insert ".venv/\n__pycache__/\n*.py[cod]\n")
	      (save-buffer))

	    ;; Create virtualenv.
	    (shell-command (format "python3 -m venv %s/.venv" proj-root))

	    (find-file main-py))))

	;; Git init + initial commit.
	(require 'magit)
	(let ((default-directory proj-root))
	  (magit-init)
	  (magit-stage-all)
	  (magit-commit "Initial commit"))

	(message "Project %s created successfully!" name)))))


;;; ==========================================================================
;;; 13. BUILD & RUN — Language-specific compile commands
;;; ==========================================================================

;; --- C++ (CMake) ----------------------------------------------------------

(defun my/cpp-build ()
  "Build the current C++ project using CMake."
  (interactive)
  (let ((root (project-project-root)))
    (if root
	(let ((build-cmd (format "cmake -S %s -B %s/build && cmake --build %s/build" root root root)))
	  (compile build-cmd))
      (message "No project root found!"))))

(defun my/cpp-run ()
  "Build and run the current C++ project using CMake."
  (interactive)
  (let ((root (project-project-root)))
    (if root
	(let* ((build-dir (expand-file-name "build" root))
	       (files (when (file-exists-p build-dir)
			 (directory-files build-dir t "^[a-zA-Z0-9_-]+$")))
	       (binary (when files (car files)))
	       (run-cmd (if binary
			    (format "cmake -S %s -B %s/build && cmake --build %s/build && %s"
				    root root root (expand-file-name binary build-dir))
			  (format "cmake -S %s -B %s/build && cmake --build %s/build" root root root))))
	  (compile run-cmd))
      (message "No project root found!"))))

;; --- Python ---------------------------------------------------------------

(defun my/python-run ()
  "Run the current Python script."
  (interactive)
  (let ((file (buffer-file-name)))
    (if file
	(compile (concat "python3 " (shell-quote-argument file)))
      (message "No file to run!"))))

;; --- Bash -----------------------------------------------------------------

(defun my/bash-run ()
  "Run the current bash script."
  (interactive)
  (let ((file (buffer-file-name)))
    (if file
	(compile (concat "bash " file))
      (message "No file to run!"))))

;; --- Unified run command --------------------------------------------------
;; `C-c l r' runs the file based on the current major mode.

(defun my/run ()
  "Run file based on current mode."
  (interactive)
  (cond
   ((derived-mode-p 'c++-mode)   (my/cpp-run))
   ((derived-mode-p 'c-mode)     (my/cpp-run))
   ((derived-mode-p 'python-mode) (my/python-run))
   ((derived-mode-p 'sh-mode)    (my/bash-run))
   ((derived-mode-p 'emacs-lisp-mode) (eval-buffer))
   (t (message "No supported run mode!"))))

(define-key global-map (kbd "C-c l r") 'my/run)
(define-key global-map (kbd "C-c l b") 'my/cpp-build)

;; Auto-scroll compile output buffer.
(setq compilation-scroll-output t)

;; --- Compilation keybindings -----------------------------------------------
;; Quick access to compilation from any buffer.

(global-set-key (kbd "C-c l c") 'compile)
(global-set-key (kbd "C-c l k") 'kill-compilation)
(global-set-key (kbd "C-c l n") 'next-error)
(global-set-key (kbd "C-c l p") 'previous-error)


;;; ==========================================================================
;;; 14. ORG-MODE — Babel integration
;;; ==========================================================================

;; Enable shell code blocks in Org files.
(org-babel-do-load-languages 'org-babel-load-languages '((shell . t)))


;;; ==========================================================================
;;; 15. LANGUAGE MODES — Config file support
;;; ==========================================================================

;; Markdown mode
(use-package markdown-mode
  :mode ("README\\.md\\'" . markdown-mode)
  :config
  (setq markdown-fontify-whole-heading-line t))

;; YAML mode
(use-package yaml-mode
  :mode ("\\.ya?ml\\'" . yaml-mode))

;; JSON mode
(use-package json-mode
  :mode ("\\.json\\'" . json-mode))

;; TOML mode
(use-package toml-mode
  :mode ("\\.toml\\'" . toml-mode))

;; Nix mode
(use-package nix-mode
  :mode ("\\.nix\\'" . nix-mode)
  :hook ((nix-mode . eglot-ensure)))


;;; ==========================================================================
;;; 16. MEDIA & DOCUMENTS — PDF, Images, Mermaid, SVG
;;; ==========================================================================

;; --- PDF Tools (pdf-tools) ------------------------------------------------
;; View, annotate, and search PDFs inside Emacs.
;; Requires: sudo apt install libpoppler-glib-dev libpoppler-private-dev

(use-package pdf-tools
  :if (file-exists-p "/usr/lib/x86_64-linux-gnu/libpoppler-glib.so")
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (pdf-tools-install)
  (setq pdf-view-display-size 'fit-width)
  (setq pdf-view-resize-factor 1.1))

;; --- Image Dired+ (better thumbnails) ------------------------------------
;; Enhanced image-dired with better thumbnail management.

(use-package image-dired+
  :ensure t
  :after image-dired
  :config
  (setq image-dired-thumb-size 150)
  (setq image-dired-thumb-margin 10)
  (setq image-dired-thumb-relief 3))

;; --- Mermaid Mode ---------------------------------------------------------
;; Edit and preview Mermaid diagrams.

(use-package mermaid-mode
  :mode ("\\.mmd\\'" . mermaid-mode)
  :config
  (setq mermaid-cli-path "/usr/local/bin/mmdc"))

;; --- SVG Tag Mode ---------------------------------------------------------
;; Render SVG images inline in Org-Mode.

(use-package svg-tag-mode
  :hook (org-mode . svg-tag-mode)
  :config
  (setq svg-tag-tags
        '(("info" . "◉")
          ("warning" . "⚠")
          ("error" . "✕"))))


;;; ==========================================================================
;;; 17. TREE-SITTER — Better syntax highlighting
;;; ==========================================================================

;; Tree-sitter provides incremental parsing for better syntax highlighting.
;; Built-in in Emacs 29+. Requires language grammars in ~/.emacs.d/tree-sitter/.

(use-package treesit-auto
  :config
  (setq treesit-auto-install 'prompt)
  (global-treesit-auto-mode))


;;; ==========================================================================
;;; 18. SESSION — Desktop Save
;;; ==========================================================================

;; Save and restore sessions (files, buffers, windows) across restarts.

(desktop-save-mode 1)
(setq desktop-auto-save-timeout 300)  ;; auto-save every 5 minutes
(setq desktop-dirname user-emacs-directory)
(setq desktop-base-file-name ".desktop")
(setq desktop-base-lock-name ".desktop.lock")
(setq desktop-save t)  ;; save without asking


;;; ==========================================================================
;;; 19. GIT HOOKS — Pre-commit
;;; ==========================================================================

;; Run tests before each commit via git hook.

(defun my/git-pre-commit-hook ()
  "Run tests before git commit."
  (let ((default-directory (project-root (project-current))))
    (when (file-exists-p "test/run_tests.sh")
      (message "Running pre-commit tests...")
      (if (zerop (call-process "bash" nil nil nil "test/run_tests.sh"))
          (message "Pre-commit tests passed!")
        (error "Pre-commit tests failed! Commit aborted.")))))

;; Note: To activate, symlink or copy to .git/hooks/pre-commit:
;;   ln -sf ../../test/git-pre-commit .git/hooks/pre-commit


;;; ==========================================================================
;;; 20. DEVOPS — Docker
;;; ==========================================================================

;; Docker container management via docker.el.

(use-package docker
  :ensure t
  :bind ("C-c d" . docker))

(use-package dockerfile-mode
  :mode "Dockerfile\\'"
  :config
  (setq dockerfile-use-projectile t))


;;; ==========================================================================
;;; FOOTER
;;; ==========================================================================

(provide 'init)
;;; init.el ends here
