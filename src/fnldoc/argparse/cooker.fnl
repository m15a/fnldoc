;; fennel-ls: macro-file

(local unpack (or table.unpack _G.unpack))
(local {: view} (require :fennel))
(local default-config (require :fnldoc.config.default))
(local {: assert-type} (require :fnldoc.utils))
(local {: clone} (require :fnldoc.utils.table))

(fn assert-short [x]
  (assert (= 1 (length x)) (string.format "1-length string expected, got %s"
                                          (view x))))

(fn assert-sequence [x]
  (assert (sequence? x) (string.format "sequential table expected, got %s"
                                       (view x))))

(fn boolean-recipe [name short-name/description ?description]
  "Make a boolean flag and corresponding negative (`--no-*`) counterpart."
  (assert-type :string name)
  (assert-type :string short-name/description)
  (if ?description
      (let [short-name short-name/description
            description ?description]
        (assert-short short-name)
        (assert-type :string description)
        (let [description (string.format "--[no-]%s, -%s\t%s" name short-name
                                         description)
              positive-spec {:key (.. name "?") : description :value true}
              negative-spec {:key (.. name "?") :value false}
              short-spec (doto (clone positive-spec)
                           (tset :description nil))]
          `(let [flags# {}]
             (tset flags# ,(.. "--" name) ,positive-spec)
             (tset flags# ,(.. :--no- name) ,negative-spec)
             (tset flags# ,(.. "-" short-name) ,short-spec)
             flags#)))
      (let [description short-name/description]
        (let [description (string.format "--[no-]%s\t%s" name description)
              positive-spec {:key (.. name "?") : description :value true}
              negative-spec {:key (.. name "?") :value false}]
          `(let [flags# {}]
             (tset flags# ,(.. "--" name) ,positive-spec)
             (tset flags# ,(.. :--no- name) ,negative-spec)
             flags#)))))

(fn category-recipe [name short-name/domain domain/description ?description]
  "Make a categorical flag such like apple, orange, or banana."
  (assert-type :string name)
  (let [default (. default-config name)]
    (if ?description
        (let [short-name short-name/domain
              domain domain/description
              description ?description]
          (assert-type :string short-name)
          (assert-short short-name)
          (assert-sequence domain)
          (each [_ k (ipairs domain)] (assert-type :string k))
          (assert-type :string description)
          (let [description (let [domain (table.concat domain "|")]
                              (string.format "--%s, -%s\t%s (one of [%s], default: %s)"
                                             name short-name description domain
                                             default))
                validate (let [domain (collect [_ k (ipairs domain)] k true)]
                           `(fn [x#]
                              (or (. ,domain x#) false)))
                spec {:key name : description : validate :consume-next? true}
                short-spec (doto (clone spec)
                             (tset :description nil))]
            `(let [flags# {}]
               (tset flags# ,(.. "--" name) ,spec)
               (tset flags# ,(.. "-" short-name) ,short-spec)
               flags#)))
        (let [domain short-name/domain
              description domain/description]
          (assert-sequence domain)
          (each [_ k (ipairs domain)] (assert-type :string k))
          (assert-type :string description)
          (let [description (let [domain (table.concat domain "|")]
                              (string.format "--%s\t%s (one of [%s], default: %s)"
                                             name description domain default))
                validate (let [domain (collect [_ k (ipairs domain)] k true)]
                           `(fn [x#]
                              (or (. ,domain x#) false)))
                spec {:key name : description : validate :consume-next? true}]
            `{,(.. "--" name) ,spec})))))

(fn string-recipe [name short-name/description ?description]
  "Make a simple string flag."
  {:fnl/arglist (or [name description] [name short-name description])}
  (assert-type :string name)
  (assert-type :string short-name/description)
  (let [default (. default-config name)]
    (if ?description
        (let [short-name short-name/description
              description ?description]
          (assert-type :string description)
          (let [description (string.format "--%s, -%s\t%s (default: %s)" name
                                           short-name description default)
                spec {:key name : description :consume-next? true}
                short-spec (doto (clone spec)
                             (tset :description nil))]
            `(let [flags# {}]
               (tset flags# ,(.. "--" name) ,spec)
               (tset flags# ,(.. "-" short-name) ,short-spec)
               flags#)))
        (let [description short-name/description]
          (let [description (string.format "--%s\t%s (default: %s)" name
                                           description default)
                spec {:key name : description :consume-next? true}]
            `{,(.. "--" name) ,spec})))))

(fn number-recipe [name short-name/description ?description]
  "Make a number flag."
  {:fnl/arglist (or [name description] [name short-name description])}
  (assert-type :string name)
  (assert-type :string short-name/description)
  (let [default (. default-config name)]
    (if ?description
        (let [short-name short-name/description
              description ?description]
          (assert-type :string description)
          (let [description (string.format "--%s, -%s\t%s (default: %s)" name
                                           short-name description default)
                spec {:key name
                      : description
                      :preprocess `tonumber
                      :validate `(fn [x#] (= :number (type x#)))
                      :consume-next? true}
                short-spec (doto (clone spec)
                             (tset :description nil))]
            `(let [flags# {}]
               (tset flags# ,(.. "--" name) ,spec)
               (tset flags# ,(.. "-" short-name) ,short-spec)
               flags#)))
        (let [description short-name/description]
          (let [description (string.format "--%s\t%s (default: %s)" name
                                           description default)
                spec {:key name
                      : description
                      :preprocess `tonumber
                      :validate `(fn [x#] (= :number (type x#)))
                      :consume-next? true}]
            `{,(.. "--" name) ,spec})))))

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
