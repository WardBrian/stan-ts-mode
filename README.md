# stan-ts-mode

[![MELPA](https://melpa.org/packages/stan-ts-mode-badge.svg)](https://melpa.org/#/stan-ts-mode)

A major mode for editing Stan files in Emacs based
on [tree-sitter-stan](https://github.com/WardBrian/tree-sitter-stan).

It works well when [paired with the `stan-language-server`](https://github.com/tomatitito/stan-language-server#emacs-eglot).

This is still a work in progress.

## Usage

When using Emacs 29+ ensure you have [compiled with treesit support](https://www.masteringemacs.org/article/how-to-get-started-tree-sitter).

The following `init.el` snippet is what I use:

```emacs-lisp
  (when (treesit-available-p)
    (require 'treesit)
    (setq treesit-font-lock-level 4)
    (setq treesit-language-source-alist
          '((stan . ("https://github.com/WardBrian/tree-sitter-stan"))
            ; other languages here
            ))

    ; could also use https://github.com/renzmann/treesit-auto or similar
    (defun bmw/treesit-install-all-languages ()
      "Install all languages specified by `treesit-language-source-alist'."
      (interactive)
      (let ((languages (mapcar 'car treesit-language-source-alist)))
        (dolist (lang languages)
          (unless (treesit-language-available-p lang)
            (treesit-install-language-grammar lang)
            (message "`%s' parser was installed." lang)
            (sit-for 0.75))
          )))
    (bmw/treesit-install-all-languages)

    ;; (load-file "PATH/TO/stan-ts-mode.el")
    ;; OR
    ;; (use-package stan-ts-mode :ensure t) ;; requires MELPA in your package-archives list
    )
```

## Preview

![Screenshot of a demo file](https://user-images.githubusercontent.com/31640292/232508026-e3fe8406-a8b8-498f-824b-2968c46379cf.png)
