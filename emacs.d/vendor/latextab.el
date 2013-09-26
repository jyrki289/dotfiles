;;; latextab.el --- AUCTeX add-on to ease editing of latex tabulars and friends

;; Copyright (C) 2003-2008 Christophe Deleuze <latextab@free.fr>
;; Created: Nov 2002
;; Version: 0.7 / 9 Dec 2008

;; Last version available at http://christophe.deleuze.free.fr/D/latextab.html

;; This file is NOT part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the
;; Free Software Foundation; either version 2, or (at your option) any later
;; version.

;; This file is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.

;; You should have received a copy of the GNU General Public License along
;; with this program; if not, write to the Free Software Foundation, Inc.,
;; 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.


;;; Commentary:

;; This is an add-on to the famous AUCTeX package for editing LaTeX
;; code, easing the edition of tabulars and friends (array etc).
;;
;; It requires AUCTeX to be installed.

;; For details, please see the documentation string of the
;; `ltxtab-format' function below.

;; Should work on all versions of (x)emacs.


;;; Various notes:

;; supports
;; - any number of columns
;; - missing columns at end of line
;; - \multicolumn

;; TODO
;; get lcr info from env name
;; balance col width inside multicol
;; allow a col to span several text lines
;; allow a blank prefix before first col
;; use (current-column)?

;; for AucTeX, see (defcustom LaTeX-indent-environment-list

;; BUGS

;; doesn't ignore \&'s
;; fixed by Joachim Schlosser <joachim at schlosser dot info>, 6/2004

;; current limitations:
;; - each tab line on one and only text line
;;   -> search \\ rather than (end-of-line) ?



;;; Code:

(defvar ltxtab-override-auctex t
  "Non-nil means AUCTeX's LaTeX-fill-environment function is overriden")

(defvar ltxtab-envlist 
  '( "tabular" "tabular*" "tabularx" "supertabular" "supertabular*" "longtable"
     "array" "eqnarray" "align" "align*" "cases" "matrix" "pmatrix" "Bmatrix"
     "vmatrix" "Vmatrix" "smallmatrix"
     "alignat" "alignat*" "flalign" "flalign*" "split" "aligned" "alignedat(?)"
     )
  "List of all recognized tabular-like environments")


;; We use some macros from the cl package
;; namely push, pop, dolist and dotimes

(require 'cl)


;; internal variable
(setq ltxtab-maxcol 0)


;;;; commands

(defun ltxtab-format (arg)
  "Format enclosing tab environment.
In each column, set cell size to size of the largest cell.  With
prefix arg, ask for per column alignement info as a string of 'l',
'c', and 'r' characters."

  (interactive "P")
  (save-excursion
    (let ( (l (ltxtab-find-tab))
	   (beg (make-marker))
	   (end (make-marker))
	   maxc marks tab lcrs )

      (if (null l) (message "Can't find tab!")
	(set-marker beg (car l))
	(set-marker end (cadr l))

	(if arg (setq lcrs (string-to-list (read-string "Alignement info: ")))
	  (setq lcrs '( ?c ?c ?c ?c ?c ?c ?c ?c )))

	(ltxtab-shrink beg end)
	(setq marks (ltxtab-get-markers-list beg end))
	(setq ltxtab-maxcol (car marks))
	(setq marks (cdr marks))

	(setq tab (ltxtab-parse-tab marks))
	(dotimes (i (length tab)) (print (aref tab (1- (- (length tab) i)))))
	(ltxtab-update marks tab (ltxtab-adjust tab) lcrs)
	(dolist (m (cons beg (cons end marks))) (set-marker m nil))
      ))))


;;;; sub-routines

;; this is stupidly copied from the latex.el file of AucTeX, except we
;; substring text without properties

(defun myLaTeX-current-environment (&optional arg)
  "Return the name (a string) of the enclosing LaTeX environment.
With optional ARG>=1, find that outer level."
  (setq arg (if arg (if (< arg 1) 1 arg) 1))
  (save-excursion
    (while (and
	    (/= arg 0)
	    (re-search-backward
	     (concat (regexp-quote TeX-esc) "begin" (regexp-quote TeX-grop)
		     "\\|"
		     (regexp-quote TeX-esc) "end" (regexp-quote TeX-grop)) 
	     nil t 1))
      (cond ((TeX-in-comment)
	     (beginning-of-line 1))
	    ((looking-at (concat (regexp-quote TeX-esc)
				 "end" (regexp-quote TeX-grop)))
	     (setq arg (1+ arg)))
	    (t
	    (setq arg (1- arg)))))
    (if (/= arg 0)
	"document"
      (search-forward TeX-grop)
      (let ((beg (point)))
	(search-forward TeX-grcl)
	(backward-char 1)
	(buffer-substring-no-properties beg (point))))))


(defun ltxtab-find-tab ()
  "Return (beg end) positions of enclosing tab environment, or nil."
  (save-excursion
    (let ((cur (myLaTeX-current-environment)))
      (if (member cur ltxtab-envlist)
	  (list (search-backward "\\begin{" )
		(progn (search-forward "\\end{")
		       (backward-word 1) (point)))))))


(defun ltxtab-get-markers-list (beg end)
  "Return (maxcol (markers)) info for tab at passed position.
Maxcol is the max number of columns of the tab, a marker is set at the
beginning of each 'tab line' (ie those that have a & in them)."

  ;; return current line end position
  (defun eol-pos ()
    (save-excursion
      (end-of-line) (point)))

  ;; how many cols on that line?
  (defun nb-cols ()
    (let ( (nb 0)
	   (eol (eol-pos)) )
      (while (re-search-forward "\\\\?&" eol t) 
	(unless (string= "\\&" (match-string 0))
	  (setq nb (1+ nb))))
      nb))

  (let ( l (maxcol 0) )
    (goto-char beg)
    (while (< (point) end)
      (forward-line)
      (if (search-forward "&" (eol-pos) t)
	  (progn
	    ;; get marker on bol
	    (beginning-of-line)
	    (push (set-marker (make-marker) (point)) l)
	    ;; get number of columns
	    (let ( (nb (nb-cols) )) (if (> nb maxcol) (setq maxcol nb))) )))
    (cons maxcol l)))


(defun ltxtab-parse-tab (marks)
  "Given marks for each tab line, return vector of vectors for tab structure."
  (let ( (tab (make-vector (length marks) nil))
	 (i 0) )
    (dolist (mark marks)
      (aset tab i (ltxtab-parse-line mark))
      (setq i (1+ i)))
    tab))


(defun ltxtab-parse-line (m)
  "Return vector of tab cell sizes for line starting at mark m."
  (goto-char m)
  (let ( (pos (point))
	 (eol (progn (end-of-line) (point)))
	 amps )
    
    (goto-char m)
    (while (re-search-forward "\\\\?&" eol t)
      (unless (string= "\\&" (match-string 0))
	(let ( (new-pos (point))
	       (nb 0) )
	  (if (re-search-backward "multicolumn{\\(.*\\)" pos t)
	      
	      ;; current cell is multicolumn...
	      (progn
		(forward-word 1) (forward-char)
		(setq nb (- (char-after) 48))   ; nb of columns
		(goto-char new-pos)

		(dotimes (i (1- nb)) (push 0 amps))
		(push (- pos (point)) amps))

	    ;; normal cell
	    (goto-char new-pos)
	    (push (- (point) pos) amps))

	  (setq pos (point)))))

    (apply 'vector
	   ((lambda (l) (append l (make-list (- ltxtab-maxcol (length l)) 0)))
	    (reverse amps)))))


(defun ltxtab-adjust (tab)
  "Compute the list of goal cell sizes from tab structure (vect of vect)."
  (let ( (i 0)
	 (j 0)
	 maxs max
	 (c-j  (make-vector (length tab) 0)) ) ; current carry for each line

    (dotimes (i ltxtab-maxcol)

      ;; get the largest value for this column
      (setq max 0)
      (setq clines nil)                         ; lines with carry

      (dotimes (j (length tab))

	;; for each line
	(let ( (a-ij (aref (aref tab j) i)) )
	  (cond
	   ;; normal cell
	   ((> a-ij 0) (progn (if (> a-ij max) (setq max a-ij))
			      (aset c-j j 0)))

	   ;; inside a multicol - mark for updating carry
	   ((= a-ij 0) (push j clines))

	   ;; end of multicol - report carry
	   ((< a-ij 0) (progn (if (> (- (+ a-ij (aref c-j j))) max)
				  (setq max (- (+ a-ij (aref c-j j)))))
			      (aset c-j j 0)))
	   ))
	)

      ;; now max is set for current column
      (push max maxs)

      ;; update carry for each line that needs to
      (dolist (line clines)
	(aset c-j line (+ (aref c-j line) max)))

      )
    ;; echo the result
    (print (reverse maxs))))


;; update the tab so that columns have the sizes specified in goals
;; and alignement info in lcrs

(defun ltxtab-update (marks tab goals lcrs)
  "Update tab by expanding cells to conform goal sizes and alignment info.
marks list tab lines, tab show tab structure, goals is the list of
column sizes, lcrs is the list of characters for alignment info."

  ;; point is one char before first char of cell
  (defun cell-adjust (cur goal lrc)
    (let ( (dif (- goal cur)) )
      (if (> dif 0)
	  (case lrc
	    ((?l) (progn (forward-char cur) (insert-char 32 dif)))
	    ((?c) (progn (forward-char 1)
			 (insert-char 32 (/ dif 2))
			 (forward-char (1- cur))
			 (insert-char 32 (+ (/ dif 2) (mod dif 2)))))
	    ((?r) (progn (forward-char 1)
			 (insert-char 32 dif)
			 (forward-char (1- cur)))))
	
	(forward-char cur))
       ))

  (let ( (i 0) j line pos lcrs2
	 (r-i (make-vector (length tab) 0)))

    ;; for each line
    (dolist (mark marks)
      (setq lcrs2 lcrs)
      (goto-char mark)
      (backward-char)              ;???
      (setq line (aref tab i))
      (setq j 0)

      ;; for each column
      (dolist (goal goals)
	  (let ( (s (aref line j)) )
	    (cond
	     ;; normal cell
	     ((> s 0) (cell-adjust s goal (pop lcrs2)))
	     
	     ;; inside a multicol
	     ((= s 0) (progn (pop lcrs2) (aset r-i i (+ (aref r-i i) goal))) )

	     ;; end of multicol
	     ((< s 0) (progn (cell-adjust (- s) (+ (aref r-i i) goal) 
					  (pop lcrs2))
			     (aset r-i i 0)) )
	     ))
	  (setq j (1+ j)))
      (setq i (1+ i))) ))


(defun ltxtab-shrink (beg end)
  "Compress (remove blanks) each cell of the tab between beg/end positions."
  (goto-char beg)
  (while (re-search-forward "^ +" end t)
    (replace-match ""))
  (goto-char beg)
  (while (re-search-forward "\\(\\\\\\)?& *" end t)
    (unless (string= "\\" (match-string 1))
    (replace-match "\\1& ")))
  (goto-char beg)
  (while (re-search-forward " +&" end t)
    (replace-match " &"))
)


(defun ltxtab-init ()
  "Initialization code for latextab.
If ltxtab-override-auctex is non-nil, override LaTeX-fill-environment
function, else set specific keyboard shortcut and menu entry."

  (interactive)
  (if ltxtab-override-auctex

      (defun LaTeX-fill-environment (justify)
	"Fill and indent current environment as LaTeX text."
	(interactive "*P")
	(save-excursion
	  (if (ltxtab-find-tab) (ltxtab-format nil)
	    (LaTeX-mark-environment)
	    (re-search-forward "{\\([^}]+\\)}")
	    (LaTeX-fill-region
	     (region-beginning)
	     (region-end)
	     justify
	     (concat " environment " (TeX-match-buffer 1))))))
    ;; else
    (define-key LaTeX-mode-map "\C-c\C-q\C-t" #'ltxtab-format)
    (easy-menu-add-item nil
			'("LaTeX" "Formatting and Marking")
			[ "Format Tab" ltxtab-format "\C-c\C-q\C-t" ]
			"Format Section")))


;;; latextab.el ends here
