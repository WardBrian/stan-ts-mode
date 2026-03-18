;;; stan-ts-mode.el --- Major mode for editing Stan files -*- lexical-binding: t -*-

;; Copyright (C) 2023-2026 Simons Foundation

;; Author: Brian Ward <bward@flatironinstitute.org>
;; Version: 1.0
;; Package-Requires: ((emacs "30.1"))
;; Keywords: stan languages tree-sitter
;; URL: https://github.com/WardBrian/stan-ts-mode
;; SPDX-License-Identifier: BSD-3-Clause

;;; Commentary:
;; This package provides tree-sitter powered syntax highlighting
;; for the Stan programming language (https://mc-stan.org/).


;;; Code:

(require 'treesit)

;; TODO: In emacs 31.1+, use treesit-ensure-installed instead of treesit-ready-p
;; (add-to-list
;;  'treesit-language-source-alist
;;  '(stan . ("https://github.com/WardBrian/tree-sitter-stan" "v0.3.0" "grammars/stan/src"))
;;  t)
;; (add-to-list
;;  'treesit-language-source-alist
;;  '(stanfunctions . ("https://github.com/WardBrian/tree-sitter-stan" "v0.3.0" "grammars/stanfunctions/src"))
;;  t)

(defcustom stan-ts-mode-indent-offset 2
  "Number of spaces for each indentation step in `stan-ts-mode'."
  :type 'integer
  :group 'stan)

(defun stan-ts-mode--treesit-types (language)
  (append
   '("data"
     "int"
     "real"
     "complex"
     "array"
     "tuple"
     "vector"
     "void"
     )
   (when (eq language 'stan)
     '(
       "simplex"
       "unit_vector"
       "sum_to_zero_vector"
       "ordered"
       "positive_ordered"
       "row_vector"
       "matrix"
       "complex_vector"
       "complex_matrix"
       "complex_row_vector"
       "corr_matrix"
       "cov_matrix"
       "cholesky_factor_cov"
       "cholesky_factor_corr"
       "column_stochastic_matrix"
       "row_stochastic_matrix"
       "sum_to_zero_matrix"))))

(defvar stan-ts-mode--treesit-operators
  '(
    "||"
    "&&"
    "=="
    "!="
    "<"
    "<="
    ">"
    ">="
    "+"
    "-"
    "*"
    "/"
    "%"
    "\\"
    ".^"
    "%/%"
    ".*"
    "./"
    "!"
    "-"
    "+"
    "^"
    "'"
    "~"
    "="
    "+="
    "-="
    "*="
    "/="
    ".*="
    "./="))

(defun stan-ts-mode--treesit-settings (language)
  "Tree-sitter font lock settings."
  (append
   (treesit-font-lock-rules

    :feature 'comment
    :language language
    '((comment) @font-lock-comment-face)

    :feature 'string
    :language language
    '((string_literal) @font-lock-string-face)

    :feature 'operator
    :language language
    `([,@stan-ts-mode--treesit-operators] @font-lock-operator-face
      (assignment_op) @font-lock-operator-face)


    :feature 'bracket
    :language language
    '(["(" ")" "[" "]" "{" "}" "<" ">"] @font-lock-bracket-face)

    :feature 'delimiter
    :language language
    '(["," "|" ";"] @font-lock-delimiter-face)

    :feature 'definition
    :language language
    '(
      (function_declarator
       name: (identifier) @font-lock-function-name-face)
      (for_statement
       loopvar: (identifier) @font-lock-variable-name-face)
      (parameter_declaration
       parameter: (identifier) @font-lock-variable-name-face)
      (var_decl name: (identifier) @font-lock-variable-name-face))

    :feature 'function
    :language language
    '(
      (function_expression
       name: (identifier) @font-lock-function-call-face)
      (distr_expression
       name: (identifier) @font-lock-function-call-face)
      (sampling_statement
       name: (identifier) @font-lock-function-call-face)
      (print_statement
       "print" @font-lock-function-call-face)
      (reject_statement
       "reject" @font-lock-function-call-face)
      (fatal_error_statement
       "fatal_error" @font-lock-function-call-face)
      (function_statement
       name: (identifier) @font-lock-function-call-face))

    :feature 'type
    :language language
    `([,@(stan-ts-mode--treesit-types language)]  @font-lock-type-face)

    :feature 'number
    :language language
    '([(integer_literal) (real_literal) (imag_literal)] @font-lock-number-face)

    :feature 'keyword
    :language language
    '(["break"
       "continue"
       "while"
       "for"
       "if"
       "else"
       "return"] @font-lock-keyword-face
       (profile_statement "profile" @font-lock-keyword-face)
       (target_statement "target" @font-lock-keyword-face)
       (jacobian_statement "jacobian" @font-lock-keyword-face))

    :feature 'preprocessor
    :language language
    '((preproc_include) @font-lock-preprocessor-face)

    :feature 'variable
    :language language
    '((identifier) @font-lock-variable-use-face)

    :feature 'error
    :language language
    :override t
    '((ERROR) @font-lock-warning-face))
   (when (eq language 'stan)
     ;; some nodes are only present in full Stan files
     (treesit-font-lock-rules
      :feature 'definition
      :language 'stan
      '(
        (top_var_decl name: (identifier) @font-lock-variable-name-face)
        (top_var_decl_no_assign name: (identifier) @font-lock-variable-name-face))

      :feature 'constraints
      :language 'stan
      '(["lower" "upper" "offset" "multiplier"] @font-lock-property-name-face)

      :feature 'block
      :language 'stan
      '(
        (functions "functions" @font-lock-keyword-face)
        (data "data" @font-lock-keyword-face)
        (transformed_data "transformed data" @font-lock-keyword-face)
        (parameters "parameters" @font-lock-keyword-face)
        (transformed_parameters "transformed parameters" @font-lock-keyword-face)
        (model "model" @font-lock-keyword-face)
        (generated_quantities "generated quantities" @font-lock-keyword-face))))))


