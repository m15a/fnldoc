;; fennel-ls: macro-file

;;;; Generate command line argument option recipes.
 
;;;; Macros defined here generate a table that maps command line argument
;;;; flag to its *recipe*, which will be used later in command line argument
;;;; parsing.

;;;; You can generate option recipes, for example, by
;;;; 
;;;; ```fennel :skip-test
;;;; (cooking
;;;;   (recipe :boolean :ramen
;;;;     "Whether you like to have ramen noodles")
;;;;   (recipe :category :taste :t [:shoyu :miso :tonkotsu]
;;;;     "Which type of ramen you like to have")
;;;;   (recipe :number :bowls :n :NUM
;;;;     "How many ramen bowls you like to have"))
;;;; ```
;;;; 
;;;; And, it yields
;;;; 
;;;; ```fennel :skip-test
;;;; {:--ramen {:description "--[no-]ramen\t\tWhether you like to have ramen noodles"
;;;;            :key :ramen?
;;;;            :value true}
;;;;  :--no-ramen {:key :ramen?
;;;;               :value false}
;;;;  :--taste {:description "-t, --taste\t[shoyu|miso|tonkotsu]\tWhich type of ramen you like to have (default: nil)"
;;;;            :key :taste
;;;;            :validator #<function: 0x7ffa16ead208>}
;;;;  :-t {:key :taste
;;;;       :validator #<function: 0x7ffa16e31310>}
;;;;  :--bowls {:description "-n, --bowls\tNUM\tHow many ramen bowls you like to have (default: nil)"
;;;;            :key :bowls
;;;;            :preprocessor #<function: builtin#17>
;;;;            :validator #<function: 0x7ffa16f984e8>}
;;;;  :-n {:key :bowls
;;;;       :preprocessor #<function: builtin#17>
;;;;       :validator #<function: 0x7ffa16de4a98>}}
;;;; ```
;;;; 
;;;; It gives you no dishes, only recipes, unfortunately.
;;;; 
;;;; A recipe is a table that possibly contains the following entries,
;;;; depending on the needs.
;;;; 
;;;; - `key`: Corresponding key name in Fnldoc's configuration loaded from
;;;;   `.fenneldoc`.
;;;; - `description`: Text that explain the flag, which will be shown in help.
;;;;   Flag(s), argument if any, and description are separated by tab (`\t`).
;;;; - `value`: Options that do not require argument (e.g., boolean flags)
;;;;   have this entry. Its value will be set at the `key`'s field in
;;;;   configuration. If `value` is missing, the next command line argument
;;;;   will be parsed and set into configuration, possibly after calling
;;;;   `preprocessor` and `validator`.
;;;; - `preprocessor`: Function that converts the next command line argument
;;;;   string to a value that can be set into configuration. Currently only
;;;;   used for number options.
;;;; - `validator`: Function that checks if preprocessed value is valid.
;;;;   Currently only used for category and number options.
 
