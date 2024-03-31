(local t (require :test.faith))
(local {: bless : option-descriptions/order} (require :fnldoc.argparse.eater))

(fn test-bless []
  (let [recipe (bless {:key :key :flag :--flag})]
    (t.= "a" (recipe:preprocess "a"))
    (t.= recipe.value (recipe:preprocess recipe.value)))
  (let [recipe (bless {:key :num :flag :--num
                       :preprocessor tonumber
                       :validator #(= :number (type $))})]
    (t.= 10 (-> "10"
                (recipe:preprocess)
                (recipe:validate)))
    (t.error "invalid argument for option %-%-num: \"a\""
             #(-> :a
                  (recipe:preprocess)
                  (recipe:validate)))))

(fn test-parse! []
  (let [args []
        config {}
        recipe (bless {:key :key :value true} {:flag :--key})]
    (recipe:parse! config args)
    (t.= {:key true} config)
    (t.= [] args))
  (let [args [:arg1]
        config {}
        recipe (bless {:key :key} {:flag :--key})]
    (recipe:parse! config args)
    (t.= {:key :arg1} config)
    (t.= [] args))
  (let [args []
        config {}
        recipe (bless {:key :key} {:flag :--key})]
    (t.error "argument missing while processing option %-%-key"
             #(recipe:parse! config args))))

(fn test-option-descriptions/order []
  (let [recipes {:--a {:description "-a, --a-flag\tA flag."}
                 :--b {}
                 :--c {:description "    --c-flag\tC flag."}}]
    (t.= "    --c-flag
      C flag.

-a, --a-flag
      A flag.
"
         (option-descriptions/order [:--c :--a] recipes))
    (t.= "-a, --a-flag
      A flag.

    --c-flag
      C flag.
"
         (option-descriptions/order [:--a :--c] recipes))
    (t.error "no flag found: %-%-b"
             #(option-descriptions/order [:--b] recipes))))

{: test-bless : test-parse! : test-option-descriptions/order}