(defun stan-ts-mode--indent-rules (language)
  `((,language
     ;; Top-level: column 0
     ((parent-is "program") column-0 0)

     ;; Closing brackets align with parent
     ((node-is "}") parent-bol 0)
     ((node-is ")") parent-bol 0)
     ((node-is "]") parent-bol 0)

     ;; Program blocks (data { ... }, model { ... }, etc.)
     ((parent-is "functions") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "data") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "transformed_data") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "parameters") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "transformed_parameters") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "model") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "generated_quantities") parent-bol ,stan-ts-mode-indent-offset)

     ;; Braced block statements ({ ... })
     ((parent-is "block_statement") parent-bol ,stan-ts-mode-indent-offset)

     ;; Control flow bodies
     ((parent-is "for_statement") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "while_statement") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "if_statement") parent-bol ,stan-ts-mode-indent-offset)

     ;; Function definitions
     ((parent-is "function_definition") parent-bol ,stan-ts-mode-indent-offset)

     ;; Profile blocks
     ((parent-is "profile_statement") parent-bol ,stan-ts-mode-indent-offset)

     ;; Argument lists (multi-line function calls)
     ((parent-is "argument_list") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "distr_argument_list") parent-bol ,stan-ts-mode-indent-offset)
     ((parent-is "parameter_list") parent-bol ,stan-ts-mode-indent-offset)

     ;; Fallback
     (no-node parent-bol 0)))
  "Tree-sitter indent rules for Stan.")

(defvar stan-ts-mode--syntax-table
  (let ((table (make-syntax-table)))
    ;; Adapted from c-ts-mode
    (modify-syntax-entry ?_  "_"     table)
    (modify-syntax-entry ?+  "."     table)
    (modify-syntax-entry ?-  "."     table)
    (modify-syntax-entry ?=  "."     table)
    (modify-syntax-entry ?%  "."     table)
    (modify-syntax-entry ?<  "."     table)
    (modify-syntax-entry ?>  "."     table)
    (modify-syntax-entry ?&  "."     table)
    (modify-syntax-entry ?|  "."     table)
    (modify-syntax-entry ?\; "."     table)
    (modify-syntax-entry ?'  "."     table)
    (modify-syntax-entry ?/  ". 124b" table)
    (modify-syntax-entry ?*  ". 23"   table)
    (modify-syntax-entry ?\n "> b"  table)
    (modify-syntax-entry ?\^m "> b" table)
    table)
  "Syntax table for `stan-ts-mode'.")


(define-derived-mode stan-ts-base-mode prog-mode "Stan"
  "Base mode for editing Stan, powered by tree-sitter."
  :syntax-table stan-ts-mode--syntax-table
  ;; Comment syntax
  (setq-local comment-start "// ")
  (setq-local comment-end "")
  (setq-local comment-start-skip "//+\\s-*")

  ;; Indentation
  (setq-local indent-tabs-mode nil)
  (setq-local tab-width 2)

  ;; Electric
  (setq-local electric-indent-chars
              (append "{}()" electric-indent-chars))

  (setq-local treesit-font-lock-feature-list
              ;; the 4 lists here correspond to different settings of treesit-font-lock-level
              '((comment block definition)
                (keyword preprocessor string type)
                (number constraints function)
                (operator bracket delimiter variable error))))

(defun stan-ts-mode--setup-mode (language)
  (when (treesit-ready-p language)
    (let ((parser (treesit-parser-create language)))
      (when (boundp 'treesit-primary-parser)
        (setq-local treesit-primary-parser parser)))
    (setq-local treesit-simple-indent-rules (stan-ts-mode--indent-rules language))
    (setq-local treesit-font-lock-settings (stan-ts-mode--treesit-settings language))
    (treesit-major-mode-setup)))

;;;###autoload
(define-derived-mode stan-ts-mode stan-ts-base-mode "Stan"
  "Major mode for editing Stan, powered by tree-sitter.

\\{stan-ts-base-mode-map}"
  (stan-ts-mode--setup-mode 'stan))

;;;###autoload
(define-derived-mode stan-functions-ts-mode stan-ts-base-mode "Stan [functions]"
  "Major mode for editing Stan Functions files, powered by tree-sitter.

\\{stan-ts-base-mode-map}"
  (stan-ts-mode--setup-mode 'stanfunctions)
  )


;;;###autoload
(progn
  (unless (treesit-ready-p 'stan)
    (user-error "Error: stan-ts-mode cannot be activated. Ensure tree-sitter and tree-sitter-stan are installed"))
  (add-to-list 'auto-mode-alist '("\\.stan\\'" . stan-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.stanfunctions\\'" . stan-functions-ts-mode)))

(put 'stan-ts-base-mode 'eglot-language-id "stan")
(put 'stan-ts-mode 'eglot-language-id "stan")
(put 'stan-functions-ts-mode 'eglot-language-id "stan")

(provide 'stan-ts-mode)
;;; stan-ts-mode.el ends here
