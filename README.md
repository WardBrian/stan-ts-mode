# stan-ts-mode

[![MELPA](https://melpa.org/packages/stan-ts-mode-badge.svg)](https://melpa.org/#/stan-ts-mode) [![MELPA Stable](https://stable.melpa.org/packages/stan-ts-mode-badge.svg)](https://stable.melpa.org/#/stan-ts-mode)

A major mode for editing Stan files in Emacs based
on [tree-sitter-stan](https://github.com/WardBrian/tree-sitter-stan).

It works well when [paired with the `stan-language-server`](https://github.com/tomatitito/stan-language-server#emacs-eglot).

## Usage

When using Emacs 29+ ensure you have [compiled with treesit support](https://www.masteringemacs.org/article/how-to-get-started-tree-sitter).

The following `init.el` snippet is what I use:

```emacs-lisp
(require 'package)
;; if using eglot, recommend using the latest from GNU ELPA
(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)

;; for stan-ts-mode
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; can also pull from MELPA stable, if desired:
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)


(use-package treesit
  :if (treesit-available-p))

(use-package stan-ts-mode
  :requires treesit
  :mode ("\\.stan\\'" "\\.stanfunctions\\'")
  :defer t
  :init
  (add-to-list 'treesit-language-source-alist '(stan .
  ("https://github.com/WardBrian/tree-sitter-stan" "v0.3.0" "grammars/stan/src")))
  (unless (treesit-language-available-p 'stan)
    (treesit-install-language-grammar 'stan))
  (add-to-list 'treesit-language-source-alist '(stanfunctions .
  ("https://github.com/WardBrian/tree-sitter-stan" "v0.3.0" "grammars/stanfunctions/src")))
  (unless (treesit-language-available-p 'stanfunctions)
    (treesit-install-language-grammar 'stanfunctions)))


;; if you also want to use https://github.com/tomatitito/stan-language-server

(use-package eglot
  :ensure t
  :demand t
  :pin gnu
  :hook (stan-ts-mode . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs '(stan-ts-mode . ("PATH/TO/stan-language-server" "--stdio"))))
```

## Preview

![Screenshot of a demo file](https://user-images.githubusercontent.com/31640292/232508026-e3fe8406-a8b8-498f-824b-2968c46379cf.png)
