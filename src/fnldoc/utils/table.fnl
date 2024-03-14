;;;; Table extras.

(local {: assert-type} (require :fnldoc.utils.assert))

(fn clone [tbl]
  "Return a shallow copy of the `table`, assuming that keys are string or number."
  {:fnl/arglist [table]}
  (collect [k v (pairs tbl)] k v))

(fn clone/deeply [tbl]
  "Return a deep copy of the `table`, assuming that keys are string or number."
  {:fnl/arglist [table]}
  (collect [k v (pairs tbl)]
    k
    (case (type v)
      :table (clone/deeply v)
      _ v)))

(fn merge! [tbl ...]
  "Merge all the non-sequential `tables` into the first `table`.

The operations will be executed from left to right.
It returns `nil`.

# Examples

```fennel
(doto {:a 1} (merge! {:a nil :b 1} {:b 2})) ;=> {:a 1 :b 2}
```"
  {:fnl/arglist [table & tables]}
  (let [to (assert-type :table tbl)]
    (each [_ from (ipairs [...])]
      (each [k v (pairs (assert-type :table from))]
        (tset to k v)))))

(fn comparator/table [tbl ?fallback]
  "Make a comparator for the elements of `table`.

The returned comparator compares its two arguments, namely *left* and *right*,
and returns `true` iff

- both the *left* and *right* appear in the table, and the *left*'s index in
  the `table` is smaller than the *right*'s;
- only the *left* appears in the `table`; or
- both do not appear in the table, and the `?fallback` comparator (default:
  `#(< $1 $2)`) against the *left* and *right* returns `true`.

**CAVEAT**: Make sure that the elements of `table` are each distinct.
"
  {:fnl/arglist [table ?fallback]}
  (let [index (collect [i x (pairs tbl)] x i)
        fallback (or ?fallback #(< $1 $2))]
     #(let [l (. index $1) r (. index $2)]
        (if (and l r)
            (< l r)
            (and l (= nil r))
            true
            (and (= nil l) r)
            false
            (fallback $1 $2)))))

{: clone : clone/deeply : merge! : comparator/table}
