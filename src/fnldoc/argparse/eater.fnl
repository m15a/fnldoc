;;;; Various option recipe consumers that help command line argument processing.

(local {: view} (require :fennel))
(local console (require :fnldoc.console))
(local {: merge!} (require :fnldoc.utils.table))
(local {: indent : wrap} (require :fnldoc.utils.text))

(fn preprocess [self next-arg]
  "Preprocess the `next-arg` and return the processed value.

If an option recipe `self` has `preprocessor`, call it against the `next-arg`;
otherwise pass through it.
In addition, remember the `next-arg` in the `processed-arg` attribute."
  (set self.processed-arg next-arg)
  (if (not self.preprocessor)
      next-arg
      (self.preprocessor next-arg)))

(fn validate [self value]
  "Validate the `value` and return it if successes.

If an option recipe `self` has `validator`, call it against the `value`;
otherwise pass through it.
If validation fails, report error and exit with failing status."
  (if (not self.validator)
      value
      (if (self.validator value)
          value
          (let [msg (.. "invalid argument: " (view self.processed-arg))]
            ;; For testing purpose; see test/fnldoc/argparse/eater.fnl.
            (if self.__fnldoc_debug?
                (error msg)
                (do
                  (console.error msg)
                  (os.exit 1)))))))

(fn parse! [self config args]
  "Update the `config` object possibly with consuming the head of `args`.

If the option recipe `self` has `value`, append it to the `config` using `self`'s
`key`. If not, consume the head of `args`, possibly preprocess, validate, and append
it to the `config` accordingly.
If the head of `args` is missing, report error and exit with failing status."
  (if (not= nil self.value)
      (tset config self.key self.value)
      (if (next args)
          (let [next-arg (table.remove args 1)]
            (tset config self.key (-> next-arg
                                      (self:preprocess)
                                      (self:validate))))
          (let [msg (.. "argument missing while processing option " self.flag)]
            (if self.__fnldoc_debug?
                (error msg)
                (do
                  (console.error msg)
                  (os.exit 1)))))))

(local eater-mt {:__index {: preprocess : validate : parse!}})

(fn bless [option-recipe extra]
  "Enable the `option-recipe` table to consume command line arguments.

In addition, attach `extra` key-value pairs to the table.
To be blessed, `key` and `flag` attributes are mandatory.
"
  (merge! option-recipe extra)
  (assert (and (= :string (type option-recipe.key))
               (= :string (type option-recipe.flag)))
          (string.format "invalid option recipe key and/or flag: %s and %s"
                         (view option-recipe.key)
                         (view option-recipe.flag)))
  (setmetatable option-recipe eater-mt))

(fn recipes->tab-splitted-descriptions [recipes]
  (collect [k v (pairs recipes)]
    (when v.description
      (values k
              {:flag (pick-values 1 (v.description:match "^[^\t]+"))
               :desc (pick-values 1 (v.description:match "[^\t]+$"))}))))

(fn option-descriptions/order [order recipes]
  "Gather descriptions among option `recipes` and enumerate them in the given `order`."
  (let [descriptions (recipes->tab-splitted-descriptions recipes)
        lines (icollect [_ flag (ipairs order)]
                (let [description (. descriptions flag)]
                  (if description
                      (.. (. description :flag) "\n"
                          (indent 6 (wrap 72 (. description :desc))) "\n")
                      (error (.. "no flag found: " flag)))))]
    (table.concat lines "\n")))

{: bless : preprocess : validate : parse! : option-descriptions/order}
