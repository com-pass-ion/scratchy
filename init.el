;;; init.el --- emacs from scratch                   -*- lexical-binding: t; -*-

;; Copyright (C) 2026

;; Author:  njh
;; Keywords: emacs from scratch

;;; Commentary:
;;; -> demoing config capabilities


;;; Code:

;;; GUI Tweeks:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq gc-cons-threshold (* 8 1024 1024 2))  ;; for quicker startup
(setq inhibit-startup-message t)
(menu-bar-mode -1)
(tool-bar-mode -1)
(global-visual-line-mode 1)
(scroll-bar-mode -1)
(electric-pair-mode 1)
(show-paren-mode 1)
(tooltip-mode -1)  ;; help texts in echo area: -1
(set-fringe-mode '(12 . 0))  ;; fringe: non-writable part of frame (left/right...)
(set-face-attribute 'default nil
					:font "Hack"
					:weight 'normal
					:height 109)  ;; sudo apt install fonts-hack
;; (nerd-icons-install-fonts) ;; installs missing fonts


;; BELL
(setq visible-bell t)
(setq ring-bell-function
      (lambda ()
        (let ((orig-bg (face-background 'mode-line)))
          (set-face-background 'mode-line "#26AE60")
          (run-with-idle-timer 0.1 nil
                               (lambda (bg) (set-face-background 'mode-line bg))
                               orig-bg))))

;;(beep)  ;; rings the bell

;; LINE NUMBERS
(column-number-mode t)
(global-display-line-numbers-mode t)
;; Disable line numbers for some modes
(dolist (mode '(org-mode-hook
				term-mode-hook
				eshell-mode-hook
				shell-mode-hook))
  (add-hook mode (lambda() (display-line-numbers-mode 0))))



;; enabling dangerous features
(put 'narrow-to-region 'disabled nil)

;;; PACKAGES:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Initialize package sources
(require 'package)
(setq package-archives '(("melpa" . "https://melpa.org/packages/")
						 ("org" . "https://orgmode.org/elpa/")
						 ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)

;; For first Use:
(unless package-archive-contents
  (package-refresh-contents))


;; Initialize use-package on non-linux platforms
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; activate + C-c o for window
(use-package command-log-mode
  :diminish)

(use-package ivy
  :diminish  ;; keeps ivy from mode list
  :ensure t
  :bind (("C-s". swiper)
		 ;; :map ivy-minibuffer-map
		 ;; ;;("TAB" . ivy-alt-done)
		 ;; ("C-l" . ivy-alt-done)
		 ;; ("C-j" . ivy-next-line)
		 ;; ("C-k" . ivy-previous-line)
		 ;; :map ivy-switch-buffer-map
		 ;; ("C-k" . ivy-previos-line)
		 ;; ("C-l" . ivy-done)
		 ;; ("C-d" . ivy-switch-buffer-kill)
		 ;; :map ivy-reverse-i-search-map
		 ;; ("C-k" . ivy-previous-line)
		 ;; ("C-d" . ivy-reverse-i-search-kill)
		 )
  :config
  (ivy-mode 1))


(use-package counsel
  :bind (("M-x" . counsel-M-x)
		 ("C-x b" . counsel-ibuffer)
		 ("C-x C-f" . counsel-find-file)
		 :map minibuffer-local-map
		 ("C-r" . 'counsel-minibuffer-history))
  :config (setq ivy-initial-inputs-alist nil))

;; M-x M-o for quicker help

(use-package helpful
  :ensure t
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package ivy-rich
  :init
  (ivy-rich-mode t))

(use-package doom-themes)
(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))


(load-theme 'doom-palenight t)

;;  "fuzzy matching" in buffer
(use-package swiper
  :ensure t)

;; Colors corresponding parenthesises
(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))

;; Shows available following keys to keybinding like C-x
(use-package which-key
  :ensure t
  :init (which-key-mode)
  :diminish which-key-mode
  :config (setq which-key-idle-delay 0.5))

(use-package eglot-java)
(add-hook 'java-mode-hook 'eglot-java-mode)

(with-eval-after-load 'eglot-java
  (define-key eglot-java-mode-map (kbd "C-c l n") #'eglot-java-file-new)
  (define-key eglot-java-mode-map (kbd "C-c l x") #'eglot-java-run-main)
  (define-key eglot-java-mode-map (kbd "C-c l t") #'eglot-java-run-test)
  (define-key eglot-java-mode-map (kbd "C-c l N") #'eglot-java-project-new)
  (define-key eglot-java-mode-map (kbd "C-c l T") #'eglot-java-project-build-task)
  (define-key eglot-java-mode-map (kbd "C-c l R") #'eglot-java-project-build-refresh))

(use-package flycheck-eglot)


(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
    (setq projectile-project-search-path '("~/Projects/" "~/java"))
    (setq projectile-switch-project-action #'projectile-dired))

(use-package magit
  :commands (magit-status magit-get-current-branch)
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package company
  :config (company-mode-on))

(use-package yasnippet
  :defer 2
  :diminish yas-minor-mode
  :config (yas-global-mode 1))

(use-package yasnippet-snippets
  :after yasnippet)

(use-package rainbow-mode
  :commands (rainbow-mode)
  :diminish
  :config
  (setq rainbow-x-colors nil))




(provide 'init)
;;; init.el ends here


;;; KEYS:
;;(comment-or-uncomment-region)
;;(duplicate-dwim)
;;(move-text)


;;;; NOTES:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; activate + C-c o for window
;; C-M-x  -> eval-defun
;; shift-M-. -> eval prompt
;; C-x-n-d  -> narrow to function

;; Needed if GPG keys expired:
;;(setq package-check-signature nil)
;;(package-refresh-contents)
;;(package-install gnu-elpa-keyring-update)
;;(setq package-check-signature 'allow-unsigned)
