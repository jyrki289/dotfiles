;; ====PATHS====
(setq load-path
      (append load-path
              (list "~/.dotfiles/emacs.d/")
              (list "~/.dotfiles/emacs.d/color-theme-6.6.0")
              (list "~/.dotfiles/emacs.d/yasnippet-0.6.1c")
              (list "~/.dotfiles/emacs.d/magit-1.2.0/")
              (list "~/.dotfiles/emacs.d/ess-13.05/lisp/")
              (list "~/.dotfiles/emacs.d/haskell-mode/")
              (list "~/.dotfiles/emacs.d/ethan-wspace/lisp/")
              (list "~/.dotfiles/emacs.d/expand-region/")
              (list "~/.dotfiles/emacs.d/multiple-cursors/")

              (list "~/.dotfiles/emacs.d/s.el/")
              (list "~/.dotfiles/emacs.d/dash.el//")
              (list "~/.dotfiles/emacs.d/flx/")

              (list "~/.dotfiles/emacs.d/ack-and-a-half-1.2.0/")

              (list "~/.dotfiles/emacs.d/projectile/")

              (list "~/.dotfiles/emacs.d/csharp")))

;; ====APPEARANCE====
(if window-system
    (progn
      (global-font-lock-mode t)
      (require 'color-theme)
      (color-theme-initialize)
      (color-theme-charcoal-black)
      (tool-bar-mode 0)))

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
(global-set-key "\C-c\C-c" 'comment-dwim)
(global-set-key "\C-o" 'kill-region)
(global-set-key "\C-x\C-b" 'ibuffer)
(global-set-key "\C-x\\" 'align-regexp)


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

(require 'ess-site)

;;
;; Haskell
;;
(load "haskell-site-file")
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)

;;
;; Org-mode
;;

;;(org-remember-insinuate)
(setq remember-annotation-functions '(org-remember-annotation))
(setq remember-handler-functions '(org-remember-handler))
(add-hook 'remember-mode-hook 'org-remember-apply-template)

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

(defun goto-dotemacs ()
  (interactive)
  (find-file "~/.dotfiles/emacs.el"))

(global-set-key "\C-cy" 'goto-today-org)
(global-set-key "\C-cn" 'goto-notes-org)
(global-set-key "\C-cs" 'goto-scratch)
(global-set-key "\C-ce" 'goto-dotemacs)
(global-set-key "\C-ca" 'org-agenda)

(setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w)" "|" "DONE(d)")))

(setq org-clock-persist 'history)
(org-clock-persistence-insinuate)

;; org-babel
(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (ruby . t)
   (python . t)
   (sh . t)
   (perl . t)
   (ditaa . t)
   (latex . t)))


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
    (defun magit-highlight-section ())
     (set-face-foreground 'diff-added "#00cc33")
     (set-face-foreground 'diff-removed "#ff0000")
     (when (not window-system)
       (set-face-background 'magit-item-highlight "black"))))


;; y/n is enough
(defalias 'yes-or-no-p 'y-or-n-p)

;; whitespace mode
(require 'ethan-wspace)
(global-ethan-wspace-mode 1)

;; Magnars stuff
(require 'expand-region)
(global-set-key (kbd "C--") 'er/expand-region)
;;(pending-delete-mode)

(require 'multiple-cursors)
(global-set-key (kbd "C-=") 'mc/mark-next-like-this)



;; flymake
(when (load "flymake" t)
  (defun flymake-pyflakes-init ()
    (let* ((temp-file (flymake-init-create-temp-buffer-copy
                       'flymake-create-temp-inplace))
           (local-file (file-relative-name
                        temp-file
                        (file-name-directory buffer-file-name))))
      (list "pyflakes"  (list local-file))))
  (add-to-list 'flymake-allowed-file-name-masks
               '("\\.py\\'" flymake-pyflakes-init)))


(defun smart-line-beginning ()
  "Move point to the beginning of text on the current line; if
that is already the current position of point, then move it to
the beginning of the line."
  (interactive)
  (let ((pt (point)))
    (beginning-of-line-text)
    (when (eq pt (point))
      (beginning-of-line))))
(global-set-key (kbd "C-a") 'smart-line-beginning)


(require 'multiple-cursors)
(global-set-key (kbd "C-=") 'mc/mark-next-like-this)

;; (global-set-key "\M-\\" 'align-regexp)


;; autoscroll console in ess
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)

(require 'flx-ido)
(ido-mode 1)
(ido-everywhere 1)
(flx-ido-mode 1)
;; disable ido faces to see flx highlights.
(setq ido-use-faces nil)

(require 'ack-and-a-half)
;; Create shorter aliases
(defalias 'ack 'ack-and-a-half)
(defalias 'ack-same 'ack-and-a-half-same)
(defalias 'ack-find-file 'ack-and-a-half-find-file)
(defalias 'ack-find-file-same 'ack-and-a-half-find-file-same)

;; for looking at ack results
(global-set-key (kbd "<s-up>")   'previous-error)
(global-set-key (kbd "<s-down>") 'next-error)

(require 'projectile)
(define-key projectile-mode-map [?\s-d] 'projectile-find-dir)
(define-key projectile-mode-map [?\s-p] 'projectile-switch-project)
(define-key projectile-mode-map [?\s-f] 'projectile-find-file)
(define-key projectile-mode-map [?\s-g] 'projectile-grep)
(define-key projectile-mode-map [?\s-a] 'projectile-ack)

(projectile-global-mode)


;; Display ido results vertically, rather than horizontally
(setq ido-decorations (quote ("\n-> " "" "\n   " "\n   ..." "[" "]" " [No match]"
                              " [Matched]" " [Not readable]" " [Too big]" " [Confirm]")))


(defun ido-disable-line-truncation () (set (make-local-variable 'truncate-lines) nil))
(add-hook 'ido-minibuffer-setup-hook 'ido-disable-line-truncation)
(defun ido-define-keys () ;; C-n/p is more intuitive in vertical layout
  (define-key ido-completion-map (kbd "C-n") 'ido-next-match)
  (define-key ido-completion-map (kbd "C-p") 'ido-prev-match))
(add-hook 'ido-setup-hook 'ido-define-keys)
