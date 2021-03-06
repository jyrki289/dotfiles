;; ====PATHS====
(setq load-path
      (append load-path
              (list "~/.dotfiles/emacs.d/")
              (list "~/.dotfiles/emacs.d/vendor")
              (list "~/.dotfiles/emacs.d/vendor/color-theme-6.6.0")
              (list "~/.dotfiles/emacs.d/vendor/yasnippet")
              (list "~/.dotfiles/emacs.d/vendor/magit-1.2.1/")
              (list "~/.dotfiles/emacs.d/vendor/ess-13.05/lisp/")
              (list "~/.dotfiles/emacs.d/vendor/haskell-mode/")
              (list "~/.dotfiles/emacs.d/vendor/ethan-wspace/lisp/")
              (list "~/.dotfiles/emacs.d/vendor/expand-region.el-0.9.0/")
              (list "~/.dotfiles/emacs.d/vendor/multiple-cursors.el-1.3.0/")
              (list "~/.dotfiles/emacs.d/vendor/s.el-1.8.0/")
              (list "~/.dotfiles/emacs.d/vendor/dash.el-1.5.0/")
              (list "~/.dotfiles/emacs.d/vendor/f.el-0.10.0/")
              (list "~/.dotfiles/emacs.d/vendor/flx-master/")
              (list "~/.dotfiles/emacs.d/vendor/ack-and-a-half-1.2.0/")
              (list "~/.dotfiles/emacs.d/vendor/projectile/")
              (list "~/.dotfiles/emacs.d/vendor/csharp")
              (list "~/.dotfiles/emacs.d/vendor/auctex-11.87/")
              (list "~/.dotfiles/emacs.d/vendor/auctex-11.87/preview/")
              (list "~/.dotfiles/emacs.d/vendor/fsharpbinding-3.2.22/emacs/")
              (list "~/.dotfiles/emacs.d/vendor/auto-complete-1.4.0/")
              (list "~/.dotfiles/emacs.d/vendor/popup-el-0.5.0/")
              (list "~/.dotfiles/emacs.d/vendor/flycheck-0.14.1/")
              (list "~/.dotfiles/emacs.d/vendor/helm-1.6.3")
))

