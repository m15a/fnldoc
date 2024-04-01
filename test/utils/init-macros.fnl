;; fennel-ls: macro-file

(local unpack (or table.unpack _G.unpack))

(fn test [name arglist & body]
  (assert-compile (= :string (type name)) "invalid test name" name)
  `{,(.. :test- name) (fn ,arglist ,(unpack body))})

(fn %string->id [str]
  (pick-values 1 (-> str
                     (string.gsub "&" "and")
                     (string.gsub "#" "numbersign")
                     (string.gsub "%$" "dollar")
                     (string.gsub ";" "semicolon")
                     (string.gsub "[\"'`%(%){}%[%]]+" "")
                     (string.gsub "[ %.:]+" "-"))))

(fn %it->test [testing-name spec-description ...]
  (assert-compile (= :string (type spec-description))
                  "invalid test spec description"
                  spec-description)
  (let [name (.. testing-name :- (%string->id spec-description))]
    (test name ...)))


(fn testing [name & body]
  "A wrapper macro to define test module.

In `testing` macro,

- forms beginning with `fn`, `lambda`, or `λ` and named either `setup`,
  `setup-all`, `teardown`, or `teardown-all` are exported as Faith's
  setup/teardown functions;
- forms beginning with `it` or `test` are exported as Faith's test functions;
  and
- the other forms are evaluated before the above Faith exports.

For example,

```
(testing :foo
  (fn setup-all []
    (do :setup-all))
  (it \"should do this\" []
    (do :this))
  (test :that []
    (do :that)))
  (do :something :beforehand)
```

will be translated to

```
(do
  (do :something :beforehand)
  {:setup-all (fn [] (do :setup-all))
   :test-foo-should-do-this (fn [] (do :this))
   :test-that (fn [] (do :that))})
```"
  (assert-compile (= :string (type name)) "invalid testing name" name)
  (let [name (%string->id name)
        do-body []
        setups {}
        tests []]
    (each [_ form (ipairs body)]
      (case (tostring (. form 1))
        :test (table.insert tests form)
        :it (table.insert tests (%it->test name (unpack form 2)))
        (where (or :fn :lambda :λ))
        (let [function-id (. form 2)]
          (table.insert do-body form)
          (case (tostring function-id)
            (where (or :setup :setup-all :teardown :teardown-all))
            (tset setups (tostring function-id) function-id)))
        _ (table.insert do-body form)))
    (table.insert do-body `(let [exports# ,setups]
                             (each [_# test# (ipairs ,tests)]
                               (each [tname# tfn# (pairs test#)]
                                 (tset exports# tname# tfn#)))
                             exports#))
    `(do
       ,(unpack do-body))))

{: testing : test}
