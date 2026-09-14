;; -*- no-byte-compile: t; -*-

(package! jinx :recipe  (:host github :repo "minad/jinx" :files (:defaults
                                                                 "jinx-mod.c" "emacs-module.h")))
(package! aidermacs)
(package! agent-shell
  :recipe (:host github :repo "xenodium/agent-shell"))
(package! evil-owl
  :recipe (:host github :repo "mamapanda/evil-owl"))
(package! platformio-mode)
(package! leetcode)
(package! calibredb)
(package! mixed-pitch)
(package! anki-editor)
(package! ov)
(package! pomm :recipe (:host github :repo "SqrtMinusOne/pomm.el"))
(package! eglot-java)
(package! glsl-mode)
(package! gams-mode)
(package! pet)
(package! pddl-mode)
(package! org-node)
(package! org-transclusion)
(package! ef-themes)

(package! org-krita
  :recipe (:host github
           :repo "lepisma/org-krita"
           :files ("resources" "resources" "*.el" "*.el")))

