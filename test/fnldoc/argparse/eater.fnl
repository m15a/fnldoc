(import-macros {: testing : test : it} :test.utils)
(local {: text} (require :test.utils))
(local t (require :test.faith))
(local {: bless : option-descriptions/order} (require :fnldoc.argparse.eater))

(testing
  (test :recipe-does-nothing-without-preprocessor-validator []
    (let [recipe (bless {:key :key :flag :--flag})]
      (t.= :a (-> :a
                  (recipe:preprocess)
                  (recipe:validate)))))

  (test :recipe-does-preprocessing-and-validation []
    (let [recipe (bless {:key :num :flag :--num
                         :preprocessor tonumber
                         :validator #(= :number (type $))})]
      (t.= 10 (-> :10
                  (recipe:preprocess)
                  (recipe:validate)))
      (t.error "invalid argument for option %-%-num: \"a\""
               #(-> :a
                    (recipe:preprocess)
                    (recipe:validate)))))

  (test :recipe-with-value-does-not-consume-args []
    (let [config {} args []
          recipe (bless {:key :key :value true} {:flag :--key})]
      (recipe:parse! config args)
      (t.= {:key true} config)
      (t.= [] args)))

  (test :recipe-without-value-consumes-args []
    (let [ config {} args [:arg1]
          recipe (bless {:key :key} {:flag :--key})]
      (recipe:parse! config args)
      (t.= {:key :arg1} config)
      (t.= [] args)
      (t.error "argument missing while processing option %-%-key"
               #(recipe:parse! config args))))

  (local option-recipes {:--a {:description "-a, --a-flag\tA flag."}
                         :--b {}
                         :--c {:description "    --c-flag\tC flag."}})

  (test :option-descriptions/order []
    (t.= (text "
    --c-flag
      C flag.

-a, --a-flag
      A flag.
")
         (option-descriptions/order [:--c :--a] option-recipes)
     (t.= (text "
-a, --a-flag
      A flag.

    --c-flag
      C flag.
")
          (option-descriptions/order [:--a :--c] option-recipes))))

  (test :option-descriptions/order-raises-error-if-description-missing []
      (t.error "no description found: %-%-b"
               #(option-descriptions/order [:--b] option-recipes))))

;; vim: lw+=testing,test,it spell
