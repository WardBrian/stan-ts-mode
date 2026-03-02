;;; stan-mode.el --- Major mode for editing Stan files -*- lexical-binding: t; -*-

;; see
;; https://github.com/emacs-mirror/emacs/blob/master/lisp/progmodes/python.el
;; https://github.com/emacs-mirror/emacs/blob/master/lisp/progmodes/go-ts-mode.el
;; https://git.savannah.gnu.org/cgit/emacs.git/tree/admin/notes/tree-sitter/starter-guide

(require 'treesit)

(defcustom stan-ts-mode-indent-offset 2
  "Number of spaces for each indentation step in `stan-ts-mode'."
  :type 'integer
  :group 'stan)

(defvar stan--treesit-types
  '("data"
    "int"
    "real"
    "complex"
    "array"
    "tuple"
    "vector"
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
    "sum_to_zero_matrix"
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
   `([,@stan--treesit-operators] @font-lock-operator-face
     (assignment_op) @font-lock-operator-face)


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
      (profile_statement "profile" @font-lock-keyword-face)
      (target_statement "target" @font-lock-keyword-face)
      (jacobian_statement "jacobian" @font-lock-keyword-face))

   :feature 'preprocessor
   :language 'stan
   '((preproc_include) @font-lock-preprocessor-face)

   :feature 'constraints
   :language 'stan
   '(["lower" "upper" "offset" "multiplier"] @font-lock-property-name-face)

   :feature 'variable
   :language 'stan
   '((identifier) @font-lock-variable-use-face)

   :feature 'error
   :language 'stan
   :override t
   '((ERROR) @font-lock-warning-face)
   )
  "Tree-sitter font lock settings"
  )


(defvar stan-ts-mode--indent-rules
  `((stan
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

;;;###autoload
(define-derived-mode stan-ts-mode prog-mode "Stan"
  "Major mode for editing Stan, powered by tree-sitter

\\{stan-mode-map}"
  :syntax-table stan-ts-mode--syntax-table

  (when (treesit-ready-p 'stan)
    (treesit-parser-create `stan)

    ;; Comment syntax
    (setq-local comment-start "// ")
    (setq-local comment-end "")
    (setq-local comment-start-skip "//+\\s-*")

    ;; Indentation
    (setq-local indent-tabs-mode nil)
    (setq-local tab-width 2)
    (setq-local treesit-simple-indent-rules stan-ts-mode--indent-rules)

    ;; Electric
    (setq-local electric-indent-chars
                (append "{}()" electric-indent-chars))

    (setq-local treesit-font-lock-feature-list
                ;; the 4 lists here correspond to different settings of treesit-font-lock-level
                '((comment block definition)
                  (keyword preprocessor string type)
                  (number constraints function)
                  (operator bracket delimiter variable error)))
    (setq-local treesit-font-lock-settings stan--treesit-settings)
    (treesit-major-mode-setup)))

(when (treesit-ready-p 'stan)
  (add-to-list 'auto-mode-alist '("\\.stan\\'" . stan-ts-mode))
  (add-to-list 'auto-mode-alist '("\\.stanfunctions\\'" . stan-ts-mode)))

(provide 'stan-ts-mode)
