;; -*- no-byte-compile: t; -*-
;; (package! transient :pin "c2bdf7e12c530eb85476d3aef317eb2941ab9440")
;; (package! with-editor :pin "391e76a256aeec6b9e4cbd733088f30c677d965b")

(package! jinx :recipe  (:host github :repo "minad/jinx" :files (:defaults
                                                                 "jinx-mod.c" "emacs-module.h")))
(package! aidermacs)
(package! org-edna)
(package! ement)
(package! benchmark-init)
(package! eglot)
(package! epl)
(package! evil-owl
  :recipe (:host github :repo "mamapanda/evil-owl"))
(package! evil-numbers)
(package! org-download)
(package! info-colors)
(package! evil-god-state)
(package! ewal)
(package! nhexl-mode)
(package! magit-todos)
(package! org-ql)
(package! cdlatex)
(package! eat)
(package! platformio-mode)
(package! leetcode)
(package! ewal-doom-themes)
(package! ewal-evil-cursors)
(package! solaire-mode)
(package! impatient-mode)
(package! calibredb)
;; (package! visual-fill-column)
(package! mixed-pitch)
(package! nov)
(package! affe)
;; (package! scroll-on-jump)
(package! websocket)
(package! anki-editor)
(package! ov)
(package! vlf)
;; (package! gnuplot)
(package! olivetti)
(package! org-roam-ui :recipe (:host github :repo "org-roam/org-roam-ui" :files ("*.el" "out")))
(package! org-xournalpp
  :recipe (:host gitlab
           :repo "vherrmann/org-xournalpp"
           :files ("resources" "*.el")))
;; (package! corfu)
;; (package! cape)
(package! graphviz-dot-mode)
(package! yasnippet-snippets)
(package! consult-dir)
(package! kind-icon)
(package! modus-themes)
(package! pomm :recipe (:host github :repo "SqrtMinusOne/pomm.el"))
(package! pkg-info)
;; (package! ftable)
(package! topspace
  :recipe (:host github
           :repo "trevorpogue/topspace"))
(package! eglot-java)
(package! glsl-mode)
(package! gams-mode)
(package! pet)
(package! pddl-mode)
(package! org-node)
(package! org-transclusion)
(package! spacious-padding)
(package! ef-themes)
(package! typst-ts-mode)
(package! polymode)


(package! org-krita
  :recipe (:host github
           :repo "lepisma/org-krita"
           :files ("resources" "resources" "*.el" "*.el")))

