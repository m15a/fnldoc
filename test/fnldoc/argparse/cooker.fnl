(local t (require :test.faith))
(import-macros {: cooking : recipe} :fnldoc.argparse.cooker)

(fn test-boolean-flag []
  (let [recipes (cooking (recipe :boolean :yes :YES!)
                         (recipe :bool :no :n :NO!))]
    (t.= {:--yes {:description "--[no-]yes\tYES! (default: nil)" :key :yes? :value true}
          :--no-yes {:key :yes? :value false}
          :--no {:description "--[no-]no|-n\tNO! (default: nil)" :key :no? :value true}
          :--no-no {:key :no? :value false}
          :-n {:key :no? :value true}} recipes)))

(fn test-category-flag []
  (let [recipes (cooking (recipe :category :fruit :f [:apple :banana] :Fruit!)
                         (recipe :cat :drink [:beer :another-beer] :Beer!))
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
    (t.= {:--fruit {:description "--fruit|-f [apple|banana]\tFruit! (default: nil)"
                    :key :fruit
                    :consume-next? true}
          :-f {:key :fruit :consume-next? true}
          :--drink {:description "--drink [beer|another-beer]\tBeer! (default: nil)"
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
  (let [recipes (cooking (recipe :string :text :TEXT :text)
                         (recipe :str :output :o :OUT :output))]
    (t.= {:--text {:description "--text TEXT\ttext (default: nil)"
                   :key :text
                   :consume-next? true}
          :--output {:description "--output|-o OUT\toutput (default: nil)"
                     :key :output
                     :consume-next? true}
          :-o {:key :output :consume-next? true}} recipes)))

(fn test-number-flag []
  (let [recipes (cooking (recipe :number :float :FLOAT :float)
                         (recipe :num :int :i :INT :integer))
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
    (t.= {:--float {:description "--float FLOAT\tfloat (default: nil)"
                    :key :float
                    :consume-next? true}
          :--int {:description "--int|-i INT\tinteger (default: nil)"
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

{: test-boolean-flag
 : test-category-flag
 : test-string-flag
 : test-number-flag}
