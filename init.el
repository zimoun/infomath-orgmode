;; remove the initial starting message
(setq inhibit-startup-message t)

;; delete the *scratch* initial message
(setq initial-scratch-message nil)

;; remove the menu when inside terminal
(if (display-graphic-p)
    (menu-bar-mode 1)
  (menu-bar-mode 0))

;; simplify the question-answer process
(defalias 'yes-or-no-p 'y-or-n-p)

;; M-x mode-* instead of the long name
(defalias 'mode-whitespace 'whitespace-mode)
(defalias 'mode-highlight 'global-hl-line-mode)

;; set global shortcuts
(global-set-key [?\C-k] 'kill-whole-line)
(global-set-key [?\C-$] 'ispell-region)

;; delete dirty spaces
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; highlight the selected area
(setq transient-mark-mode t)
;; change the default color of the selected area
(set-face-attribute 'region nil :background "yellow")

;; manipulate more easily Buffers
(ido-mode 'buffers)

;; instead of filename.extension~ in the working directory
;; all the backup files (suffix ~) are stored there
(setq backup-directory-alist '(("." . "~/.emacs.d/backup"))
      backup-by-copying t    ; Don't delink hardlinks
      version-control t      ; Use version numbers on backups
      delete-old-versions t  ; Automatically delete excess backups
      kept-new-versions 20   ; how many of the newest versions to keep
      kept-old-versions 5    ; and how many of the old
      )

;; set the maximum character per line
;;  used by minor mode  (fill-mode)
(setq-default fill-column 80)

;; display the number of the column
(column-number-mode t)

;; save minibuffer history
(savehist-mode 1)

;; the nice buffers manager
(require 'ibuffer)
;; change the default one to ibuffer
(defalias 'list-buffers 'ibuffer)
;; group buffers
(setq ibuffer-saved-filter-groups
      (quote (("default"
               ("Dired" (mode . dired-mode))
               ("(La)TeX" (or
                           (mode . tex-mode)
                           (mode . latex-mode)
                           ))
               ("Lisp" (or
                        (mode . lisp-mode)
                        (mode . emacs-lisp-mode)
                        (mode . scheme-mode)
                        ))
               ("MaGit" (name . "\*magit"))
               ("Org" (mode . org-mode))
               ("Py" (mode . python-mode))
               ("emacs" (or
                         (name . "^\\*[a-zA-Z ]*\\*$")))))))
;; setup the groups
(add-hook 'ibuffer-mode-hook
          (lambda ()
            (setq-local case-fold-search nil)
            (ibuffer-switch-to-saved-filter-groups "default")))
;; sort buffer in each group in alphabetic order
(setq ibuffer-default-sorting-mode 'alphabetic)


;; change theme (I personally use the default one)
;; (load-theme 'leuven)
;; or download one from the web
;; (use-package zenburn
;;   :ensure t
;;   :init
;;   (load-theme 'zenburn))

;; boostrap `use-package' by John Wiegley
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
;; load it
(require 'use-package)

;; change the default file manager
(use-package dired
  :defer t
  :init
  (defalias 'list-directory 'dired)
  :config
  (define-key dired-mode-map (kbd "E") 'dired-toggle-read-only))

;;;;
;;
;; Move automatic custom to special file
;;;; avoid to pollute this file
;;;; and custom.el is not versionned
(setq custom-file "~/.emacs.d/custom.el")
(when (file-exists-p custom-file)
  (load-file custom-file))
;;
;;;;

;;;;
;;
;; TeX/LaTeX configuration
;;
;; be careful, the names of the modes are a bit a messy
(use-package tex-mode
  :defer t
  :config
  ;; automatically bound paragraph length
  (add-hook 'latex-mode-hook 'turn-on-auto-fill)
  ;; turn on the nice RefTeX package
  (add-hook 'latex-mode-hook 'turn-on-reftex))

;; compilation show first the first error
;; instead of the end of the compilation buffer
(setq compilation-scroll-output 'first-error)

;; mispelling correction using dictionary
(use-package ispell
  :defer t
  :config
  ;; you need to install the program aspell
  (setq-default ispell-program-name "aspell"))











;;;;
;;
;; Set Org
;;
;; General config about Org
(use-package org
  :ensure org-plus-contrib		; tricks!
                                        ; ensure the last version of Org

  :defer t
  :bind ("\C-ca"  . org-agenda)

  :config
  ;; With 9.2 <s does not work anymore
  ;; The Org Tempo should allow the previous mechanism
  ;; but does not work
  (require 'org-tempo)
  ;; else see org-structure-template-alist

  ;; directories containing the Org files used by the org-agenda
  ;; search all files with the extension .org in the directory "~/org/"
  (setq org-agenda-files (directory-files-recursively "~/org/" "\.org$"))

  (setq org-hide-emphasis-markers t)	; hide markups

  ;; hook to limit the number of characters per line
  ;; this number is controled by the variable fill-column
  (add-hook 'org-mode-hook 'turn-on-auto-fill)

  (setq org-src-fontify-natively t)	; coloring   inside blocks
  (setq org-src-tab-acts-natively t)	; completion inside blocks
  (setq org-tag-faces			; color is nicer ;-)
        '(
          ("config" . (:foreground "mediumseagreen" :weight bold))
          ("LIVE" . (:foreground "Red" :underline t))

          ("@meet" . (:foreground "mediumseagreen" :weight bold :underline t))
          ("URGENT" . (:foreground "Red" :underline t))
          ))

  ;; execute blocks (can be reused if even you do not use Reveal.js)
  (org-babel-do-load-languages
   'org-babel-load-languages '((python . t)
                               (R . t)
                               (shell . t)))
  ;; do not ask before eval code blocks
  (setq org-confirm-babel-evaluate nil)

  ;; store time when TODO is DONE
  (setq org-log-done (quote time)))


;;;;
;;
;; Set Reveal.js
;;
;;
;; WARNING: issue with Org 8.2
;; Not sure this code fixed the issue
;;
;; The idea is:
;; 1. Trick from https://github.com/jwiegley/use-package/issues/319
;;    Download the newer version of Org by ensuring org-plus-contrib
;; 2. DO NOT FORGET to manually clone org-reveal from Github
;;    Put it somewhere and give this inforamtion to :load-path
;;
;;    WARNING: org-reveal does not work with Org 9.2
;;    Fork: https://github.com/zimoun/org-reveal.git
;;          and this fork comments the inconsistency
;;
;; 3. Done.
;;
(setq ox-reveal-path "~/.emacs.d/elpa/org-reveal.git")
(if (file-directory-p ox-reveal-path)
    ;; then-clause
    (use-package ox-reveal
      :load-path ox-reveal-path
      :init
      ;; always load ox-reveal at startup
      ;; comment this line if you want not
      ;; but do not forget to load it manually M-: (require 'ox-reveal)
      (require 'ox-reveal))
  ;; else-clause
  (warn
   (format "Cannot load org exporter to Reveal.js.\nFix two steps: 1) Clone and 2) Reload.\n\ngit clone https://github.com/zimoun/org-reveal.git %s\n\nM-x load-file \"~/.emacs.d/init.el\"" ox-reveal-path)))

;;
;; ;end Reveal.js
;;
;;;;

;;;;
;;
;; Set syntax coloring
;;
(use-package htmlize
  :ensure t
  :defer t)

;;
;; ;end
;;
;;;;

;;;;
;;
;; Below is not minimal
;;
;;


;;
;;
;;

;; useful to demo (log all the keystrokes)
(use-package command-log-mode
  :ensure t
  :defer t
  :init
  ;; comment the line to not load globally command-log-mode
  (setq command-log-mode-is-global t)   ; turn off by replacing t with nil

  (defalias 'mode-command-log 'command-log-mode)
  (defalias 'command-log-show '(lambda (&optional arg)
                                 (interactive "P")
                                 (progn
                                   (command-log-mode)
                                   (message "Alias of clm/open-command-log-buffer. See M-x clm/TAB.")
                                   (clm/open-command-log-buffer arg))))
  (add-hook 'LaTeX-mode-hook 'command-log-mode)
  (add-hook 'python-mode-hook 'command-log-mode)
  (add-hook 'org-mode-hook 'command-log-mode)
  (add-hook 'emacs-lisp-mode-hook 'command-log-mode)
  (add-hook 'text-mode-hook 'command-log-mode))

;; ;; to change highlight of the selection
;; (set-face-attribute 'region nil :background "#ffff00")

;; ;; to change the background, sometimes eyes are really tired
;; (set-background-color "LightGoldenrod3")
;; ;;(set-background-color "LightCyan3")

;;;;
;;
;; Basics example of configuration file
;;
;; mkdir -p $HOME/.emacs.d
;; mv init.el $HOME/.emacs.d/init.el
;;
;;;;

(require 'package)
(setq package-enable-at-startup nil)
(add-to-list 'package-archives
             ;; `use-package' is not in ELPA, as many more ;-)
             '("melpa" . "http://melpa.org/packages/"))
(add-to-list 'package-archives
               ;; Add org-plus-contrib
               '("org" . "http://orgmode.org/elpa/"))
(package-initialize)
