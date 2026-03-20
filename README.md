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
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; can also pull from MELPA stable, if desired:
;; (add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)


(use-package treesit
  :if (treesit-available-p)
  :ensure nil
  :config
  (setq treesit-language-source-alist
      '((stan . ("https://github.com/WardBrian/tree-sitter-stan" "v0.3.0" "grammars/stan/src"))
        (stanfunctions . ("https://github.com/WardBrian/tree-sitter-stan" "v0.3.0" "grammars/stanfunctions/src"))))
  (unless (treesit-language-available-p 'stan)
    (treesit-install-language-grammar 'stan))
  (unless (treesit-language-available-p 'stanfunctions)
    (treesit-install-language-grammar 'stanfunctions)))

(use-package stan-ts-mode
  :requires treesit
  :mode (("\\.stan\\'" . stan-ts-mode) ("\\.stanfunctions\\'" . stan-functions-ts-mode))
  :defer t
  :ensure t)
```

We also recommend setting up `elgot` [with the `stan-language-server`](https://github.com/tomatitito/stan-language-server#emacs-eglot).


## Preview

![Screenshot of a demo file](https://user-images.githubusercontent.com/31640292/232508026-e3fe8406-a8b8-498f-824b-2968c46379cf.png)
