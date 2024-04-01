(import-macros {: testing : test} :test.utils)
(local t (require :test.faith))
(local ut (require :fnldoc.utils.text))

(testing "text utils"
  (test :indent []
    (let [text "A\nB\nC"]
      (t.= "A\nB\nC" (ut.indent -1 text))
      (t.= "A\nB\nC" (ut.indent 0 text))
      (t.= "  A\n  B\n  C" (ut.indent 2 text))))

  (test :text->lines []
    (let [text "A\nB\nC"]
      (t.= [:A :B :C] (ut.text->lines text)))
    (let [text "A\n\nB\n"]
      (t.= [:A "" :B] (ut.text->lines text)))
    (let [text "B\n\n"]
      (t.= [:B ""] (ut.text->lines text))))

  (test :lines->text []
    (let [lines [:A :B :C]]
      (t.= "A\nB\nC" (ut.lines->text lines))
      (t.= :A__B__C (ut.lines->text lines "__"))))

  (test :wrap/line []
    (let [line "adfasdf bdfasf fa fdafas f adfaf  fasd fga"]
      (t.= "adfasdf\nbdfasf fa\nfdafas f\nadfaf \nfasd fga"
           (ut.wrap/line line 10))
      (t.= "adfasdf bdfasf fa?fdafas f adfaf ?fasd fga"
           (ut.wrap/line line 20 "?"))))

  (test :wrap []
    (let [text "What Irish man, woman, or child has not heard of our renowned Hibernian Hercules, the great and glorious Fin M'Coul?
Not one, from Cape Clear to the Giant's Causeway, nor from that back again to Cape Clear."]
      (t.= "What Irish man, woman, or child has not heard of our renowned Hibernian
Hercules, the great and glorious Fin M'Coul?
Not one, from Cape Clear to the Giant's Causeway, nor from that back again to
Cape Clear." (ut.wrap 78 text))))

  (test :pad []
    (let [text :A]
      (t.= :A (ut.pad -2 text))
      (t.= :A (ut.pad 0 text))
      (t.= "   A" (ut.pad 4 text))
      (t.= :000A (ut.pad 4 text :0))
      (t.error "invalid %?pad%-char length:" #(ut.pad 0 text :BB))))

  (test :pad/right []
    (let [text :FOUR]
      (t.= :FOUR (ut.pad/right -1 text))
      (t.= :FOUR (ut.pad/right 0 text))
      (t.= "FOUR  " (ut.pad/right 6 text))
      (t.= :FOUR00 (ut.pad/right 6 text :0))
      (t.error "invalid %?pad%-char length:" #(ut.pad/right 0 text :BB)))))

;; vim: lw+=testing,test,it spell
