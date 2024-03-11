(local t (require :test.faith))
(local {: bless : option-descriptions/order} (require :fnldoc.argparse.eater))

(fn test-bless []
  (let [recipe (bless {:key :key :flag :--flag})]
    (t.= "a" (recipe:preprocess "a"))
    (t.= recipe.value (recipe:preprocess recipe.value)))
  (let [recipe (bless {:key :num :flag :--num
                       :preprocessor tonumber
                       :validator #(= :number (type $))})]
    (set recipe.__fnldoc_debug? true)
    (t.= 10 (-> "10"
                (recipe:preprocess)
                (recipe:validate :debug)))
    (t.error "invalid argument: \"a\""
             #(-> :a
                  (recipe:preprocess)
                  (recipe:validate)))))

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

{: test-bless : test-option-descriptions/order}
