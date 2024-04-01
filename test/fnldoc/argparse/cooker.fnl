(import-macros {: testing} :test.utils)
(local t (require :test.faith))
(import-macros {: cooking : recipe} :fnldoc.argparse.cooker)

(fn move-validator-from [recipes flag]
  (let [r (. recipes flag)
        v r.validator]
    (set r.validator nil)
    v))

(fn move-preprocessor-from [recipes flag]
  (let [r (. recipes flag)
        v r.preprocessor]
    (set r.preprocessor nil)
    v))

(testing :cooking
  (it "makes boolean recipes" []
    (t.= {:--yes {:description "    --[no-]yes\t\tYES! (default: nil)"
                  :key :yes?
                  :value true}
          :--no-yes {:key :yes? :value false}
          :--no {:description "-n, --[no-]no\t\tNO! (default: nil)"
                 :key :no?
                 :value true}
          :--no-no {:key :no? :value false}
          :-n {:key :no? :value true}}
         (cooking
           (recipe :boolean :yes :YES!)
           (recipe :bool :no :n :NO!))))

  (it "makes category recipes" []
    (let [recipes (cooking (recipe :category :fruit :f
                                   [:apple :banana] :Fruit!)
                           (recipe :cat :drink [:beer] :Beer!))
          validator-fruit (move-validator-from recipes :--fruit)
          validator-f (move-validator-from recipes :-f)
          validator-drink (move-validator-from recipes :--drink)]
      (t.= {:--fruit {:description
                      "-f, --fruit\t[apple|banana]\tFruit! (default: nil)"
                      :key :fruit}
            :-f {:key :fruit}
            :--drink {:description
                      "    --drink\t[beer]\tBeer! (default: nil)"
                      :key :drink}}
           recipes)
      (t.= :function (type validator-fruit))
      (t.= [true true false]
           (icollect [_ x (ipairs [:apple :banana :orange])]
             (validator-fruit x)))
      (t.= :function (type validator-f))
      (t.= [true true false]
           (icollect [_ x (ipairs [:apple :banana :orange])]
             (validator-f x)))
      (t.= :function (type validator-drink))
      (t.= [true false]
           (icollect [_ x (ipairs [:beer :whisky])]
             (validator-drink x)))))

  (it "makes string recipes" []
    (t.= {:--text {:description "    --text\tTEXT\ttext (default: nil)"
                   :key :text}
          :--output {:description "-o, --output\tOUT\toutput (default: nil)"
                     :key :output}
          :-o {:key :output}}
         (cooking
           (recipe :string :text :TEXT :text)
           (recipe :str :output :o :OUT :output))))

  (it "makes number recipes" []
    (let [recipes (cooking
                    (recipe :number :float :FLOAT :float)
                    (recipe :num :int :i :INT :integer))
          preprocessor-float (move-preprocessor-from recipes :--float)
          validator-float (move-validator-from recipes :--float)
          preprocessor-int (move-preprocessor-from recipes :--int)
          validator-int (move-validator-from recipes :--int)
          preprocessor-i (move-preprocessor-from recipes :-i)
          validator-i (move-validator-from recipes :-i)]
      (t.= {:--float {:description "    --float\tFLOAT\tfloat (default: nil)"
                      :key :float}
            :--int {:description "-i, --int\tINT\tinteger (default: nil)"
                    :key :int}
            :-i {:key :int}}
           recipes)
      (t.= :function (type validator-float))
      (t.= [true false]
           (icollect [_ x (ipairs [100 :a])]
             (validator-float x)))
      (t.= :function (type preprocessor-float))
      (t.= 100 (preprocessor-float :100))
      (t.= :function (type validator-int))
      (t.= [true false]
           (icollect [_ x (ipairs [100 :a])]
             (validator-int x)))
      (t.= :function (type preprocessor-int))
      (t.= 100 (preprocessor-int :100))
      (t.= :function (type validator-i))
      (t.= [true false]
           (icollect [_ x (ipairs [100 :a])]
             (validator-i x)))
      (t.= :function (type preprocessor-i))
      (t.= 100 (preprocessor-i :100)))))

;; vim: lw+=testing,test,it,cooking,recipe spell
