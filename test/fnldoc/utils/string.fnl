(import-macros {: testing} :test.utils)
(local {: merge!} (require :test.utils))
(local t (require :test.faith))
(local {: escape-regex : capitalize} (require :fnldoc.utils.string))

(merge!
  (testing :escape-regex
    (it "escapes magic characters of Lua pattern" []
      (t.= "%^%$%(%)%%%.%[%]%*%+%-%?"
           (escape-regex "^$()%.[]*+-?"))))

  (testing :capitalize
    (it "capitalizes the first word" []
      (t.= "Snakecase is snakeCase"
           (capitalize "snakeCase is snakeCase")))
    (it "keeps spaces" []
      (t.= " Snakecase "
           (capitalize " snakeCase ")))
    (it "keeps all-uppercase word" []
      (t.= "UPPER lower"
           (capitalize "UPPER lower")))))

;; vim: lw+=testing,test,it spell
