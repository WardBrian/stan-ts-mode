;;; stan-mode.el --- Major mode for editing Stan files -*- lexical-binding: t; -*-

;; see
;; https://github.com/emacs-mirror/emacs/blob/master/lisp/progmodes/python.el
;; https://github.com/emacs-mirror/emacs/blob/master/lisp/progmodes/go-ts-mode.el
;; https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide

(require 'treesit)

(defvar stan--treesit-types
  '("data"
    "int"
    "real"
    "complex"
    "array"
    "vector"
    "simplex"
    "unit_vector"
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
    "void"))

(defvar stan--treesit-operators
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
    "./="
    )
  )

(defvar stan--treesit-settings
  (treesit-font-lock-rules
   :feature 'block
   :language 'stan
   '(
     (functions "functions" @font-lock-keyword-face)
     (data "data" @font-lock-keyword-face)
     (transformed_data "transformed data" @font-lock-keyword-face)
     (parameters "parameters" @font-lock-keyword-face)
     (transformed_parameters "transformed parameters" @font-lock-keyword-face)
     (model "model" @font-lock-keyword-face)
     (generated_quantities "generated quantities" @font-lock-keyword-face)
     )

   :feature 'comment
   :language 'stan
   '((comment) @font-lock-comment-face)

   :feature 'string
   :language 'stan
   '((string_literal) @font-lock-string-face)

   :feature 'operator
   :language 'stan
   `([,@stan--treesit-operators] @font-lock-operator-face)


   :feature 'bracket
   :language 'stan
   '(["(" ")" "[" "]" "{" "}" "<" ">"] @font-lock-bracket-face)

   :feature 'delimiter
   :language 'stan
   '(["," "|" ";"] @font-lock-delimiter-face)

   :feature 'definition
   :language 'stan
   '(
     (function_declarator
      name: (identifier) @font-lock-function-name-face)
     (for_statement
      loopvar: (identifier) @font-lock-variable-name-face)
     (parameter_declaration
      parameter: (identifier) @font-lock-variable-name-face)
     (var_decl name: (identifier) @font-lock-variable-name-face)
     (top_var_decl name: (identifier) @font-lock-variable-name-face)
     (top_var_decl_no_assign name: (identifier) @font-lock-variable-name-face))

   :feature 'function
   :language 'stan
   '(
     (function_expression
      name: (identifier) @font-lock-function-call-face)
     (distr_expression
      name: (identifier) @font-lock-function-call-face)
     (print_statement
      "print" @font-lock-function-call-face)
     (reject_statement
      "reject" @font-lock-function-call-face))

   :feature 'type
   :language 'stan
   `([,@stan--treesit-types]  @font-lock-type-face)

   :feature 'number
   :language 'stan
   '([(integer_literal) (real_literal) (imag_literal)] @font-lock-number-face)

   :feature 'keyword
   :language 'stan
   '(["break"
      "continue"
      "while"
      "for"
      "if"
      "else"
      "return"] @font-lock-keyword-face
      (profile_statement "profile" @font-lock-keyword-face))

   :feature 'preprocessor
   :language 'stan
   '((preproc_include) @font-lock-preprocessor-face)

   :feature 'constraints
   :language 'stan
   '(["lower" "upper" "offset" "multiplier"] @font-lock-property-name-face)

   :feature 'variable
   :language 'stan
   '((identifier) @font-lock-variable-use-face)
   )
  "Tree-sitter font lock settings"
  )


(define-derived-mode stan-ts-mode prog-mode "Stan"
  (when (treesit-ready-p 'stan)
    (treesit-parser-create `stan)
    (setq-local treesit-font-lock-feature-list
                ;; the 4 lists here correspond to different settings of treesit-font-lock-level
                '((comment block definition)
                  (keyword preprocessor string type)
                  (number constraints)
                  (operator bracket delimiter function variable)))
    (setq-local treesit-font-lock-settings stan--treesit-settings)
    (treesit-major-mode-setup)))

(when (treesit-ready-p 'stan)
  (add-to-list 'auto-mode-alist '("\\.stan\\'" . stan-ts-mode)))

(provide 'stan-ts-mode)
