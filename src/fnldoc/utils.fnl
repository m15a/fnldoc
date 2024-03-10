;;;; Miscellaneous utilities.

(local {: view} (require :fennel))

(fn assert-type [expected x]
  "Check if `x` is of the `expected` type.

Return evaluated `x` if passed the check; otherwise raise an error.

# Examples

```fennel
(let [x {:a 1}] (assert-type :table x)) ; => {:a 1}
```

```fennel :skip-test
(let [b :string] (assert-type :number b))
; => runtime error: number expected, got \"string\"
```"
  (assert (case expected
            :nil true
            :boolean true
            :number true
            :string true
            :function true
            :userdata true
            :thread true
            :table true)
          (.. "expected type invalid: " (view expected)))
  (assert (= expected (type x))
          (.. expected " expected, got " (view x)))
  x)

{: assert-type}
