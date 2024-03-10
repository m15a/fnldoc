;;;; Table extras.

(local {: assert-type} (require :fnldoc.utils))

(fn clone [tbl]
  "Return a shallow copy of the `table`, assuming that keys are string or number."
  {:fnl/arglist [table]}
  (collect [k v (pairs tbl)] k v))

(fn clone/deeply [tbl]
  "Return a deep copy of the `table`, assuming that keys are string or number."
  {:fnl/arglist [table]}
  (collect [k v (pairs tbl)]
    k (case (type v)
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

{: clone : clone/deeply : merge!}
