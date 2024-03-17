;;;; Various option recipe consumers that help command line argument processing.

(local {: view} (require :fennel))
(local {: exit/error} (require :fnldoc.debug))
(local {: merge!} (require :fnldoc.utils.table))
(local {: indent : wrap : lines->text} (require :fnldoc.utils.text))
(local color (require :fnldoc.utils.color))

(fn preprocess [self next-arg]
  "Preprocess the `next-arg` and return the processed value.

If option recipe `self` has `preprocessor`, call it against the `next-arg`;
otherwise pass through it.
In addition, remember the `next-arg` in the `processed-arg` attribute."
  (set self.processed-arg next-arg)
  (if (not self.preprocessor)
      next-arg
      (self.preprocessor next-arg)))

(fn validate [self value]
  "Validate the `value` and return it if fine.

If option recipe `self` has `validator`, call it against the `value`;
otherwise pass through it.
If validation fails, report error and exit with failing status."
  (if (not self.validator)
      value
      (if (self.validator value)
          value
          (let [msg (.. "invalid argument for option " self.flag ": "
                        (view self.processed-arg))]
            ;; For testing purpose; see test/fnldoc/argparse/eater.fnl.
            (exit/error msg self.__fnldoc_debug?)))))

(fn parse! [self config args]
  "Update the `config` possibly with consuming the head of `args`.

If `self`, an option recipe, has `value`, append it to the `config` using
`self.key`. If not, consume the head of `args`, possibly `preprocess',
`validate', and append it to the `config` accordingly.
If the head of `args` is missing, report error and exit with failing status."
  (if (not= nil self.value)
      (tset config self.key self.value)
      (if (next args)
          (let [next-arg (table.remove args 1)]
            (tset config self.key (-> next-arg
                                      (self:preprocess)
                                      (self:validate))))
          (let [msg (.. "argument missing while processing option " self.flag)]
            (exit/error msg self.__fnldoc_debug?)))))

(local eater-mt {:__index {: preprocess : validate : parse!}})

(fn bless [option-recipe extra]
  "Enable the `option-recipe` table to process command line argument.

By blessing an option recipe, it can `parse!' command line argument.
It merges `extra` key-value pairs to the table.
To be blessed, `key` and `flag` entries are mandatory."
  (merge! option-recipe extra)
  (assert (and (= :string (type option-recipe.key))
               (= :string (type option-recipe.flag)))
          (string.format "invalid option recipe key and/or flag: %s and %s"
                         (view option-recipe.key)
                         (view option-recipe.flag)))
  (setmetatable option-recipe eater-mt))

(fn recipes->tab-splitted-descriptions [recipes color?]
  (let [bold (if color? color.bold #$)
        italic (if color? color.italic #$)]
    (collect [k v (pairs recipes)]
      (when v.description
        (values k
                {:spec (let [flags (v.description:match "^[^\t]+")
                             arg (v.description:match "\t([^\t]+)\t")]
                         (.. (bold flags) (if arg (.. " " (italic arg)) "")))
                 :desc (pick-values 1 (v.description:match "[^\t]+$"))})))))

(fn option-descriptions/order [order recipes color?]
  "Gather descriptions among option `recipes` and enumerate them in the given `order`.

If `color?` is truthy, it uses ANSI escape code."
  (let [descriptions (recipes->tab-splitted-descriptions recipes color?)
        lines (icollect [_ flag (ipairs order)]
                (let [description (. descriptions flag)]
                  (if description
                      (lines->text [(. description :spec)
                                    (indent 6 (wrap 72 (. description :desc)))
                                    ""])
                      (error (.. "no flag found: " flag)))))]
    (lines->text lines)))

{: bless : preprocess : validate : parse! : option-descriptions/order}
