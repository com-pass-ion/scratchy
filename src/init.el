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
;;  21. Debug            — GDB (gud/gdb-mi, built-in)
;;

;;; Code:

;;; ==========================================================================
;;; 1. BOOTSTRAP — GC, package system, use-package
;;; ==========================================================================

;; Increase GC threshold to 16MB for faster startup.
;; Restored to a modest value after init so interactive use stays responsive.
(defvar gc-cons-threshold)
(setq gc-cons-threshold (* 8 1024 1024 2))
(add-hook 'emacs-startup-hook
	  (lambda ()
	    (setq gc-cons-threshold (* 2 1024 1024))))

;; --- Package system -------------------------------------------------------

(require 'package)
(package-initialize) ;; Initialize early to synchronize package state
(setq package-archives
      '(("nongnu" . "https://elpa.nongnu.org/nongnu/")   ;; nongnu ELPA
	("elpa"   . "https://elpa.gnu.org/packages/")     ;; GNU ELPA
	("melpa"  . "https://melpa.org/packages/")))      ;; MELPA

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

(defvar inhibit-startup-message)
(defvar inhibit-startup-screen)
(defvar inhibit-startup-echo-area-message)
(defvar use-file-dialog)
(setq inhibit-startup-message t
      inhibit-startup-screen t
      inhibit-startup-echo-area-message t
      use-file-dialog nil)

(defvar use-dialog-box)
(setq use-dialog-box nil)          ;; force yes-or-no to minibuffer echo area
(defvar use-short-answers)
(setq use-short-answers t)         ;; y/n instead of yes/no
(menu-bar-mode -1)       ;; no menu bar
(tool-bar-mode -1)       ;; no tool bar
(scroll-bar-mode -1)     ;; no scroll bar
(tab-bar-mode -1)        ;; no tab bar
(tooltip-mode -1)        ;; no tooltips

;; --- Font -----------------------------------------------------------------

(defvar default-face)
(set-face-attribute 'default nil
		    :font "Noto Sans Mono"
		    :weight 'normal
		    :height 145)

;; --- Transparency ---------------------------------------------------------

(defvar alpha-background)
(set-frame-parameter (selected-frame) 'alpha-background 90)
(defvar default-frame-alist)
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; --- Frame title -----------------------------------------------------------
;; Show buffer name and path in the frame title.

(defvar frame-title-format)
(setq frame-title-format
      '(:eval (if (buffer-file-name)
		  (abbreviate-file-name (buffer-file-name))
		"%b")))

;; --- Global Visual Line Mode -----------------------------------------------
(defvar global-visual-line-mode)
(global-visual-line-mode 1)

;; --- Fringe & Line Spacing ---------------------------------------------------
(defvar set-fringe-mode)
(set-fringe-mode '(12 . 0))      ;; left fringe 12px, right 0
(defvar line-spacing)
(setq-default line-spacing 0.15) ;; breathing room between lines

;; --- Bell -----------------------------------------------------------------
;; Visual bell flashes the mode-line instead of beeping.

(defvar visible-bell)
(setq visible-bell t)
(defvar ring-bell-function)
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

(use-package which-key
  :init (which-key-mode))

;; --- Persistent state across sessions -------------------------------------

(save-place-mode 1)

(use-package savehist
  :init (savehist-mode))

;; --- Recent files ---------------------------------------------------------
;; `C-x C-r' opens a list of recently opened files.

(use-package recentf
  :init (recentf-mode))

;; --- Which function -------------------------------------------------------
;; Display current function/block name in the mode-line.

(which-function-mode 1)

;; --- Whitespace cleanup ---------------------------------------------------
;; Remove trailing whitespace and normalize blank lines on save.

(defun cleanup-whitespace ()
  (whitespace-cleanup))

(add-hook 'before-save-hook #'cleanup-whitespace)

;; --- Delete selection mode --------------------------------------------------
;; Typing replaces the selected region (like modern editors).

(delete-selection-mode 1)

;; --- Narrowing enabled ----------------------------------------------------
;; Allow `C-x n n' (narrow-to-region) without confirmation.

(defvar narrow-to-region)
(put 'narrow-to-region 'disabled nil)

;; --- Visual Undo -----------------------------------------------------------
;; `C-c u' opens a visual undo tree. Navigate with arrow keys, RET to jump.

(defvar vundo-glyph-alist)
(defvar vundo-unicode-symbols)
(use-package vundo
  :commands vundo
  :config
  (setq vundo-glyph-alist vundo-unicode-symbols))

;; --- Window Switching ------------------------------------------------------
;; `M-o' shows numbers over each window. Type the number to jump there.

(use-package ace-window
  :bind ("M-o" . ace-window)
  :config

  (defvar aw-keys)
  (setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l)))


