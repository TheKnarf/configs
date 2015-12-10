(require 'package)
(package-initialize)

(setq mac-option-modifier nil
      mac-command-modifier 'meta
      x-select-enable-clipboard t)

(setq org-agenda-files (list "~/todo.org"
			     ))

(org-babel-do-load-languages
 'org-babel-load-languages '((C . t)))


(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)
(setq auto-revert-verbose nil)
(add-hook 'doc-view-mode-hook 'auto-revert-mode)

(define-key global-map "\C-ca" 'org-agenda)

(tool-bar-mode -1)

(invert-face 'default)

(setenv "PATH" (concat "/Library/TeX/texbin" ":"
	       	       "/usr/local/bin/" ":"
	       	       (getenv "PATH")))

(setq doc-view-ghostscript-program "/usr/local/bin/gs")

; http://orgmode.org/manual/LaTeX-and-PDF-export.html
(require 'ox-latex)

(unless (boundp 'org-latex-classes)
  (setq org-latex-classes nil))
  
(add-to-list 'org-latex-classes
             '("article"
               "\\documentclass{article}"
               ("\\section{%s}" . "\\section*{%s}")))
	       

;; fontify code in code blocks
(setq org-src-fontify-natively t)
