(local t (require :test.faith))
(import-macros {: start-cooking : recipe : collect-recipes}
               :fnldoc.argparse.cooker)

(fn test-global-gets-empty-after-collecting-recipes []
  (start-cooking)
  (recipe :bool :a :a)
  (collect-recipes)
  (t.= nil _G.FNLDOC_FLAG_RECIPES))

(fn test-boolean-flag []
  (start-cooking)
  (recipe :boolean :yes :YES!)
  (recipe :bool :no :n :NO!)
  (let [recipes (collect-recipes)]
    (t.= {:--yes {:description "--[no-]yes\tYES!" :key :yes? :value true}
          :--no-yes {:key :yes? :value false}
          :--no {:description "--[no-]no, -n\tNO!" :key :no? :value true}
          :--no-no {:key :no? :value false}
          :-n {:key :no? :value true}} recipes)))

(fn test-category-flag []
  (start-cooking)
  (recipe :category :fruit :f [:apple :banana] :Fruit!)
  (recipe :cat :drink [:beer :another-beer] :Beer!)
  (let [recipes (collect-recipes)
        validate-fruit (let [fruit (. recipes :--fruit)
                             v fruit.validate]
                         (set fruit.validate nil)
                         v)
        validate-f (let [f (. recipes :-f)
                         v f.validate]
                     (set f.validate nil)
                     v)
        validate-drink (let [drink (. recipes :--drink)
                             v drink.validate]
                         (set drink.validate nil)
                         v)]
    (t.= {:--fruit {:description "--fruit, -f\tFruit! (one of [apple|banana], default: nil)"
                    :key :fruit
                    :consume-next? true}
          :-f {:key :fruit :consume-next? true}
          :--drink {:description "--drink\tBeer! (one of [beer|another-beer], default: nil)"
                    :key :drink
                    :consume-next? true}} recipes)
    (t.= :function (type validate-fruit))
    (t.= :function (type validate-f))
    (t.= true (validate-fruit :apple))
    (t.= true (validate-fruit :banana))
    (t.= false (validate-fruit :orange))
    (t.= true (validate-f :apple))
    (t.= true (validate-f :banana))
    (t.= false (validate-f :orange))
    (t.= :function (type validate-drink))
    (t.= true (validate-drink :beer))
    (t.= true (validate-drink :another-beer))
    (t.= false (validate-drink :cocktail))))

(fn test-string-flag []
  (start-cooking)
  (recipe :string :text :text)
  (recipe :str :output :o :output)
  (let [recipes (collect-recipes)]
    (t.= {:--text {:description "--text\ttext (default: nil)"
                   :key :text
                   :consume-next? true}
          :--output {:description "--output, -o\toutput (default: nil)"
                     :key :output
                     :consume-next? true}
          :-o {:key :output :consume-next? true}} recipes)))

(fn test-number-flag []
  (start-cooking)
  (recipe :number :float :float)
  (recipe :num :int :i :integer)
  (let [recipes (collect-recipes)
        preprocess-float (let [float (. recipes :--float)
                               v float.preprocess]
                           (set float.preprocess nil)
                           v)
        validate-float (let [float (. recipes :--float)
                             v float.validate]
                         (set float.validate nil)
                         v)
        preprocess-int (let [int (. recipes :--int)
                             v int.preprocess]
                         (set int.preprocess nil)
                         v)
        validate-int (let [int (. recipes :--int)
                           v int.validate]
                       (set int.validate nil)
                       v)
        preprocess-i (let [i (. recipes :-i)
                           v i.preprocess]
                       (set i.preprocess nil)
                       v)
        validate-i (let [i (. recipes :-i)
                         v i.validate]
                     (set i.validate nil)
                     v)]
    (t.= {:--float {:description "--float\tfloat (default: nil)"
                    :key :float
                    :consume-next? true}
          :--int {:description "--int, -i\tinteger (default: nil)"
                  :key :int
                  :consume-next? true}
          :-i {:key :int :consume-next? true}} recipes)
    (t.= :function (type validate-float))
    (t.= :function (type validate-int))
    (t.= :function (type validate-i))
    (t.= true (validate-float 100))
    (t.= false (validate-float :a))
    (t.= true (validate-int 100))
    (t.= false (validate-int :a))
    (t.= true (validate-i 100))
    (t.= false (validate-i :a))
    (t.= :function (type preprocess-float))
    (t.= :function (type preprocess-int))
    (t.= :function (type preprocess-i))
    (t.= 100 (preprocess-float :100))
    (t.= 100 (preprocess-int :100))
    (t.= 100 (preprocess-i :100))))

{: test-global-gets-empty-after-collecting-recipes
 : test-boolean-flag
 : test-category-flag
 : test-string-flag
 : test-number-flag}
