(import-macros {: testing : test} :test.utils)
(local {:merge! tmerge!} (require :test.utils))
(local t (require :test.faith))
(local {: clone : clone/deeply : merge! : comparator/table}
       (require :fnldoc.utils.table))

(tmerge!
  (testing "table clone"
    (it "clones shallowly" []
      (let [x {:a 1 :b {:c 2} :d 1}
            y (clone x)]
        (tset y :a 2)
        (tset y :b :c 3)
        (t.= {:a 1 :b {:c 3} :d 1} x)
        (t.= {:a 2 :b {:c 3} :d 1} y)))
    (it "clones deeply" []
      (let [x {:a 1 :b {:c 2} :d [1 2 3]}
            y (clone/deeply x)]
        (tset y :a 2)
        (tset y :b :c 3)
        (table.insert x.d 4)
        (t.= {:a 1 :b {:c 2} :d [1 2 3 4]} x)
        (t.= {:a 2 :b {:c 3} :d [1 2 3]} y))))

  (testing "table merge!"
    (it "can merge!" []
      (let [x {:a 1}
            y {:b nil}
            z {:c 3}]
        (merge! x y z)
        (t.= {:a 1 :c 3} x)
        (t.= {:b nil} y)
        (t.= {:c 3} z)))
    (it "raises error against empty args" []
      (t.error "table expected, got nil"
               #(merge!))))

  (testing "comparator/table"
    (local xs [2 3 1 0 3 2])
    (it "sorts items by table order" []
      (table.sort xs (comparator/table [3 2]))
      (t.= [3 3 2 2 0 1] xs))
    (it "can use non-sequential table order" []
      (table.sort xs (comparator/table {:a 2 :b 3}))
      (t.= [2 2 3 3 0 1] xs))
    (it "falls back to optional comparator" []
      (table.sort xs (comparator/table [3 2] #(> $1 $2)))
      (t.= [3 3 2 2 1 0] xs))
    (it "falls back to optional table comparator" []
      (table.sort xs (comparator/table [3] (comparator/table [0 1])))
      (t.= [3 3 0 1 2 2] xs))))

;; vim: lw+=testing,test,it spell
