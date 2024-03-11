(local t (require :test.faith))
(import-macros {: cooking : recipe} :fnldoc.argparse.cooker)

(fn test-boolean-flag []
  (let [recipes (cooking (recipe :boolean :yes :YES!)
                         (recipe :bool :no :n :NO!))]
    (t.= {:--yes {:description "    --[no-]yes\tYES! (default: nil)"
                  :key :yes?
                  :value true}
          :--no-yes {:key :yes?
                     :value false}
          :--no {:description "-n, --[no-]no\tNO! (default: nil)"
                 :key :no?
                 :value true}
          :--no-no {:key :no?
                    :value false}
          :-n {:key :no?
               :value true}} recipes)))

(fn test-category-flag []
  (let [recipes (cooking (recipe :category :fruit :f [:apple :banana] :Fruit!)
                         (recipe :cat :drink [:beer :another-beer] :Beer!))
        validator-fruit (let [fruit (. recipes :--fruit)
                              v fruit.validator]
                          (set fruit.validator nil)
                          v)
        validator-f (let [f (. recipes :-f)
                          v f.validator]
                      (set f.validator nil)
                      v)
        validator-drink (let [drink (. recipes :--drink)
                              v drink.validator]
                          (set drink.validator nil)
                          v)]
    (t.= {:--fruit {:description "-f, --fruit [apple|banana]\tFruit! (default: nil)"
                    :key :fruit}
          :-f {:key :fruit}
          :--drink {:description "    --drink [beer|another-beer]\tBeer! (default: nil)"
                    :key :drink}}
         recipes)
    (t.= :function (type validator-fruit))
    (t.= :function (type validator-f))
    (t.= true (validator-fruit :apple))
    (t.= true (validator-fruit :banana))
    (t.= false (validator-fruit :orange))
    (t.= true (validator-f :apple))
    (t.= true (validator-f :banana))
    (t.= false (validator-f :orange))
    (t.= :function (type validator-drink))
    (t.= true (validator-drink :beer))
    (t.= true (validator-drink :another-beer))
    (t.= false (validator-drink :cocktail))))

(fn test-string-flag []
  (let [recipes (cooking (recipe :string :text :TEXT :text)
                         (recipe :str :output :o :OUT :output))]
    (t.= {:--text {:description "    --text TEXT\ttext (default: nil)"
                   :key :text}
          :--output {:description "-o, --output OUT\toutput (default: nil)"
                     :key :output}
          :-o {:key :output}}
         recipes)))

(fn test-number-flag []
  (let [recipes (cooking (recipe :number :float :FLOAT :float)
                         (recipe :num :int :i :INT :integer))
        preprocessor-float (let [float (. recipes :--float)
                                 v float.preprocessor]
                             (set float.preprocessor nil)
                             v)
        validator-float (let [float (. recipes :--float)
                              v float.validator]
                          (set float.validator nil)
                          v)
        preprocessor-int (let [int (. recipes :--int)
                               v int.preprocessor]
                           (set int.preprocessor nil)
                           v)
        validator-int (let [int (. recipes :--int)
                            v int.validator]
                        (set int.validator nil)
                        v)
        preprocessor-i (let [i (. recipes :-i)
                             v i.preprocessor]
                         (set i.preprocessor nil)
                         v)
        validator-i (let [i (. recipes :-i)
                          v i.validator]
                      (set i.validator nil)
                      v)]
    (t.= {:--float {:description "    --float FLOAT\tfloat (default: nil)"
                    :key :float}
          :--int {:description "-i, --int INT\tinteger (default: nil)"
                  :key :int}
          :-i {:key :int}}
         recipes)
    (t.= :function (type validator-float))
    (t.= :function (type validator-int))
    (t.= :function (type validator-i))
    (t.= true (validator-float 100))
    (t.= false (validator-float :a))
    (t.= true (validator-int 100))
    (t.= false (validator-int :a))
    (t.= true (validator-i 100))
    (t.= false (validator-i :a))
    (t.= :function (type preprocessor-float))
    (t.= :function (type preprocessor-int))
    (t.= :function (type preprocessor-i))
    (t.= 100 (preprocessor-float :100))
    (t.= 100 (preprocessor-int :100))
    (t.= 100 (preprocessor-i :100))))

{: test-boolean-flag
 : test-category-flag
 : test-string-flag
 : test-number-flag}
