(setq mac-option-modifier nil
      mac-command-modifier 'meta
      x-select-enable-clipboard t)

(setq org-agenda-files (list "~/todo.org"
			     ))

(define-key global-map "\C-ca" 'org-agenda)

(tool-bar-mode -1)

(invert-face 'default)