;;; ==========================================================================
;;; 4. THEME & VISUAL — Colors, line numbers, highlighting
;;; ==========================================================================

;; --- Theme ----------------------------------------------------------------
;; modus-vivendi is built-in. Colors are overridden to match Tokyo Night.

(defvar modus-themes-common-palette-overrides)
(setq modus-themes-common-palette-overrides
      '((bg-main  "#1a1b26")   ;; dark background
	(fg-main  "#c0caf5")   ;; light foreground
	(bg-region "#24283b")  ;; selection/region
	(cursor   "#7aa2f7"))) ;; blue cursor

(load-theme 'modus-vivendi t)

;; --- Line numbers ---------------------------------------------------------

(defvar column-number-mode)
(column-number-mode t)                ;; show column in mode-line
(defvar global-display-line-numbers-mode)
(global-display-line-numbers-mode t)  ;; enable line numbers everywhere

;; Disable line numbers in specific modes where they don't make sense.
(defun disable-line-numbers ()
  (display-line-numbers-mode 0))

(dolist (mode '(org-mode-hook
		term-mode-hook
		eshell-mode-hook
		shell-mode-hook))
  (add-hook mode #'disable-line-numbers))

;; --- Highlight current line ------------------------------------------------

(defvar hl-line-sticky-flag)
(global-hl-line-mode 1)
(setq hl-line-sticky-flag nil)
  ;; only highlight in active window

;; --- Paren matching -------------------------------------------------------

(defvar show-paren-mode)
(show-paren-mode 1)
(defvar show-paren-style)
(defvar show-paren-when-point-inside-paren)
(setq show-paren-style 'mixed
      show-paren-when-point-inside-paren t)

;; --- Electric pair ---------------------------------------------------------
;; Auto-close brackets, quotes, etc.

(defvar electric-pair-mode)
(electric-pair-mode 1)

;; --- Cursor ----------------------------------------------------------------

(defvar cursor-type)
(setq-default cursor-type 'bar)  ;; thin bar cursor
(defvar blink-cursor-mode)
(blink-cursor-mode -1)           ;; no blinking

;; --- Scrolling ------------------------------------------------------------

(defvar scroll-margin)
(defvar scroll-conservatively)
(defvar scroll-preserve-screen-position)
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

;; For terminal Emacs (non-GUI), corfu needs a backend that renders in the
;; same frame rather than a separate child frame.
(unless (display-graphic-p)
  (use-package corfu-terminal
    :ensure t
    :init (corfu-terminal-mode +1)))

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
  (defvar diff-hl-side)
  (defvar diff-hl-margin-mode)
  (setq diff-hl-side 'left)
  (setq diff-hl-margin-mode nil))


;; --- LSP — Eglot (built-in Language Server Protocol)
;; ==========================================================================

;; Eglot connects to language servers for code intelligence.
;; Servers: pyright (Python), clangd (C/C++), jdtls (Java), bash-ls.

(use-package eglot
  :hook ((python-mode . eglot-ensure)
         (c++-mode . eglot-ensure)
         (c-mode . eglot-ensure)
         (java-mode . eglot-ensure)
         (sh-mode . eglot-ensure))
  :config
  (defvar eglot-autoshutdown)
  (setq eglot-autoshutdown t)) ;; kill server when last buffer closes

;; --- Python (pyright) -----------------------------------------------------
;; Type checking in "basic" mode, run buffer with C-c C-c.

(defun eglot-setup-python ()
  (setq-local eglot-workspace-configuration
	          '((:pyright . (:typeCheckingMode "basic"))))
  (local-set-key (kbd "C-c C-c") 'python-shell-send-buffer))

(add-hook 'python-mode-hook #'eglot-setup-python)

;; --- C/C++ (clangd) -------------------------------------------------------
;; Compile flags come from the CMake-generated build/compile_commands.json,
;; not hardcoded fallback flags. A project `.clangd' points clangd at the
;; compile database (see doc/IMPLEMENTATION-STRATEGY.md).

;; --- Java (jdtls) ---------------------------------------------------------
;; Vanilla eglot — jdtls is auto-detected.

;; --- Bash (bash-language-server) ------------------------------------------

;; --- Flymake navigation (built-in) ----------------------------------------
;; M-n / M-p to jump between errors/warnings.

(with-eval-after-load 'flymake
  (defvar flymake-mode-map)
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
;; Templates loaded from ~/.emacs.d/templates (user-managed).
;; Usage: type snippet name, then M-+ (tempel-complete) or M-* (tempel-insert).

(use-package tempel
  :bind (("M-+" . tempel-complete)
         ("M-*" . tempel-insert))
  :init
  (defun tempel-setup-capf ()
    (setq-local completion-at-point-functions
                (cons #'tempel-expand completion-at-point-functions)))
  (add-hook 'prog-mode-hook 'tempel-setup-capf)
  (add-hook 'text-mode-hook 'tempel-setup-capf))

;; Community snippet collection (more IDE templates beyond our custom set).
;; Disabled: requires Emacs 31.1+
;; (use-package tempel-collection
;;   :ensure t
;;   :after tempel)


;;; ==========================================================================
;;; 11. TERMINAL — Eat (pure Elisp terminal emulator)
;;; ==========================================================================

;; Eat: lightweight terminal inside Emacs. `C-c t n' to open.

(use-package eat
  :commands eat
  :config
  (defvar eat-shell)
  (setq eat-shell "/bin/bash")
  (defvar eat-enable-auto-line-mode)
  (setq eat-enable-auto-line-mode t))

(define-key global-map (kbd "C-c t n") 'eat)


;;; ==========================================================================
;;; 12. PROJECT — Project.el + Templates
;;; ==========================================================================

;; --- Project.el: built-in project management (like projectile, but lighter).

(use-package project
  :config
  (defvar project-switch-commands)
  (setq project-switch-commands 'project-find-dir)
  (defvar project-list-files-gap)
  (setq project-list-files-gap 0))

;; --- C/C++ project adoption -----------------------------------------------
;; `M-x adopt-cpp-project' runs the repo's scaffold/adopt-cpp-project.sh
;; in the current directory to add only what's missing (build system if none
;; exists, .clangd, .gitignore, .clang-format unless --no-format).

(defvar repo-root
  (file-name-directory (directory-file-name (file-name-directory (or load-file-name buffer-file-name "."))))
  "Absolute path to the Scratchy repository root.")

(defun adopt-script-path ()
  (expand-file-name "scaffold/adopt-cpp-project.sh" repo-root))

(defun adopt-cpp-project ()
  "Adopt the current directory into the C/C++ workflow (confirmation first)."
  (interactive)
  (let ((dir default-directory)
        (script (adopt-script-path)))
    (unless (file-executable-p script)
      (error "adopt script not found or not executable: %s" script))
    (when (y-or-n-p (format "Adopt %s into the C/C++ workflow? " dir))
      (compile (concat script " " dir)))))


;;; ==========================================================================
;;; 13. BUILD & RUN — Language-specific compile commands
;;; ==========================================================================

;; --- C/C++ Formatting ---------------------------------------------------------
;; Formats with the nearest project `.clang-format' (`-style=file'), so legacy
;; code keeps its own style. No-op when clang-format is not installed or no
;; `.clang-format' is found above the file.

(defun clang-format-config-root (dir)
  "Return the nearest ancestor of DIR containing a `.clang-format' file.
DIR is expanded first. Returns nil when none is found."
  (let ((dir (file-name-as-directory (expand-file-name dir)))
	found)
    (while (and dir (not found))
      (if (file-exists-p (expand-file-name ".clang-format" dir))
	  (setq found dir)
	(let ((parent (file-name-directory (directory-file-name dir))))
	  (setq dir (unless (equal parent dir)
		      (file-name-as-directory parent))))))
    found))

(defun clang-format-buffer ()
  "Format the current C/C++ buffer with `clang-format' using `-style=file'.
Does nothing unless clang-format is installed and a `.clang-format' file is
found above `default-directory'."
  (interactive)
  (let ((exe (executable-find "clang-format"))
	(file (buffer-file-name)))
    (when (and exe file (clang-format-config-root default-directory))
      (let ((temp (generate-new-buffer " *clang-format*")))
	(unwind-protect
	    (let ((exit (call-process-region (point-min) (point-max)
					   exe nil temp
					   "-style=file" "-assume-filename"
					   file)))
	      (when (and (integerp exit) (zerop exit))
		(let ((pos (point))
		      (output (with-current-buffer temp (buffer-string))))
		  (delete-region (point-min) (point-max))
		  (insert output)
		  (goto-char (min pos (point-max))))))
	  (when (not exe)
	    (message "clang-format not found: please install it to enable format-on-save"))
	(kill-buffer temp))))))


;; --- Python ---------------------------------------------------------------

;; --- Bash -----------------------------------------------------------------

;; --- Unified run command --------------------------------------------------
;; `C-c l r' runs the file based on the current major mode.

(defvar compilation-scroll-output)
(setq compilation-scroll-output t)

(declare-function project-compile "project" ())

;; --- CLI-style command aliases -----------------------------------------------
;; These provide a "shell-like" interface via M-x, mirroring the project Makefile.

(defun make-build ()
  "Build the project using project-compile (default: make)."
  (interactive)
  (project-compile))

(defun make-run ()
  "Run the project using `make run'."
  (interactive)
  (compile "make run"))

(defun make-clean ()
  "Clean the project using `make clean'."
  (interactive)
  (compile "make clean"))

(defun make-format ()
  "Format the current C/C++ buffer with `clang-format'."
  (interactive)
  (clang-format-buffer))


;;; ==========================================================================
;;; 14. ORG-MODE — Babel integration, LaTeX, Mermaid
;;; ==========================================================================

;; --- Org-Mode ----------------------------------------------------------------

(use-package org
  :config
  (org-babel-do-load-languages 'org-babel-load-languages
                               '((emacs-lisp . t)
                                (python . t)
                                (C . t)
                                (java . t)
                                (shell . t)))

  (defvar org-confirm-babel-evaluate)
  (setq org-confirm-babel-evaluate nil)

  (defvar org-structure-template-alist)
  (setq org-structure-template-alist
        '(("el" . "src emacs-lisp")
          ("py" . "src python")
          ("sh" . "src shell")
          ("java" . "src java")
          ("c" . "src C"))))

;; --- LaTeX Support (cdlatex) -----------------------------------------------
;; Enable LaTeX editing and preview in Org-mode.

(use-package cdlatex
  :hook ((org-mode . org-cdlatex-mode))
  :config
  (defvar cdlatex-use-dollar-signs)
  (setq cdlatex-use-dollar-signs t))

;; Enable LaTeX fragment preview in Org-mode.
(add-hook 'org-mode-hook 'org-fold-show-all)

;; LaTeX export backend.
(with-eval-after-load 'ox-latex
  (defvar org-latex-packages-alist)
  (add-to-list 'org-latex-packages-alist '("" "listings" t))
  (defvar org-latex-src-block-backend)
  (setq org-latex-src-block-backend 'listings))


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
;; Arch-independent guard: checks several known libpoppler locations
;; (x86_64, aarch64) plus pkg-config, so RaspiOS works too.

(defun pdf-poppler-available-p ()
  "Non-nil when poppler dev libraries look installed."
  (or (file-exists-p "/usr/lib/x86_64-linux-gnu/libpoppler-glib.so")
      (file-exists-p "/usr/lib/aarch64-linux-gnu/libpoppler-glib.so")
      (file-exists-p "/usr/lib/libpoppler-glib.so")
      (and (executable-find "pkg-config")
	   (zerop (call-process "pkg-config" nil nil nil
				"--exists" "poppler-glib")))))

(defun pdf-server-built-p ()
  "Non-nil when the pdf-tools epdfinfo server is already compiled."
  (ignore-errors
    (let ((lib (locate-library "pdf-tools")))
      (and lib
	   (file-exists-p (expand-file-name "build/server/epdfinfo"
					    (file-name-directory lib)))))))

(use-package pdf-tools
  :if (pdf-poppler-available-p)
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :config
  (declare-function pdf-tools-install "pdf-tools" (&optional noupdate))
  (defvar pdf-view-display-size)
  (defvar pdf-view-resize-factor)
  ;; One-shot server install: skip when already compiled.
  (unless (pdf-server-built-p)
    (pdf-tools-install))
  (setq pdf-view-display-size 'fit-width)
  (setq pdf-view-resize-factor 1.1))

;; --- Image Dired+ (better thumbnails) ------------------------------------
;; Enhanced image-dired with better thumbnail management.

(use-package image-dired+
  :ensure t
  :after image-dired
  :config
  (defvar image-dired-thumb-size)
  (defvar image-dired-thumb-margin)
  (defvar image-dired-thumb-relief)
  (setq image-dired-thumb-size 150)
  (setq image-dired-thumb-margin 10)
  (setq image-dired-thumb-relief 3))

;; --- Mermaid Mode ---------------------------------------------------------
;; Edit and preview Mermaid diagrams.
;; mmdc location varies (npm -g bin); `executable-find' covers
;; /usr/local/bin, /usr/bin, ~/.npm-global/bin via PATH.

(use-package mermaid-mode
  :mode ("\\.mmd\\'" . mermaid-mode)
  :config
  (defvar mermaid-cli-path)
  (setq mermaid-cli-path (or (executable-find "mmdc")
			     "/usr/local/bin/mmdc")))

;; --- SVG Tag Mode ---------------------------------------------------------
;; Render SVG images inline in Org-Mode.

(use-package svg-tag-mode
  :hook (org-mode . svg-tag-mode)
  :config
  (defvar svg-tag-tags)
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
  (defvar treesit-auto-install)
  (setq treesit-auto-install 'prompt)
  ;; Use funcall to silence "might not be defined at runtime" byte-compile warning
  (condition-case nil
      (funcall (symbol-function 'global-treesit-auto-mode))
    (error nil)))


;;; ==========================================================================
;;; 18. SESSION — Desktop Save
;;; ==========================================================================

;; --- Session — Desktop Save
;; ==========================================================================

(defvar frameset-filter-alist)
(push '(menu-bar-lines  . :never) frameset-filter-alist)
(push '(tool-bar-lines  . :never) frameset-filter-alist)
(push '(tab-bar-lines   . :never) frameset-filter-alist)
(push '(font             . :never) frameset-filter-alist)
(push '(alpha            . :never) frameset-filter-alist)
(push '(alpha-background . :never) frameset-filter-alist)
(push '(fullscreen       . :never) frameset-filter-alist)

(unless noninteractive
  (desktop-save-mode 1))

(defvar desktop-save)
(setq desktop-save 'ask)
(defvar desktop-auto-save-timeout)
(setq desktop-auto-save-timeout nil)
(defvar desktop-path)
(setq desktop-path '("."))
(defvar desktop-base-file-name)
(setq desktop-base-file-name ".desktop")
(defvar desktop-base-lock-name)
(setq desktop-base-lock-name ".desktop.lock")
(defvar desktop-restore-eager)
(setq desktop-restore-eager 10)
(defvar desktop-load-locked-desktop)
(setq desktop-load-locked-desktop nil)


;;; ==========================================================================
;;; 19. GIT HOOKS — Pre-commit
;;; ==========================================================================

;; Run tests before each commit via git hook.
;; Nil-safe: no-op outside a project or without the test runner.

(declare-function project-root "project" (project))
(declare-function project-current "project" (&optional maybe-prompt))

(defun git-pre-commit-hook ()
  "Run tests before git commit."
  (let* ((proj (ignore-errors (project-current)))
	 (root (when proj (ignore-errors (project-root proj))))
	 (default-directory (or root default-directory)))
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
  :bind ("C-c d" . docker))

(use-package dockerfile-mode
  :mode "Dockerfile\\'")


;;; ==========================================================================
;;; 21. DEBUG — GDB (gud/gdb-mi, built-in only)
;;; ==========================================================================

;; Standard `M-x gdb' (gud/gdb-mi). Build with `C-c l b' (make) and launch
;; `M-x gdb' on the binary under build/. Type GDB's built-in abbreviations in
;; the console (n/s/c/b/p/bt, rn/rs/rc). No custom launcher or keybindings.
;; Pretty-printing/safe-path defaults live in the default `.gdbinit' shipped
;; in dotfiles/ (symlinked to ~/.gdbinit by the installer); see
;; doc/IMPLEMENTATION-STRATEGY.md.

;; --- Layout (applied before M-x gdb) ---------------------------------------

(with-eval-after-load 'gdb-mi
  (defvar gdb-many-windows)
  (defvar gdb-show-main)
  (setq gdb-many-windows t   ;; source + stack + locals + breakpoints + IO
	gdb-show-main t))    ;; show main source on startup

;; --- Tooltips with dereferenced values -------------------------------------

(with-eval-after-load 'gud
  (add-hook 'gdb-mode-hook #'gud-tooltip-mode))


;;; ==========================================================================
;;; FOOTER
;;; ==========================================================================

(provide 'init)
;;; init.el ends here
