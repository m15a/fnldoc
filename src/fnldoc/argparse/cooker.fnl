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

(fn boolean-description [name description ?short-name]
  (if ?short-name
      (string.format "--[no-]%s, -%s\t%s"
                     name
                     ?short-name
                     description)
      (string.format "--[no-]%s\t%s"
                     name
                     description)))

(fn boolean-recipe [name ...]
  "Make a boolean flag and corresponding negative (`--no-*`) counterpart."
  (assert-type :string name)
  (case ...
    (short-name description)
    (do
      (assert-char short-name)
      (assert-type :string description)
      (let [description (boolean-description name description short-name)
            positive-spec {:key (.. name "?")
                           : description
                           :value true}
            negative-spec {:key (.. name "?")
                           :value false}
            short-spec (doto (clone positive-spec)
                         (tset :description nil))]
        `(let [flags# {}]
           (tset flags# ,(.. "--" name) ,positive-spec)
           (tset flags# ,(.. :--no- name) ,negative-spec)
           (tset flags# ,(.. "-" short-name) ,short-spec)
           flags#)))
    (description)
    (do
      (assert-type :string description)
      (let [description (boolean-description name description)
            positive-spec {:key (.. name "?")
                           : description
                           :value true}
            negative-spec {:key (.. name "?")
                           :value false}]
        `(let [flags# {}]
           (tset flags# ,(.. "--" name) ,positive-spec)
           (tset flags# ,(.. :--no- name) ,negative-spec)
           flags#)))
    nil (error "argument missing: (short-name and) description")))

(fn category-description [name description domain default ?short-name]
  (let [domain (table.concat domain "|")]
    (if ?short-name
        (string.format "--%s, -%s\t%s (one of [%s], default: %s)"
                       name
                       ?short-name
                       description
                       domain
                       default)
        (string.format "--%s\t%s (one of [%s], default: %s)"
                       name
                       description
                       domain
                       default))))

(fn category-validate [domain]
  (let [domain (collect [_ k (ipairs domain)] k true)]
    `(fn [x#] (or (. ,domain x#) false))))

(fn category-recipe [name ...]
  "Make a categorical flag such like apple, orange, or banana."
  (assert-type :string name)
  (let [default (. default-config name)]
    (case ...
      (short-name domain description)
      (do
        (assert-char short-name)
        (assert-sequence domain)
        (each [_ k (ipairs domain)]
          (assert-type :string k))
        (assert-type :string description)
        (let [description (category-description name description domain default
                                                short-name)
              validate (category-validate domain)
              spec {:key name
                    : description
                    : validate
                    :consume-next? true}
              short-spec (doto (clone spec)
                           (tset :description nil))]
          `(let [flags# {}]
             (tset flags# ,(.. "--" name) ,spec)
             (tset flags# ,(.. "-" short-name) ,short-spec)
             flags#)))
      (domain description)
      (do
        (assert-sequence domain)
        (each [_ k (ipairs domain)]
          (assert-type :string k))
        (assert-type :string description)
        (let [description (category-description name description domain default)
              validate (category-validate domain)
              spec {:key name
                    : description
                    : validate
                    :consume-next? true}]
          `{,(.. "--" name) ,spec}))
      nil (error "argument missing: (short-name,) domain, and description"))))

(fn string-description [name description default ?short-name]
  (if ?short-name
      (string.format "--%s, -%s\t%s (default: %s)"
                     name
                     ?short-name
                     description
                     default)
      (string.format "--%s\t%s (default: %s)"
                     name
                     description
                     default)))

(fn string-recipe [name ...]
  "Make a simple string flag."
  (assert-type :string name)
  (let [default (. default-config name)]
    (case ...
      (short-name description)
      (do
        (assert-char short-name)
        (assert-type :string description)
        (let [description (string-description name description default short-name)
              spec {:key name
                    : description
                    :consume-next? true}
              short-spec (doto (clone spec)
                           (tset :description nil))]
          `(let [flags# {}]
             (tset flags# ,(.. "--" name) ,spec)
             (tset flags# ,(.. "-" short-name) ,short-spec)
             flags#)))
      (description)
      (do
        (assert-type :string description)
        (let [description (string-description name description default)
              spec {:key name
                    : description
                    :consume-next? true}]
          `{,(.. "--" name) ,spec}))
      nil (error "argument missing: (short-name and) description"))))

(fn number-description [name description default ?short-name]
  (if ?short-name
      (string.format "--%s, -%s\t%s (default: %s)"
                     name
                     ?short-name
                     description
                     default)
      (string.format "--%s\t%s (default: %s)"
                     name
                     description
                     default)))

(fn number-preprocess []
  `tonumber)

(fn number-validate []
  `(fn [x#] (= :number (type x#))))

(fn number-recipe [name ...]
  "Make a number flag."
  (assert-type :string name)
  (let [default (. default-config name)]
    (case ...
      (short-name description)
      (do
        (assert-char short-name)
        (assert-type :string description)
        (let [description (number-description name description default short-name)
              spec {:key name
                    : description
                    :preprocess (number-preprocess)
                    :validate (number-validate)
                    :consume-next? true}
              short-spec (doto (clone spec)
                           (tset :description nil))]
          `(let [flags# {}]
             (tset flags# ,(.. "--" name) ,spec)
             (tset flags# ,(.. "-" short-name)
                   ,short-spec)
             flags#)))
      (description)
      (do
        (assert-type :string description)
        (let [description (number-description name description default)
              spec {:key name
                    : description
                    :preprocess (number-preprocess)
                    :validate (number-validate)
                    :consume-next? true}]
          `{,(.. "--" name) ,spec}))
      nil (error "argument missing: (short-name and) description"))))

(fn recipe [recipe-type ...]
  "Make a flag recipe of given `recipe-type`.

The recipe type can be one of

* `boolean` (or `bool` for short-hand notation),
* `category` (or `cat`),
* `string` (or `str`), or
* `number` (or `num`).

# Boolean flag recipe

`recipe-spec` should be `[name description]` or `[name short-name description]`.
The `name` will be expanded to positive flag `--name` and negative flag
`--no-name`. If it has `short-name`, a short name flag `-x`, where `x` is given
by the `short-name`, will also be created.

In command line argument parsing, the positive flag and short name flag will
set the `config` object's attribute corresponding to the `name` (e.g., if the
`name` is `apple`, the attribute is `apple?`) to `true`, and the negative flag
set it to `false`.

# Category flag recipe

`recipe-spec` should be `[name domain description]` or `[name short-name domain
description]`. The `name` will be expanded to flag `--name`. If it has
`short-name`, a short name flag will also be created.
The `domain` should be a sequential table of strings (e.g., `[:apple :banana
:orange]`).

In command line argument parsing, this flag will consumes the next
argument, validate if the argument is one of `domain`'s items, and set the
`config` object's corresponding attribute to the argument value.

# String flag recipe

`recipe-spec` should be `[name description]` or `[name short-name description]`.
The `name` will be expanded to flag `--name`. If it has `short-name`, a short
name flag will also be created.

In command line argument parsing, this flag will consumes the next
argument and set the `config` object's corresponding attribute to the argument
value.

# Number flag recipe

`recipe-spec` should be the same as the string flag recipe.

In command line argument parsing, this flag will consumes the next
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
  "A helper macro to collect recipes into one table."
  `(let [merge!# (. (require :fnldoc.utils.table) :merge!)]
     (doto {}
       (merge!# ,(unpack recipes)))))

{: cooking : recipe}
