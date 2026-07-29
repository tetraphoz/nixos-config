;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Spelling
(use-package! jinx
  :after vertico
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages))
  :init
  (setq jinx-languages "es_MX en_US"
        jinx-delay 1.0)
  :config
  (add-to-list 'vertico-multiform-categories
               '(jinx (vertico-grid-annotate . 25)))
  (vertico-multiform-mode 1))

(use-package! mixed-pitch
  :hook
  ;; If you want it in all text modes:
  (text-mode . mixed-pitch-mode))

;; Let new buffers replace the Doom dashboard in new frames
(defun my/doom-dashboard-replaceable (&rest _)
  "Make the *doom* buffer's window not dedicated so other buffers can replace it."
  (when (string= (buffer-name) "*doom*")
    (set-window-dedicated-p (selected-window) nil)))

;; Run whenever frame/window config changes, so it works even in new frames
(add-hook 'window-configuration-change-hook #'my/doom-dashboard-replaceable)

(use-package! org-krita
  :config
  (add-hook 'org-mode-hook 'org-krita-mode))

(use-package! org
  :defer t
  :config
  (setq org-directory "/media/syncthing/gtd-new"
        org-log-done 'time
        org-log-redeadline 'time
        org-log-reschedule 'time
        org-default-notes-file (concat org-directory "/gtd.org")
        org-agenda-files '("/media/syncthing/gtd-new/accion.org"
                           "/media/syncthing/gtd-new/gtd.org"
                           "/media/syncthing/gtd-new/responsabilidades.org"
                           "/media/syncthing/gtd-new/tickler.org"
                           "/media/syncthing/gtd-new/cel.org"
                           "/media/syncthing/gtd-new/lap.org")

        org-refile-targets '(("/media/syncthing/gtd-new/gtd.org" :maxlevel . 2)
                             ("/media/syncthing/gtd-new/accion.org" :level . 1)
                             ("/media/syncthing/gtd-new/tickler.org" :maxlevel . 1)))
  (setq org-capture-templates
        `(("a" "Acción" entry (file "/media/syncthing/gtd-new/accion.org") "* TODO %? ")
          ("l" "Link" entry (file "/media/syncthing/gtd-new/gtd.org") "* %?\n %U\n %a\n")
          ("b" "Inbox de mi computadora" entry (file "/media/syncthing/gtd-new/lap.org") "* %?")
          ("d" "Diario de sueños" entry (file+datetree "/media/syncthing/roam/20250918133306-suenos.org") "* %U \n%?")
          ("t" "Por hacer" entry (file+headline "/media/syncthing/gtd-new/porhacer.org" "* HOLD "))))

  (setq org-image-align 'center)
  (setq org-image-actual-width '(0.6))

  (add-to-list 'org-modules 'org-habit t)
  (add-to-list 'org-modules 'org-depend t)

  (org-babel-do-load-languages
   'org-babel-load-languages
   '((gnuplot . t)))
  )


(use-package! org-roam
  :defer t
  :config
  (setq org-roam-directory "/media/syncthing/roam")
  (setq org-roam-completion-everywhere t)
  (setq org-roam-mode-sections
        (list #'org-roam-backlinks-section
              #'org-roam-reflinks-section
              #'org-roam-unlinked-references-section)))

(use-package! org-journal
  :defer t
  :config
  (add-to-list 'org-agenda-files org-journal-dir)
  (setq org-journal-enable-agenda-integration t
        org-journal-file-type 'weekly
        org-journal-file-format "%Y%m%d.org"
        org-icalendar-store-UID t
        org-icalendar-include-todo "all"
        org-icalendar-combined-agenda-file "/media/syncthing/gtd-new/cal.ics"
        )

  ;; (add-hook 'org-journal-after-header-create-hook (lambda () (make-symbolic-link (org-journal--get-entry-path) "/home/tetra/gtd/diario.org" 't)))
  ;; Diosmio, que rico es programar cuando le sabes
  ;; Bendito seas emacs
  )

(use-package! emacs
  :defer t
  :config
  (setq-default evil-escape-key-sequence "jk")
  (setq evil-respect-visual-line-mode t)
  (setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
  (setq mouse-wheel-progressive-speed nil)
  (setq-default line-spacing .15)
  (setq doom-theme 'ef-light
        doom-font (font-spec :family "Fira Code" :weight 'medium :size 11)
        doom-variable-pitch-font (font-spec :family "IBM Plex Serif" :weight 'normal)
        display-line-numbers-type 't
        ;; warning-minimum-level :error
        global-auto-revert-mode t
        browse-url-firefox-program "librewolf"
        user-full-name "tetraphz"
        user-mail-address "tetraphosphorus@gmail.com"
        confirm-kill-emacs nil
        search-default-mode #'char-fold-to-regexp)
  ;; Add your global npm bin directory to Emacs's PATH
  (setenv "PATH" (concat (getenv "PATH") ":/home/tetra/.local/bin"))
  (add-to-list 'exec-path "/home/tetra/.local/bin")
  )

;; (set-frame-parameter nil 'alpha-background 80)
;; (add-to-list 'default-frame-alist '(alpha-background . 80))


(use-package! dired-x
  :config
  (setq dired-omit-files
        (concat dired-omit-files "\\|^\\..*$")))

(use-package! w3m
  :defer t)

;; (use-package! spacious-padding
;;   :ensure t
;;   :config
;;   ;; Default padding settings
;;   (setq spacious-padding-widths
;;         '( :internal-border-width 15
;;            :header-line-width 4
;;            :mode-line-width 6
;;            :tab-width 4
;;            :right-divider-width 30
;;            :scroll-bar-width 8
;;            :fringe-width 8))

;;   ;; Flexible mode line settings
;;   (setq spacious-padding-subtle-frame-lines
;;         `( :mode-line-active 'default
;;            :mode-line-inactive vertical-border))

