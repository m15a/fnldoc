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
(local default-config (require :fnldoc.config.default))
(local {: clone} (require :fnldoc.utils.table))

(fn string? [x]
  (case (type x)
    :string true
    _ false))

(fn char? [x]
  (and (string? x) (= 1 (length x))))

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
  (assert-compile (string? name) "invalid long flag name" name)
  (when short-name
    (assert-compile (char? short-name)
                    "invalid short flag name, should be 1-length string"
                    short-name))
  (assert-compile (string? description) "invalid description" description)
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
    `(fn [x#] {:fnldoc/type :private} (or (. ,domain x#) false))))

(fn category-recipe* [{: name : short-name : domain : description}]
  (assert-compile (string? name) "invalid long flag name" name)
  (when short-name
    (assert-compile (char? short-name)
                    "invalid short flag name, should be 1-length string"
                    short-name))
  (assert-compile (sequence? domain) "invalid domain type" domain)
  (each [_ k (ipairs domain)]
    (assert-compile (string? k) "invalid domain item" domain))
  (assert-compile (string? description) "invalid description" description)
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
  (assert-compile (string? name) "invalid long flag name" name)
  (when short-name
    (assert-compile (char? short-name)
                    "invalid short flag name, should be 1-length string"
                    short-name))
  (assert-compile (string? var-name) "invalid variable name" var-name)
  (assert-compile (string? description) "invalid description" description)
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
  `(fn [x#] {:fnldoc/type :private} (tonumber x#)))

(fn number-validator []
  `(fn [x#] {:fnldoc/type :private} (= :number (type x#))))

(fn number-recipe* [{: name : short-name : var-name : description}]
  (assert-compile (string? name) "invalid long flag name" name)
  (when short-name
    (assert-compile (char? short-name)
                    "invalid short flag name, should be 1-length string"
                    short-name))
  (assert-compile (string? var-name) "invalid variable name" var-name)
  (assert-compile (string? description) "invalid description" description)
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

(fn recipe [recipe-type & recipe-spec]
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
  (assert-compile (case recipe-type
                    (where (or :boolean :bool
                               :category :cat
                               :string :str
                               :number :num)) true
                    _ false)
                  "invalid recipe type"
                  recipe-type)
  (let [n (case recipe-type
            (where (or :boolean :bool)) 2
            _ 3)]
    (assert-compile (<= n (length recipe-spec))
                    "some recipe argument missing"
                    recipe-spec))
  (case recipe-type
    (where (or :boolean :bool))
    (case recipe-spec
      [name short-name description]
      (boolean-recipe* {: name : short-name : description})
      [name description]
      (boolean-recipe* {: name : description}))
    (where (or :category :cat))
    (case recipe-spec
      [name short-name domain description]
      (category-recipe* {: name : short-name : domain : description})
      [name domain description]
      (category-recipe* {: name : domain : description}))
    (where (or :string :str))
    (case recipe-spec
      [name short-name var-name description]
      (string-recipe* {: name : short-name : var-name : description})
      [name var-name description]
      (string-recipe* {: name : var-name : description}))
    (where (or :number :num))
    (case recipe-spec
      [name short-name var-name description]
      (number-recipe* {: name : short-name : var-name : description})
      [name var-name description]
      (number-recipe* {: name : var-name : description}))))

(fn cooking [& recipes]
  "A helper macro to collect option `recipes` into one table."
  `(let [merge!# (. (require :fnldoc.utils.table) :merge!)]
     (doto {}
       (merge!# ,(unpack recipes)))))

{: cooking : recipe}
