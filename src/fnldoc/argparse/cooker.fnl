;; fennel-ls: macro-file

(local unpack (or table.unpack _G.unpack))
(local {: view} (require :fennel))
(local default-config (require :fnldoc.config.default))
(local {: assert-type} (require :fnldoc.utils))
(local {: clone} (require :fnldoc.utils.table))

(fn assert-char [x]
  (assert (and (= :string (type x)) (= 1 (length x)))
          (string.format "1-length string expected, got %s" (view x))))

(fn assert-sequence [x]
  (assert (sequence? x) (string.format "sequential table expected, got %s"
                                       (view x))))

(fn boolean-description [{: name : short-name : default : description}]
  (if short-name
      (string.format "-%s, --[no-]%s\t%s (default: %s)"
                     short-name
                     name
                     description
                     default)
      (string.format "    --[no-]%s\t%s (default: %s)"
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
        (string.format "-%s, --%s [%s]\t%s (default: %s)"
                       short-name
                       name
                       domain
                       description
                       default)
        (string.format "    --%s [%s]\t%s (default: %s)"
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
      (string.format "-%s, --%s %s\t%s (default: %s)"
                     short-name
                     name
                     (or var-name :TEXT)
                     description
                     default)
      (string.format "    --%s %s\t%s (default: %s)"
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
      (string.format "-%s, --%s %s\t%s (default: %s)"
                     short-name
                     name
                     (or var-name :NUM)
                     description
                     default)
      (string.format "    --%s %s\t%s (default: %s)"
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
  "Make an option recipe of given `recipe-type`.

The recipe type can be one of

* `boolean` (or `bool` for short-hand notation),
* `category` (or `cat`),
* `string` (or `str`), or
* `number` (or `num`).

# Boolean option recipe

`recipe-spec` should be `[name description]` or `[name short-name description]`.
The `name` will be expanded to positive flag `--name` and negative flag
`--no-name`. If it has `short-name`, a short name flag `-x`, where `x` is given
by the `short-name`, will also be created.

In command line argument parsing, the positive flag and short name flag will
set the `config` object's attribute corresponding to the `name` (e.g., if the
`name` is `apple`, the attribute is `apple?`) to `true`, and the negative flag
set it to `false`.

# Category option recipe

`recipe-spec` should be `[name domain description]` or `[name short-name domain
description]`. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
The `domain` should be a sequential table of strings (e.g., `[:apple :banana
:orange]`).

In command line argument parsing, this option will consumes the next
argument, validate if the argument is one of `domain`'s items, and set the
`config` object's corresponding attribute to the argument value.

# String option recipe

`recipe-spec` should be `[name VARNAME description]` or `[name short-name VARNAME
description]`. The `name` will be expanded to flag `--name`. If it has `short-name`,
a short name flag will also be created. `VARNAME` will be used to indicate the next
command line argument that will be consumed by this option parsing.

In command line argument parsing, this option will consumes the next
argument and set the `config` object's corresponding attribute to the argument
value.

# Number option recipe

`recipe-spec` should be the same as the string option recipe.

In command line argument parsing, this option will consumes the next
argument, validate if it can be converted to number, and set the `config`
object's corresponding attribute to the converted number."
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
