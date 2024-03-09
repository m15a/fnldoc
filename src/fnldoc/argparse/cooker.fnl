;; fennel-ls: macro-file

(local {: view} (require :fennel))
(local default-config (require :fnldoc.config.default))

(fn start-cooking []
  "Start declaration of command line argument flags.

It implicitly declares global table `_G.FNLDOC_FLAG_RECIPES`. Flag recipes
declared by `(recipe ...)` macro will be gathered into this global, and
later collected by calling `(collect-recipes)`."
  `(tset _G :FNLDOC_FLAG_RECIPES {}))

(fn assert-string [x]
  (assert (= :string (type x))
          (string.format "string expected, got %s" (view x))))

(fn assert-short [x]
  (assert (= 1 (length x)) (string.format "1-length string expected, got %s"
                                          (view x))))

(fn assert-sequence [x]
  (assert (sequence? x) (string.format "sequential table expected, got %s"
                                       (view x))))

(fn boolean-recipe [name short-name/description ?description]
  "Define a boolean flag and corresponding negative (`--no-*`) counterpart."
  (assert-string name)
  (assert-string short-name/description)
  (if ?description
      (let [short-name short-name/description
            description ?description]
        (assert-short short-name)
        (assert-string description)
        (let [description (string.format "--[no-]%s, -%s\t%s" name short-name
                                         description)
              positive-spec {:key (.. name "?") : description :value true}
              negative-spec {:key (.. name "?") :value false}
              short-spec (doto (collect [k v (pairs positive-spec)] k v)
                           (tset :description nil))]
          `(do
             (tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,positive-spec)
             (tset _G :FNLDOC_FLAG_RECIPES ,(.. :--no- name) ,negative-spec)
             (tset _G :FNLDOC_FLAG_RECIPES ,(.. "-" short-name) ,short-spec))))
      (let [description short-name/description]
        (let [description (string.format "--[no-]%s\t%s" name description)
              positive-spec {:key (.. name "?") : description :value true}
              negative-spec {:key (.. name "?") :value false}]
          `(do
             (tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,positive-spec)
             (tset _G :FNLDOC_FLAG_RECIPES ,(.. :--no- name) ,negative-spec))))))

(fn category-recipe [name short-name/domain domain/description ?description]
  "Define a categorical flag such like apple, orange, or banana."
  (assert-string name)
  (let [default (. default-config name)]
    (if ?description
        (let [short-name short-name/domain
              domain domain/description
              description ?description]
          (assert-string short-name)
          (assert-short short-name)
          (assert-sequence domain)
          (each [_ k (ipairs domain)] (assert-string k))
          (assert-string description)
          (let [description (let [domain (table.concat domain "|")]
                              (string.format "--%s, -%s\t%s (one of [%s], default: %s)"
                                             name short-name description domain
                                             default))
                validate (let [domain (collect [_ k (ipairs domain)] k true)]
                           `(fn [x#]
                              (or (. ,domain x#) false)))
                spec {:key name : description : validate :consume-next? true}
                short-spec (doto (collect [k v (pairs spec)] k v)
                             (tset :description nil))]
            `(do
               (tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,spec)
               (tset _G :FNLDOC_FLAG_RECIPES ,(.. "-" short-name) ,short-spec))))
        (let [domain short-name/domain
              description domain/description]
          (assert-sequence domain)
          (each [_ k (ipairs domain)] (assert-string k))
          (assert-string description)
          (let [description (let [domain (table.concat domain "|")]
                              (string.format "--%s\t%s (one of [%s], default: %s)"
                                             name description domain default))
                validate (let [domain (collect [_ k (ipairs domain)] k true)]
                           `(fn [x#]
                              (or (. ,domain x#) false)))
                spec {:key name : description : validate :consume-next? true}]
            `(tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,spec))))))

(fn string-recipe [name short-name/description ?description]
  "Define a simple string flag."
  {:fnl/arglist (or [name description] [name short-name description])}
  (assert-string name)
  (assert-string short-name/description)
  (let [default (. default-config name)]
    (if ?description
        (let [short-name short-name/description
              description ?description]
          (assert-string description)
          (let [description (string.format "--%s, -%s\t%s (default: %s)" name
                                           short-name description default)
                spec {:key name : description :consume-next? true}
                short-spec (doto (collect [k v (pairs spec)] k v)
                             (tset :description nil))]
            `(do
               (tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,spec)
               (tset _G :FNLDOC_FLAG_RECIPES ,(.. "-" short-name) ,short-spec))))
        (let [description short-name/description]
          (let [description (string.format "--%s\t%s (default: %s)" name
                                           description default)
                spec {:key name : description :consume-next? true}]
            `(tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,spec))))))

(fn number-recipe [name short-name/description ?description]
  "Define a number flag."
  {:fnl/arglist (or [name description] [name short-name description])}
  (assert-string name)
  (assert-string short-name/description)
  (let [default (. default-config name)]
    (if ?description
        (let [short-name short-name/description
              description ?description]
          (assert-string description)
          (let [description (string.format "--%s, -%s\t%s (default: %s)" name
                                           short-name description default)
                spec {:key name
                      : description
                      :preprocess `tonumber
                      :validate `(fn [x#] (= :number (type x#)))
                      :consume-next? true}
                short-spec (doto (collect [k v (pairs spec)] k v)
                             (tset :description nil))]
            `(do
               (tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,spec)
               (tset _G :FNLDOC_FLAG_RECIPES ,(.. "-" short-name) ,short-spec))))
        (let [description short-name/description]
          (let [description (string.format "--%s\t%s (default: %s)" name
                                           description default)
                spec {:key name
                      : description
                      :preprocess `tonumber
                      :validate `(fn [x#] (= :number (type x#)))
                      :consume-next? true}]
            `(tset _G :FNLDOC_FLAG_RECIPES ,(.. "--" name) ,spec))))))

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
  (assert-string recipe-type)
  (case recipe-type
    :boolean (boolean-recipe ...)
    :bool (boolean-recipe ...)
    :category (category-recipe ...)
    :cat (category-recipe ...)
    :string (string-recipe ...)
    :str (string-recipe ...)
    :number (number-recipe ...)
    :num (number-recipe ...)
    _ (error "unknown recipe type!")))

(fn collect-recipes []
  "Return all defined flag recipes as a table.

The implicit global `_G.FNLDOC_FLAG_RECIPES` will be cleared as well."
  `(let [flags# (collect [k# v# (pairs (. _G :FNLDOC_FLAG_RECIPES))]
                  k#
                  v#)]
     (tset _G :FNLDOC_FLAG_RECIPES nil)
     flags#))

{: start-cooking : recipe : collect-recipes}