(require 'helm-config)
(helm-mode 0)


;; ====APPEARANCE====
(if window-system
    (progn
      (global-font-lock-mode t)
      (tool-bar-mode 0)))

;; (add-to-list 'custom-theme-load-path "~/.dotfiles/emacs.d/themes/")
;; (load-theme 'zenburn t)

(require 'color-theme)
(color-theme-initialize)
(color-theme-wheat)


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
(setq auto-mode-alist (cons '("\\.cu$"  . c++-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.pyx$" . python-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.cs$"  . csharp-mode) auto-mode-alist))

(setq auto-mode-alist (cons '("\\.fs$"   . fsharp-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.fsx$"  . fsharp-mode) auto-mode-alist))


(global-set-key "\M-g" 'goto-line)
(global-set-key "\C-c\C-c" 'comment-dwim)
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
(require 'yasnippet)
(setq yas-snippet-dirs
      '("~/.dotfiles/emacs.d/site-snippets/"
        "~/.dotfiles/emacs.d/vendor/yasnippet/snippets"))
(yas-global-mode 1)


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
(setq python-fill-docstring-style 'django)


(global-auto-revert-mode)

(require 'ess-site)
;;(ess-toggle-underscore)

;;
;; Haskell
;;
(require 'haskell-mode-autoloads)
(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indent)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)

;;(define-key haskell-mode-map (kbd "C-x C-s") 'haskell-mode-save-buffer)

;; (eval-after-load "haskell-mode"
;;   '(progn
;;     (define-key haskell-mode-map (kbd "C-x C-d") nil)
;;     (define-key haskell-mode-map (kbd "C-c C-z") 'haskell-interactive-switch)
;;     (define-key haskell-mode-map (kbd "C-c C-l") 'haskell-process-load-file)
;;     (define-key haskell-mode-map (kbd "C-c C-b") 'haskell-interactive-switch)
;;     (define-key haskell-mode-map (kbd "C-c C-t") 'haskell-process-do-type)
;;     (define-key haskell-mode-map (kbd "C-c C-i") 'haskell-process-do-info)
;;     (define-key haskell-mode-map (kbd "C-c M-.") nil)
;;     (define-key haskell-mode-map (kbd "C-c C-d") nil)))



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
   (gnuplot . t)
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

(setq tramp-auto-save-directory "/tmp")



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
(require 'helm-projectile)

(setq projectile-completion-system 'helm)
(define-key projectile-mode-map [?\s-p] 'helm-projectile-switch-project)
(define-key projectile-mode-map [?\s-f] 'projectile-find-file)
(define-key projectile-mode-map [?\s-b] 'projectile-switch-to-buffer)
(define-key projectile-mode-map [?\s-g] 'projectile-grep)
(define-key projectile-mode-map [?\s-a] 'projectile-ack)
(define-key projectile-mode-map [?\s-m] 'projectile-compile-project) ;; m for "make"
;;(define-key projectile-mode-map [?\s-c] 'projectile-compile-project)


(projectile-global-mode)


(global-set-key (kbd "<s-right>") 'next-buffer)
(global-set-key (kbd "<s-left>")  'previous-buffer)


(column-number-mode)


(require 'diminish)
(diminish 'yas-minor-mode)
(diminish 'projectile-mode)
(diminish 'ethan-wspace-mode)


(scroll-bar-mode 0)

(load "auctex.el" nil t t)
(load "preview-latex.el" nil t t)
(setq TeX-PDF-mode t)


(global-set-key (kbd "C-<") 'pop-global-mark)


(load "window-management.el")
(global-set-key [?\s-t] 'toggle-window-split)
(global-set-key [?\s-r] 'rotate-windows)

(global-set-key [?\s-o] 'other-window)


(setq-default truncate-lines t)

;; no more prompts!
(setq confirm-nonexistent-file-or-buffer nil)

(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)
(setq kill-buffer-query-functions
  (remq 'process-kill-buffer-query-function
         kill-buffer-query-functions))
(defalias 'yes-or-no-p 'y-or-n-p)

(load "move-text.el")

;;(setq comint-prompt-read-only t)
(setq comint-scroll-to-bottom-on-input t)
(setq comint-scroll-to-bottom-on-output t)
(setq comint-move-point-for-output t)

(require 'dired-x)
(global-set-key "\C-x\C-j" 'dired-jump)

(require 'uniquify)
(custom-set-variables
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))

(defun set-exec-path-from-shell-PATH ()
  "Set up Emacs' `exec-path' and PATH environment variable to match that used by the user's shell.
This is particularly useful under Mac OSX, where GUI apps are not started from a shell."
  (interactive)
  (let ((path-from-shell
         (replace-regexp-in-string "[ \t\n]*$" "" (shell-command-to-string "$SHELL --login -i -c 'echo $PATH'"))))
    (setenv "PATH" path-from-shell)
    (setq exec-path (split-string path-from-shell path-separator))))

(set-exec-path-from-shell-PATH)

(require 'csharp-mode)
(require 'fsharp-mode)

(global-set-key (kbd "C-*") 'mc/mark-all-dwim)



(defun projectile-eshell-cd (dir)
  "If there is an EShell buffer, cd to DIR in that buffer."
  (interactive "D")
  (let* ((eshell-buf-p (lambda (buf)
                         (with-current-buffer buf (eq major-mode 'eshell-mode))))
         (eshell-win-p (lambda (win)
                         (let ((buf (window-buffer win)))
                           (with-current-buffer buf (eq major-mode 'eshell-mode)))))
         (eshell-win (find-if eshell-win-p (window-list)))
         (eshell-buf (find-if eshell-buf-p (buffer-list))))
    (if eshell-win
        (setq eshell-buf (window-buffer eshell-win)))
    (unless eshell-buf
      (eshell)
      (setq eshell-buf (current-buffer)))
    (with-current-buffer eshell-buf
      (goto-char (point-max))
      (eshell/cd dir)
      (eshell-send-input nil t)
      eshell-buf ;; returns eshell-buf so you can focus
      ; the window if you want
      )
    (if eshell-win
        (select-window eshell-win)
      (switch-to-buffer eshell-buf))))

(defun projectile-eshell-cd-root ()
  (interactive)
  (projectile-eshell-cd (projectile-project-root)))

(defun projectile-eshell-cd-current ()
  (interactive)
  (projectile-eshell-cd default-directory))

(define-key projectile-mode-map [?\s-s] 'projectile-eshell-cd-root)

(setq tramp-auto-save-directory "/tmp")
(global-linum-mode)



(require 'org-crypt)
(org-crypt-use-before-save-magic)
(setq org-tags-exclude-from-inheritance (quote ("crypt")))
;; GPG key to use for encryption
;; Either the Key ID or set to nil to use symmetric encryption.
(setq org-crypt-key nil)


(require 'minibuf-electric-gnuemacs)
