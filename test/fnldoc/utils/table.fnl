(local t (require :test.faith))
(local ut (require :fnldoc.utils.table))

(fn test-clone []
  (let [x {:a 1 :b {:c 2} :d 1}
        y (ut.clone x)]
    (tset y :a 2)
    (tset y :b :c 3)
    (t.= {:a 1 :b {:c 3} :d 1} x)
    (t.= {:a 2 :b {:c 3} :d 1} y)))

(fn test-clone/deeply []
  (let [x {:a 1 :b {:c 2} :d [1 2 3]}
        y (ut.clone/deeply x)]
    (tset y :a 2)
    (tset y :b :c 3)
    (table.insert x.d 4)
    (t.= {:a 1 :b {:c 2} :d [1 2 3 4]} x)
    (t.= {:a 2 :b {:c 3} :d [1 2 3]} y)))

(fn test-merge! []
  (let [x {:a 1}
        y {:b nil}
        z {:c 3}]
    (ut.merge! x y z)
    (t.= {:a 1 :c 3} x)
    (t.= {:b nil} y)
    (t.= {:c 3} z)
    (t.error "table expected, got nil" #(ut.merge!))))

(fn test-comparator/table []
  (let [xs [2 3 1 0 3 2]]
    (table.sort xs (ut.comparator/table [3 2]))
    (t.= [3 3 2 2 0 1] xs)
    (table.sort xs (ut.comparator/table [3 0] #(> $1 $2)))
    (t.= [3 3 0 2 2 1] xs)
    (table.sort xs (ut.comparator/table {:a 2 :b 3}))
    (t.= [2 2 3 3 0 1] xs)
    (table.sort xs (ut.comparator/table [3] (ut.comparator/table [0 1])))
    (t.= [3 3 0 1 2 2] xs)))
{: test-clone : test-clone/deeply : test-merge! : test-comparator/table}
