;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Font size
(set-face-attribute 'default nil :height 150)

;; Opacity
(set-frame-parameter (selected-frame) 'alpha-background 0.9)
(add-to-list 'default-frame-alist '(alpha-background . 0.9))

;; Russian keyboard
(setq default-input-method "russian-computer")

;; Additional org keybinds
(after! org
  (map! :map org-mode-map
        :n "M-j" #'org-metadown
        :n "M-k" #'org-metaup))

(use-package org-roam
  :ensure t
  :custom
  (org-roam-directory (file-truename "~/org/"))
  :bind (("C-c n l" . org-roam-buffer-toggle)
         ("C-c n f" . org-roam-node-find)
         ("C-c n g" . org-roam-graph)
         ("C-c n i" . org-roam-node-insert)
         ("C-c n c" . org-roam-capture)
         ;; Dailies
         ("C-c n j" . org-roam-dailies-capture-today))
)

;; org-roam-ui dependencies
(use-package! websocket
    :after org-roam)

(use-package! org-roam-ui
    :after org-roam ;; or :after org
;;         normally we'd recommend hooking orui after org-roam, but since org-roam does not have
;;         a hookable mode anymore, you're advised to pick something yourself
;;         if you don't care about startup time, use
;;  :hook (after-init . org-roam-ui-mode)
    :config
    (setq org-roam-ui-sync-theme t
          org-roam-ui-follow t
          org-roam-ui-update-on-save t
          org-roam-ui-open-on-start t))

;; org agenda searching in org subfolders
(with-eval-after-load 'org
  (defun org-agenda-files (&rest _)
    (directory-files-recursively "~/org" org-agenda-file-regexp)))

;; org-roam templates
(setq org-roam-capture-templates
      '(
        ("d" "default" plain
         "%?"
         :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}\n\
#+filetags:\n\
#+date: %U\n\n")
         :unnarrowed t)
        ))

;; org-roam buffer content
(setq org-roam-mode-sections
      (list #'org-roam-backlinks-section
            #'org-roam-reflinks-section
            #'org-roam-unlinked-references-section
            ))

;; $DOOMDIR/config.el
(use-package! org-pandoc-import :after org)

;; start calendar from monday
(setq calendar-week-start-day 1)


;; Org-roam capture templates for Zettelkasten workflow
(setq org-roam-capture-templates
      '(
        ;; Fleeting note: быстрое фиксирование мысли
        ("f" "Fleeting" plain
         "* Основная мысль
%?"
         :target (file+head "fleeting/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}
#+filetags: Fleeting
#+date: %U
" )
         :unnarrowed t)

        ;; Literature note: заметка по источнику
        ("l" "Literature" plain
         "* %?"
         :target (file+head "literature/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}
#+filetags: Literature
#+date: %U
#+author: %^{Author}
#+year: %^{Year}
#+source: %^{Source}
" )
         :unnarrowed t)

        ;; Permanent note: постоянная идея
        ("p" "Permanent" plain
         "* Описание
%?

* Источники
- "
         :target (file+head "permanent/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}
#+filetags: %^{Tags}
#+date: %U
" )
         :unnarrowed t)

        ;; MOC: универсальный Map of Content для любых проектов
        ("m" "MOC" plain
         "* Описание
- %^{Short description of the project}

* Разделы
- %^{Section 1}
- %^{Section 2}
- %^{Section 3}

* Источники
- "
         :target (file+head "moc/%<%Y%m%d%H%M%S>-${slug}.org"
                            "#+title: ${title}
#+filetags: MOC
#+date: %U
" )
         :unnarrowed t)
        ))


;; === Utility Function: Delete Current Note ===
(defun delete-current-buffer-file()
  "Delete the file associated with the current buffer and kill the buffer."
  (interactive)
  (let ((file (buffer-file-name)))
    (when (and file (file-exists-p file)
               (yes-or-no-p (format "Delete file %s? " file)))
      (delete-file file)
      (when (fboundp 'org-roam-db-sync)
        (org-roam-db-sync))
      (kill-buffer (current-buffer)))))

;; Keybinding: C-c n D to delete current note in org-mode buffers
(with-eval-after-load 'org
  (define-key org-mode-map (kbd "C-c n D") #'delete-current-buffer-file))

;; daily org-roam notes
(setq org-roam-dailies-capture-templates
      '(
        ("d" "Daily" plain
         "* Задачи
- [ ] %?

* Как прошел день

* Какие были мысли
-
"
         :target (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d %A>
#+filetags: daily
#+date: %<%Y-%m-%d %a>
")
         :unnarrowed t)))

;; changing input method hotkey
;;(map! :gn "C-'" #'toggle-input-method)