;;   ;; Enable spacious padding mode
;;   (spacious-padding-mode 1)

;;   ;; Key binding to toggle spacious padding
;;   (define-key global-map (kbd "<f8>") #'spacious-padding-mode))

(after! gptel
  (setq gptel-default-mode 'org-mode)
  (setq gptel-api-key "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")
  (gptel-make-gemini "Gemini" :key "AIzaSyDJALILQmY8gL8_-NBDBF9KtcqZYp7Kdz4" :stream t))

(use-package! lsp-mode
  :defer t
  :config
  (setq lsp-pyright-langserver-command "basedpyright"))

(after! dap-mode (setq dap-python-debugger 'debugpy))

(use-package! org-gcal :defer t)

(use-package! pddl-mode :defer t)

(use-package! emacs-pet
  :defer t
  :config
  (add-hook 'python-base-mode-hook 'pet-mode -10))

(use-package! gams-mode
  :defer t
  :config
  (setq gams-process-command-name "/home/tetra/prog/gams/gams47.6_linux_x64_64_sfx/gams"))

(use-package! glsl-mode
  :defer t
  )

(use-package! platformio-mode
  :defer t
  :config
  (add-hook 'c++-mode-hook (lambda ()
                             (lsp-deferred)
                             (platformio-conditionally-enable))))

(use-package! treemacs
  :defer t
  :config
  (setq treemacs-text-scale -2))

;; (use-package! dirvish
;;   :config
;;   (setq dired-listing-switches
;;         "-l --almost-all --human-readable --group-directories-first --no-group"))

(use-package! eglot-java
  :defer t
  :config
  (add-hook 'java-mode-hook 'eglot-java-mode))


(use-package! reftex
  :defer t
  :config
  (setq reftex-default-bibliography "/gtd/biblio.bib"))

;; LSP
(after! lsp-clangd
  (setq lsp-clients-clangd-args
        '("-j=3"
          "--background-index"
          "--clang-tidy"
          "--completion-style=detailed"
          "--header-insertion=never"
          "--header-insertion-decorators=0"))
  (set-lsp-priority! 'clangd 2))

(use-package! elfeed
  :defer t
  :config
  (add-hook 'elfeed-search-mode-hook #'elfeed-update))

(use-package! leetcode
  :defer t
  :config
  (setq leetcode-language "cpp"))

;; Evil
(use-package! evil
  :defer t
  :config
  (setq +evil-want-o/O-to-continue-comments nil))

(use-package! evil-owl
  :defer t
  :config
  (setq evil-owl-display-method 'posframe
        evil-owl-extra-posframe-args '(:width 50 :height 30)
        evil-owl-max-string-length 50)
  (evil-owl-mode))

(use-package! doom-modeline
  :defer t
  :config
  (setq doom-modeline-height 15))

;; Books
(use-package! calibredb
  :defer t
  :config
  (setq calibredb-root-dir "~/media/books")
  (setq calibredb-db-dir (expand-file-name "metadata.db" calibredb-root-dir)))

;; Org
;; (use-package! org-xournalpp
;;   :defer t
;;   :config
;;   (map! :map org-mode-map
;;         :localleader "l x" 'org-xournalpp-insert-new-image)
;;   (add-hook 'org-mode-hook 'org-xournalpp-mode))

(use-package! pomm
  :defer t
  :config
  (setq pomm-mode-line-mode t)
  (setq alert-default-style 'libnotify)
  (pomm-mode-line-mode))


(use-package! olivetti
  :defer t)

(use-package! anki-editor
  :defer t)

(use-package! projectile
  :defer t
  :config
  (setq projectile-run-use-comint-mode t))

(use-package! org-node
  :defer t
  :init
  (keymap-set global-map "M-o" org-node-global-prefix-map)
  (with-eval-after-load 'org
    (keymap-set org-mode-map "M-o" org-node-org-prefix-map))
  :config
  (setq org-mem-do-sync-with-org-id t)
  (setq org-mem-watch-dirs
        (list "/media/syncthing/roam/" "/media/uni/" "/media/syncthing/gtd-new/")) ;; Your org-roam-directory here
  (org-mem-updater-mode)
  (org-node-cache-mode)
  (org-node-roam-accelerator-mode)
  (setq org-node-creation-fn #'org-node-new-via-roam-capture)
  (setq org-node-file-slug-fn #'org-node-slugify-like-roam-default)
  (setq org-node-file-timestamp-format "%Y%m%d%H%M%S-"))

(use-package! org-transclusion
  :after org
  :init
  (map!
   :map global-map "<f12>" #'org-transclusion-add
   :leader
   :prefix "n"
   :desc "Org Transclusion Mode" "t" #'org-transclusion-mode))