;;;; Read the document of `recipe' for more details of various option recipe
;;;; types.

(local unpack (or table.unpack _G.unpack))
(local {: view} (require :fennel))
(local default-config (require :fnldoc.config.default))
(local {: assert-type} (require :fnldoc.utils.assert))
(local {: clone} (require :fnldoc.utils.table))

(fn assert-char [x]
  (assert (and (= :string (type x)) (= 1 (length x)))
          (string.format "1-length string expected, got %s" (view x))))

(fn assert-sequence [x]
  (assert (sequence? x) (string.format "sequential table expected, got %s"
                                       (view x))))

(fn boolean-description [{: name : short-name : default : description}]
  (if short-name
      (string.format "-%s, --[no-]%s\t\t%s (default: %s)"
                     short-name
                     name
                     description
                     default)
      (string.format "    --[no-]%s\t\t%s (default: %s)"
                     name
                     description
                     default)))

(fn boolean-recipe* [{: name : short-name : description}]
  (assert-type :string name)
  (when short-name
    (assert-char short-name))
  (assert-type :string description)
  (let [key (.. name :?)
        default (. default-config key)
        description (boolean-description {: name
                                          : short-name
                                          : default
                                          : description})
        positive-spec {: key
                       : description
                       :value true}
        negative-spec {: key
                       :value false}
        short-spec (doto (clone positive-spec)
                     (tset :description nil))]
    `(let [options# {}]
       (tset options# ,(.. "--" name) ,positive-spec)
       (tset options# ,(.. :--no- name) ,negative-spec)
       ,(when short-name
          `(tset options# ,(.. "-" short-name) ,short-spec))
       options#)))

(fn boolean-recipe [name ...]
  "Make a boolean option and corresponding negative (`--no-*`) counterpart."
  (case ...
    (short-name description)
    (boolean-recipe* {: name : short-name : description})
    (description)
    (boolean-recipe* {: name : description})
    _ (error "argument missing: description")))

(fn category-description [{: name : short-name : domain : default : description}]
  (let [domain (table.concat domain "|")]
    (if short-name
        (string.format "-%s, --%s\t[%s]\t%s (default: %s)"
                       short-name
                       name
                       domain
                       description
                       default)
        (string.format "    --%s\t[%s]\t%s (default: %s)"
                       name
                       domain
                       description
                       default))))

(fn category-validator [domain]
  (let [domain (collect [_ k (ipairs domain)] k true)]
    `(fn [x#] (or (. ,domain x#) false))))

(fn category-recipe* [{: name : short-name : domain : description}]
  (assert-type :string name)
  (when short-name
    (assert-char short-name))
  (assert-sequence domain)
  (each [_ k (ipairs domain)]
    (assert-type :string k))
  (assert-type :string description)
  (let [default (. default-config name)
        description (category-description {: name
                                           : short-name
                                           : domain
                                           : default
                                           : description})
        spec {:key name
              : description
              :validator (category-validator domain)}
        short-spec (doto (clone spec)
                     (tset :description nil))]
    `(let [options# {}]
       (tset options# ,(.. "--" name) ,spec)
       ,(when short-name
          `(tset options# ,(.. "-" short-name) ,short-spec))
       options#)))

(fn category-recipe [name ...]
  "Make a categorical option such like apple, orange, or banana."
  (case ...
    (short-name domain description)
    (category-recipe* {: name : short-name : domain : description})
    (domain description)
    (category-recipe* {: name : domain : description})
    nil (error "argument missing: domain and description")))

(fn string-description [{: name : short-name : var-name : default : description}]
  (if short-name
      (string.format "-%s, --%s\t%s\t%s (default: %s)"
                     short-name
                     name
                     (or var-name :TEXT)
                     description
                     default)
      (string.format "    --%s\t%s\t%s (default: %s)"
                     name
                     (or var-name :TEXT)
                     description
                     default)))

(fn string-recipe* [{: name : short-name : var-name : description}]
  (assert-type :string name)
  (when short-name
    (assert-char short-name))
  (assert-type :string var-name)
  (assert-type :string description)
  (let [default (. default-config name)
        description (string-description {: name
                                         : short-name
                                         : var-name
                                         : default
                                         : description})
        spec {:key name
              : description}
        short-spec (doto (clone spec)
                     (tset :description nil))]
    `(let [options# {}]
       (tset options# ,(.. "--" name) ,spec)
       ,(when short-name
          `(tset options# ,(.. "-" short-name) ,short-spec))
       options#)))

(fn string-recipe [name ...]
  "Make a simple string option."
  (case ...
    (short-name var-name description)
    (string-recipe* {: name : short-name : var-name : description})
    (var-name description)
    (string-recipe* {: name : var-name : description})
    nil (error "argument missing: VARNAME and description")))

(fn number-description [{: name : short-name : var-name : default : description}]
  (if short-name
      (string.format "-%s, --%s\t%s\t%s (default: %s)"
                     short-name
                     name
                     (or var-name :NUM)
                     description
                     default)
      (string.format "    --%s\t%s\t%s (default: %s)"
                     name
                     (or var-name :NUM)
                     description
                     default)))

(fn number-preprocessor []
  `tonumber)

(fn number-validator []
  `(fn [x#] (= :number (type x#))))

(fn number-recipe* [{: name : short-name : var-name : description}]
  (assert-type :string name)
  (when short-name
    (assert-char short-name))
  (assert-type :string var-name)
  (assert-type :string description)
  (let [default (. default-config name)
        description (number-description {: name
                                         : short-name
                                         : var-name
                                         : default
                                         : description})
        spec {:key name
              : description
              :preprocessor (number-preprocessor)
              :validator (number-validator)}
        short-spec (doto (clone spec)
                     (tset :description nil))]
    `(let [options# {}]
       (tset options# ,(.. "--" name) ,spec)
       ,(when short-name
          `(tset options# ,(.. "-" short-name) ,short-spec))
       options#)))

(fn number-recipe [name ...]
  "Make a number option."
  (case ...
    (short-name var-name description)
    (number-recipe* {: name : short-name : var-name : description})
    (var-name description)
    (number-recipe* {: name : var-name : description})
    nil (error "argument missing: VARNAME and description")))

(fn recipe [recipe-type ...]
  "Make an option recipe of the given `recipe-type`.

The recipe type can be one of

- `boolean` (or `bool` for short-hand notation),
- `category` (or `cat`),
- `string` (or `str`), or
- `number` (or `num`).

# Boolean option recipe

Recipe for options that are either on or off.
`recipe-spec` should be *name description* or *name short-name description*.
The `name` will be expanded to positive flag `--name` and negative flag
`--no-name`. If it has `short-name`, a short name flag `-x`, where `x` is
the value of `short-name`, will also be created.

In command line argument parsing, a positive flag or a short name flag will
set corresponding entry in configuration (e.g., if a flag's `name` is
`:apple`, its `key` in the configuration is `:apple?`) to `true`, and a
negative flag set it to `false`.

# Category option recipe

Recipe for options whose value can be any one of a finite set.
`recipe-spec` should be *name domain description* or *name short-name domain
description*. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
The `domain` should be a sequential table of strings (e.g., `[:apple :banana
:orange]`).

In command line argument parsing, an option of this type will consume the
next argument, validate if the argument is one of `domain`'s items, and set
the corresponding entry in configuration to the argument's value.

# String option recipe

Recipe for simple string options.
`recipe-spec` should be *name VARNAME description* or *name short-name
VARNAME description*. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
`VARNAME` will be used to indicate the next command line argument that will
be consumed by this option parsing.

In command line argument parsing, this option will consume the next argument
and set corresponding entry in configuration to the argument's value.

# Number option recipe

Recipe for number options. `recipe-spec` is the same as the string option
recipe's.

In command line argument parsing, this option will consume the next argument,
convert the argument to a number, validate if it has been converted to number,
and set the corresponding entry in configuration to the converted number."
  {:fnl/arglist [recipe-type & recipe-spec]}
  (case (assert-type :string recipe-type)
    :boolean (boolean-recipe ...)
    :bool (boolean-recipe ...)
    :category (category-recipe ...)
    :cat (category-recipe ...)
    :string (string-recipe ...)
    :str (string-recipe ...)
    :number (number-recipe ...)
    :num (number-recipe ...)
    _ (error "unknown recipe type!")))

(fn cooking [& recipes]
  "A helper macro to collect option `recipes` into one table."
  `(let [merge!# (. (require :fnldoc.utils.table) :merge!)]
     (doto {}
       (merge!# ,(unpack recipes)))))

{: cooking : recipe}
