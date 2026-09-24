;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ---------------------------------------------------------------------------
;; Secrets
;; ---------------------------------------------------------------------------
;; API keys are pulled from auth-source instead of living here in plaintext.
;; Add these two lines to ~/.authinfo.gpg (create/encrypt it if you don't
;; have one yet):
;;
;; auth-source-pick-first-password will prompt gpg for your passphrase the
;; first time it's needed each session, then cache it.
(defun my/auth-source-secret (host)
  "Look up the password for HOST via auth-source."
  (auth-source-pick-first-password :host host))

;; ---------------------------------------------------------------------------
;; Core editor behavior
;; ---------------------------------------------------------------------------
(setq-default evil-escape-key-sequence "jk")
(setq evil-respect-visual-line-mode t)
(setq mouse-wheel-scroll-amount '(1 ((shift) . 1) ((control) . nil)))
(setq mouse-wheel-progressive-speed nil)
(setq-default line-spacing 0.15)

;; Keep the X11 mouse pointer visible over dark Emacs frames.  Emacs daemons
;; do not have a graphical frame at startup, so apply this both now and when
;; each GUI frame is created.
(defconst my/emacs-mouse-color "#f8f8f2")

;; Set the frame parameter as well as calling set-mouse-color.  The frame
;; parameter is important for frames created by an Emacs daemon and prevents
;; the toolkit from falling back to its default black pointer.
(add-to-list 'default-frame-alist
             `(mouse-color . ,my/emacs-mouse-color))

(defun my/set-emacs-mouse-color (&optional frame)
  "Use a light mouse pointer on graphical FRAME.

Also set the frame parameter explicitly because some X toolkits ignore the
value passed only through `set-mouse-color`."
  (let ((frame (or frame (selected-frame))))
    (when (display-graphic-p frame)
      (set-frame-parameter frame 'mouse-color my/emacs-mouse-color)
      (with-selected-frame frame
        (set-mouse-color my/emacs-mouse-color)))))

(add-hook 'after-make-frame-functions #'my/set-emacs-mouse-color)
(add-hook 'server-after-make-frame-hook
          (lambda () (my/set-emacs-mouse-color (selected-frame))))
(my/set-emacs-mouse-color (selected-frame))

;; Theme / fonts / global variables
(setq doom-theme 'ef-dream
      doom-font (font-spec :family "Cozette" :size 12)
      doom-variable-pitch-font (font-spec :family "IBM Plex Serif" :weight 'normal)
      display-line-numbers-type t
      browse-url-firefox-program "librewolf"
      user-full-name "tetraphz"
      user-mail-address "tetraphosphorus@gmail.com"
      confirm-kill-emacs nil
      search-default-mode #'char-fold-to-regexp)

;; Start graphical Emacs frames with a transparent background.  Only the
;; background is transparent; text and UI elements remain fully opaque.
(defvar my/doom-transparent-background t)

(defun my/toggle-doom-transparent-background ()
  "Toggle transparency of the current and future graphical Emacs frames."
  (interactive)
  (setq my/doom-transparent-background
        (not my/doom-transparent-background))
  (let ((alpha-background (if my/doom-transparent-background 0 100))
        ;; alpha-background is the precise option, while alpha provides a
        ;; fallback for X toolkits/compositors that do not honor it reliably.
        (alpha (if my/doom-transparent-background '(90 . 90) '(100 . 100))))
    (dolist (frame (frame-list))
      (set-frame-parameter frame 'alpha-background alpha-background)
      (set-frame-parameter frame 'alpha alpha))
    (setq default-frame-alist
          (assq-delete-all 'alpha-background default-frame-alist))
    (setq default-frame-alist
          (assq-delete-all 'alpha default-frame-alist))
    (push `(alpha-background . ,alpha-background) default-frame-alist)
    (push `(alpha . ,alpha) default-frame-alist)
    (message "Emacs background transparency %s"
             (if my/doom-transparent-background "enabled" "disabled"))))

(setq default-frame-alist
      (assq-delete-all 'alpha-background default-frame-alist))
(setq default-frame-alist
      (assq-delete-all 'alpha default-frame-alist))
(push '(alpha-background . 0) default-frame-alist)
(push '(alpha . (90 . 90)) default-frame-alist)

(map! :leader "t o" #'my/toggle-doom-transparent-background)

;; Add local bin directory to Emacs's PATH
(setenv "PATH" (concat (getenv "PATH") ":/home/tetra/.local/bin"))
(add-to-list 'exec-path "/home/tetra/.local/bin")

(use-package! evil
  :defer t
  :config
  (setq +evil-want-o/O-to-continue-comments nil))

(use-package! evil-owl
  :hook (doom-first-input . evil-owl-mode)
  :config
  (setq evil-owl-display-method 'posframe
        evil-owl-extra-posframe-args '(:width 50 :height 30)
        evil-owl-max-string-length 50))

(use-package! doom-modeline
  :defer t
  :config
  (setq doom-modeline-height 15))

(use-package! dired-x
  :config
  (setq dired-omit-files
        (concat dired-omit-files "\\|^\\..*$")))


(use-package! treemacs
  :defer t
  :config
  (setq treemacs-text-scale -2))

(use-package! projectile
  :defer t
  :config
  (setq projectile-run-use-comint-mode t))

;; ---------------------------------------------------------------------------
;; Writing / spelling
;; ---------------------------------------------------------------------------
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
  :hook (text-mode . mixed-pitch-mode))

;; ---------------------------------------------------------------------------
;; Dashboard behavior
;; ---------------------------------------------------------------------------
;; Let new buffers replace the Doom dashboard in new frames.
(defun my/doom-dashboard-replaceable (&rest _)
  "Make the *doom* buffer's window not dedicated so other buffers can replace it."
  (when (string= (buffer-name) "*doom*")
    (set-window-dedicated-p (selected-window) nil)))

(add-hook 'window-configuration-change-hook #'my/doom-dashboard-replaceable)

;; ---------------------------------------------------------------------------
;; Org mode
;; ---------------------------------------------------------------------------
(defconst my/org-root-dir "/media/sync/gtd/")
(defconst my/org-system-dir (expand-file-name "sistema/" my/org-root-dir))
(defconst my/org-ideas-dir (expand-file-name "ideas/" my/org-root-dir))
(defconst my/org-inbox-file (expand-file-name "inbox.org" my/org-system-dir))
(defconst my/org-tasks-file (expand-file-name "tareas.org" my/org-system-dir))
(defconst my/org-projects-file (expand-file-name "proyectos.org" my/org-system-dir))
(defconst my/org-agenda-file (expand-file-name "agenda.org" my/org-system-dir))
(defconst my/org-routines-file (expand-file-name "rutinas.org" my/org-system-dir))
(defconst my/org-project-ideas-file (expand-file-name "proyectos.org" my/org-ideas-dir))
(defconst my/org-learning-file (expand-file-name "aprendizaje.org" my/org-ideas-dir))
(defconst my/org-reflections-file (expand-file-name "reflexiones.org" my/org-ideas-dir))
(defconst my/org-trash-file (expand-file-name "trash.org" my/org-root-dir))
(defconst my/org-bibliography-file (expand-file-name "biblio.bib" my/org-root-dir))
(defconst my/org-journal-dir (expand-file-name "journal/" my/org-root-dir))

(defun my/org-agenda-skip-if-in-section (section)
  "Skip the current subtree when it lives under SECTION."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (path (org-get-outline-path t t)))
    (when (member section path)
      subtree-end)))

(defun my/org-agenda-skip-unless-in-section (section)
  "Skip the current subtree unless it lives under SECTION."
  (let ((subtree-end (save-excursion (org-end-of-subtree t)))
        (path (org-get-outline-path t t)))
    (unless (member section path)
      subtree-end)))

(defun my/org-agenda-skip-active-backlog ()
  "Skip paused tasks and anything already on the calendar."
  (or (my/org-agenda-skip-if-in-section "En pausa / revisar semanalmente")
      (org-agenda-skip-entry-if 'scheduled 'deadline)))

(use-package! org
  :defer t
  :config
  (setq org-directory my/org-root-dir
        org-use-fast-todo-selection 'expert
        org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "HOLD(h@/!)" "|" "DONE(d!)" "CANCELLED(c@)"))
        org-todo-keyword-faces '(("NEXT" . org-warning)
                                 ("WAIT" . shadow)
                                 ("HOLD" . shadow)
                                 ("CANCELLED" . shadow))
        org-log-done 'time
        org-log-redeadline 'time
        org-log-reschedule 'time
        org-default-notes-file my/org-inbox-file
        org-agenda-files (list my/org-inbox-file
                               my/org-tasks-file
                               my/org-projects-file
                               my/org-agenda-file
                               my/org-routines-file
                               my/org-project-ideas-file
                               my/org-learning-file
                               my/org-reflections-file)
        org-agenda-window-setup 'current-window
        org-agenda-start-with-log-mode t
        org-deadline-warning-days 7
        org-agenda-block-separator ?─
        org-refile-use-outline-path 'file
        org-outline-path-complete-in-steps nil
        org-refile-targets `((,my/org-tasks-file :maxlevel . 3)
                             (,my/org-projects-file :maxlevel . 2)
                             (,my/org-agenda-file :maxlevel . 1)
                             (,my/org-project-ideas-file :maxlevel . 2)
                             (,my/org-learning-file :maxlevel . 2)
                             (,my/org-reflections-file :maxlevel . 2))
        org-capture-templates
        `(("i" "Inbox / tarea" entry
           (file+headline ,my/org-inbox-file "Tareas")
           "* %?\n%U\n")
          ("I" "Inbox / idea" entry
           (file+headline ,my/org-inbox-file "Ideas")
           "* %?\n%U\n")
          ("A" "Inbox / aprendizaje" entry
           (file+headline ,my/org-inbox-file "Aprendizaje")
           "* %?\n%U\n")
          ("l" "Inbox / link" entry
           (file+headline ,my/org-inbox-file "Links")
           "* %?\n%U\n%a\n")
          ("d" "Diario de sueños" entry
           (file+datetree "/media/sync/roam/20250918133306-suenos.org")
           "* %U\n%?"))
        org-agenda-custom-commands
        `(("g" "GTD dashboard"
           ((agenda ""
                    ((org-agenda-span 1)
                     (org-agenda-overriding-header "Hoy")))
            (tags "LEVEL=2"
                  ((org-agenda-files (list ,my/org-inbox-file))
                   (org-agenda-overriding-header "Inbox por procesar")))
            (todo "NEXT"
                  ((org-agenda-files (list ,my/org-tasks-file))
                   (org-agenda-skip-function '(my/org-agenda-skip-if-in-section "En pausa / revisar semanalmente"))
                   (org-agenda-overriding-header "Siguientes acciones")))
            (todo "TODO"
                  ((org-agenda-files (list ,my/org-tasks-file))
                   (org-agenda-skip-function #'my/org-agenda-skip-active-backlog)
                   (org-agenda-overriding-header "Backlog activo")))
            (tags "STATUS=\"active\""
                  ((org-agenda-files (list ,my/org-projects-file))
                   (org-agenda-overriding-header "Proyectos activos")))))
          ("n" "Siguientes acciones"
           ((todo "NEXT"
                  ((org-agenda-files (list ,my/org-tasks-file))
                   (org-agenda-skip-function '(my/org-agenda-skip-if-in-section "En pausa / revisar semanalmente"))
                   (org-agenda-overriding-header "Todas las siguientes acciones")))))
          ("r" "Revisión semanal"
           ((agenda ""
                    ((org-agenda-span 7)
                     (org-agenda-start-on-weekday 1)
                     (org-agenda-overriding-header "Semana")))
            (tags "LEVEL=2"
                  ((org-agenda-files (list ,my/org-inbox-file))
                   (org-agenda-overriding-header "Inbox")))
            (tags "STATUS=\"active\""
                  ((org-agenda-files (list ,my/org-projects-file))
                   (org-agenda-overriding-header "Proyectos activos")))
            (todo "NEXT|TODO"
                  ((org-agenda-files (list ,my/org-tasks-file))
                   (org-agenda-skip-function '(my/org-agenda-skip-if-in-section "En pausa / revisar semanalmente"))
                   (org-agenda-overriding-header "Tareas activas")))
            (todo "NEXT|TODO"
                  ((org-agenda-files (list ,my/org-tasks-file))
                   (org-agenda-skip-function '(my/org-agenda-skip-unless-in-section "En pausa / revisar semanalmente"))
                   (org-agenda-overriding-header "En pausa / revisar semanalmente")))
            (tags "STATUS=\"paused\""
                  ((org-agenda-files (list ,my/org-projects-file))
                   (org-agenda-overriding-header "Proyectos en pausa")))))))


  (add-to-list 'org-modules 'org-habit)
  (add-to-list 'org-modules 'org-depend))

(use-package! org-roam
  :defer t
  :config
  (setq org-roam-directory "/media/sync/roam")
  (setq org-roam-completion-everywhere t)
  (setq org-roam-mode-sections
        (list #'org-roam-backlinks-section
              #'org-roam-reflinks-section
              #'org-roam-unlinked-references-section)))

(use-package! org-journal
  :defer t
  :config
  (setq org-journal-dir my/org-journal-dir
        org-journal-enable-agenda-integration t
        org-journal-file-type 'weekly
        org-journal-file-format "%Y%m%d.org"
        org-icalendar-store-UID t
        org-icalendar-include-todo "all"
        org-icalendar-combined-agenda-file "/media/sync/gtd/cal.ics")
  (add-to-list 'org-agenda-files org-journal-dir))

(use-package! org-node
  :defer t
  :init
  (keymap-set global-map "M-o" org-node-global-prefix-map)
  (with-eval-after-load 'org
    (keymap-set org-mode-map "M-o" org-node-org-prefix-map))
  :config
  (setq org-mem-do-sync-with-org-id t)
  (setq org-mem-watch-dirs
        (list "/media/sync/roam/" "/media/uni/" "/media/sync/gtd/"))
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

(use-package! org-krita
  :config
  (add-hook 'org-mode-hook 'org-krita-mode))

(use-package! reftex
  :defer t
  :config
  (setq reftex-default-bibliography my/org-bibliography-file))

;; ---------------------------------------------------------------------------
;; AI / gptel / llm
;; ---------------------------------------------------------------------------
(after! gptel
  (setq gptel-default-mode 'org-mode)
  (gptel-make-openai "ChatGPT"
    :key (lambda () (my/auth-source-secret "api.openai.com"))
    :stream t)
  ;; (gptel-make-gemini "Gemini"
  ;;   :key (lambda () (my/auth-source-secret "generativelanguage.google.com"))
  ;;   :stream t)
  )

(use-package! aidermacs
  :bind (("C-c a" . aidermacs-transient-menu))
  :config
  (setenv "OPENAI_API_KEY" (my/auth-source-secret "api.openai.com"))
  :custom
  (aidermacs-default-chat-mode 'architect)
  (aidermacs-default-model "openai/gpt-5.6-luna"))

;; Use agent-shell with Pi through the ACP adapter.  npx downloads the pinned
;; adapter on first use and then reuses npm's local cache.
(use-package! agent-shell
  :commands (agent-shell-pi-start-agent)
  :init
  (setq agent-shell-pi-acp-command
        '("npx" "--yes" "--package" "pi-acp@0.0.33" "pi-acp"))
  :bind (("C-c A" . agent-shell-pi-start-agent)))

;; ---------------------------------------------------------------------------
;; Programming / LSP / DAP
;; ---------------------------------------------------------------------------
;; Doom is configured to use Eglot rather than lsp-mode.  Register the
;; Nix-provided basedpyright executable explicitly; Eglot will not infer this
;; replacement from the lsp-mode-specific `lsp-pyright' setting.
(set-eglot-client! '(python-mode python-ts-mode)
                   '("basedpyright-langserver" "--stdio"))

(after! dap-mode
  (setq dap-python-debugger 'debugpy))

(use-package! emacs-pet
  :defer t
  :config
  (add-hook 'python-base-mode-hook #'pet-mode))

(use-package! eglot-java
  :defer t
  :config
  (add-hook 'java-mode-hook 'eglot-java-mode))

(use-package! platformio-mode
  :defer t
  :config
  (add-hook 'c++-mode-hook (lambda ()
                             (eglot-ensure)
                             (platformio-conditionally-enable))))

(use-package! glsl-mode
  :defer t)

(use-package! pddl-mode
  :defer t)

(use-package! gams-mode
  :defer t
  :config
  (setq gams-process-command-name "/home/tetra/prog/gams/gams47.6_linux_x64_64_sfx/gams"))

(use-package! leetcode
  :defer t
  :config
  (setq leetcode-language "cpp"))

;; ---------------------------------------------------------------------------
;; Misc utilities
;; ---------------------------------------------------------------------------
(use-package! elfeed
  :defer t
  :config
  (add-hook 'elfeed-search-mode-hook #'elfeed-update))

(use-package! calibredb
  :defer t
  :config
  (setq calibredb-root-dir "/media/books")
  (setq calibredb-db-dir (expand-file-name "metadata.db" calibredb-root-dir)))

(use-package! pomm
  :defer t
  :config
  (setq pomm-mode-line-mode t)
  (setq alert-default-style 'libnotify)
  (pomm-mode-line-mode))

(use-package! anki-editor
  :defer t)
