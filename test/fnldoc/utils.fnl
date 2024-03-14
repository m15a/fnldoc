(local t (require :test.faith))
(local u (require :fnldoc.utils))

(fn test-assert-type []
  (t.= nil (u.assert-type :nil nil))
  (t.= false (u.assert-type :boolean false))
  (t.= 10 (u.assert-type :number 10))
  (t.= "string" (u.assert-type :string "string"))
  (let [f (fn [] true)]
    (t.= f (u.assert-type :function f)))
  (t.= {:a :table} (u.assert-type :table {:a :table}))
  (t.error "invalid type name: nil" #(u.assert-type))
  (t.error "invalid type name: \"tab\"" #(u.assert-type :tab {}))
  (t.error "number expected, got {}" #(u.assert-type :number {}))
  (t.error "number expected, got nil" #(u.assert-type :number)))

{: test-assert-type}
