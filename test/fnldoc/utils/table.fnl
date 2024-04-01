(import-macros {: testing : test} :test.utils)
(local t (require :test.faith))
(local {: clone : clone/deeply : merge! : comparator/table}
       (require :fnldoc.utils.table))

(testing
  (test :clone []
    (let [x {:a 1 :b {:c 2} :d 1}
          y (clone x)]
      (tset y :a 2)
      (tset y :b :c 3)
      (t.= {:a 1 :b {:c 3} :d 1} x)
      (t.= {:a 2 :b {:c 3} :d 1} y)))

  (test :clone/deeply []
    (let [x {:a 1 :b {:c 2} :d [1 2 3]}
          y (clone/deeply x)]
      (tset y :a 2)
      (tset y :b :c 3)
      (table.insert x.d 4)
      (t.= {:a 1 :b {:c 2} :d [1 2 3 4]} x)
      (t.= {:a 2 :b {:c 3} :d [1 2 3]} y)))

  (test :merge! []
    (let [x {:a 1}
          y {:b nil}
          z {:c 3}]
      (merge! x y z)
      (t.= {:a 1 :c 3} x)
      (t.= {:b nil} y)
      (t.= {:c 3} z)))

  (test :merge!-raises-error-when-empty-args []
    (t.error "table expected, got nil"
             #(merge!)))

  (local xs [2 3 1 0 3 2])

  (test :comparator/table-sorts-items-by-table-order []
    (table.sort xs (comparator/table [3 2]))
    (t.= [3 3 2 2 0 1] xs))

  (test :comparator/table-fallback-comparator-works []
    (table.sort xs (comparator/table [3 2] #(> $1 $2)))
    (t.= [3 3 2 2 1 0] xs))

  (test :comparator/table-non-seq-table-can-be-used []
    (table.sort xs (comparator/table {:a 2 :b 3}))
    (t.= [2 2 3 3 0 1] xs))

  (test :comparator/table-fall-back-comparator-table-works []
    (table.sort xs (comparator/table [3] (comparator/table [0 1])))
    (t.= [3 3 0 1 2 2] xs)))
