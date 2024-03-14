(local t (require :test.faith))
(local ua (require :fnldoc.utils.assert))

(fn test-assert-type []
  (t.= nil (ua.assert-type :nil nil))
  (t.= false (ua.assert-type :boolean false))
  (t.= 10 (ua.assert-type :number 10))
  (t.= "string" (ua.assert-type :string "string"))
  (let [f (fn [] true)]
    (t.= f (ua.assert-type :function f)))
  (t.= {:a :table} (ua.assert-type :table {:a :table}))
  (t.error "invalid type name: nil" #(ua.assert-type))
  (t.error "invalid type name: \"tab\"" #(ua.assert-type :tab {}))
  (t.error "number expected, got {}" #(ua.assert-type :number {}))
  (t.error "number expected, got nil" #(ua.assert-type :number)))

{: test-assert-type}
