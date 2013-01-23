;; ====PATHS====
(setq load-path (append load-path
                        (list "~/.dotfiles/emacs.d/")
                        (list "~/.dotfiles/emacs.d/color-theme-6.6.0")
                        (list "~/.dotfiles/emacs.d/yasnippet-0.6.1c")
                        (list "~/.dotfiles/emacs.d/magit-1.2.0/")
                        (list "~/.dotfiles/emacs.d/ess-5.13/lisp/")
                        (list "~/.dotfiles/emacs.d/haskell-mode/")
                        (list "~/.dotfiles/emacs.d/ethan-wspace/lisp/")
                        (list "~/.dotfiles/emacs.d/csharp")))

;; ====APPEARANCE====
(if window-system
    (progn
      (global-font-lock-mode t)
      (require 'color-theme)
      (color-theme-initialize)
      (color-theme-charcoal-black)
      (tool-bar-mode 0)))

;;  font and window size
(if (featurep 'aquamacs)
    ;; aquamacs
    (progn
      ;; Aquamacs font prefs
      (aquamacs-autoface-mode -1)
      (set-face-attribute 'mode-line nil :inherit 'unspecified) ; show modeline in Monaco
      (set-face-attribute 'echo-area nil :family 'unspecified)  ; show echo area in Monaco
      (setq default-frame-alist
            '((font . "-apple-Monaco-medium-normal-normal-*-9-*-*-*-m-0-iso10646-1")
              (width  . 100)
              (height . 100))))
  ;; else...
  nil)

;;(tool-bar-mode 0)

;; ====EDITING====
;; indent is 4 spaces
(setq-default indent-tabs-mode nil)

(setq-default
 c-default-style "bsd"
 c-basic-offset 4)
;; fix obnoxious extern "C" { indenting
(setq c-offsets-alist '((inextern-lang . 0)))



;; ====FILE EXTENSIONS AND MODES=====
(setq auto-mode-alist (cons '("\\.cu$" . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.pyx$" . python-mode) auto-mode-alist))

(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-c\C-c" `comment-dwim)
(global-set-key "\C-o" 'kill-region)

(defun match-paren (arg)
  "Go to the matching paren if on a paren; otherwise insert %."
  (interactive "p")
  (cond ((looking-at "\\s\(") (forward-list 1) (backward-char 1))
        ((looking-at "\\s\)") (forward-char 1) (backward-list 1))
        (t (self-insert-command (or arg 1)))))


;; Folding mode
;; (load "folding")
;; (folding-mode-add-find-file-hook)
;; (global-set-key (kbd "C-c h") 'folding-hide-current-entry)
;; (global-set-key (kbd "C-c s") 'folding-show-current-entry)


;; find-other-file
(add-hook 'c-mode-common-hook
  (lambda() 
    (local-set-key  (kbd "C-c o") 'ff-find-other-file)
    (local-set-key  (kbd "RET") 'newline-and-indent)))


;; yasnippet
(require 'yasnippet) ;; not yasnippet-bundle
(yas/initialize)
(setq yas/root-directory '("~/.dotfiles/emacs.d/yasnippet-0.6.1c/snippets"
                           "~/.dotfiles/emacs.d/site-snippets/"))
(mapc 'yas/load-directory yas/root-directory)

;; server
(server-start)

(global-set-key (kbd "M-/") 'hippie-expand)
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
try-expand-dabbrev-all-buffers try-expand-dabbrev-from-kill
try-complete-file-name-partially try-complete-file-name
try-expand-all-abbrevs try-expand-list))

(show-paren-mode)

;; Emacs doesn't get the right path
(setenv "PATH"
  (concat "/usr/texbin/:" (getenv "PATH")))

;; 
(add-hook 'python-mode-hook '(lambda ()
  (local-set-key (kbd "RET") 'newline-and-indent)))
(setq-default py-indent-offset 4)

(global-auto-revert-mode)

;; (require 'ess-site)

;;
;; Haskell
;;
(load "haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

;;
;; Org-mode
;;
(org-remember-insinuate)
(setq org-directory "~/Dropbox/Org/")
(setq org-default-notes-file (concat org-directory "/NOTES.org"))
(define-key global-map "\C-cr" 'org-remember)
(setq org-remember-templates
      '(("Todo" ?t "* TODO %?\n %i\n" "~/Dropbox/Org/TODO.org" "Unsorted")
        ("Note" ?n "* %?\n\n %i\n"    "~/Dropbox/Org/NOTES.org")))

(setq org-agenda-files
      '("~/Dropbox/Org/TODAY.org"
        "~/Dropbox/Org/TODO.org"))


(defun goto-today-org ()
  (interactive)
  (find-file "~/Dropbox/Org/TODAY.org"))

(defun goto-notes-org ()
  (interactive)
  (find-file "~/Dropbox/Org/NOTES.org"))

(defun goto-scratch ()
  (interactive)
  (switch-to-buffer "*scratch*"))

(global-set-key "\C-cy" 'goto-today-org)
(global-set-key "\C-cn" 'goto-notes-org)
(global-set-key "\C-cs" 'goto-scratch)


(setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)")))

(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)


;;
;; Magit-mode
;;
(autoload 'magit-status "magit" nil t)
(global-set-key "\C-xg" 'magit-status)
(setq magit-status-buffer-switch-function 'switch-to-buffer)

;; Magit diff colors
(eval-after-load 'magit
  '(progn
     ;;(set-face-foreground 'diff-context "#666666")
     (set-face-foreground 'diff-added "#00cc33")
     (set-face-foreground 'diff-removed "#ff0000")
     (when (not window-system)
       (set-face-background 'magit-item-highlight "black"))))


;; y/n is enough
(defalias 'yes-or-no-p 'y-or-n-p)

;; whitespace mode
(require 'ethan-wspace)
(global-ethan-wspace-mode 1)
