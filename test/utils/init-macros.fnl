;; fennel-ls: macro-file

(local unpack (or table.unpack _G.unpack))
(local {: view} (require :fennel))

(fn testing [& body]
  "A wrapper macro to define test module.

In `testing` macro,

- forms beginning with `fn`, `lambda`, or `λ` and having name either
  `setup`, `setup-all`, `teardown`, or `teardown-all` are exported as Faith's
  setup/teardown functions;
- forms beginning with `it` or `test` are exported as Faith's test functions;
  and
- the other forms are evaluated before the above Faith exports.

For example,

```
(testing
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
   :test-it-should-do-this (fn [] (do :this))
   :test-that (fn [] (do :that))})
```"
  (let [do-body []
        setups {}
        tests []]
    (each [_ form (ipairs body)]
      (case (tostring (. form 1))
        (where (or :it :test))
        (table.insert tests form)
        (where (or :fn :lambda :λ))
        (case (tostring (. form 2))
          (where (or :setup :setup-all :teardown :teardown-all))
          (do
            (table.insert do-body form)
            (tset setups (tostring (. form 2)) (. form 2)))
          _ (table.insert do-body form))
        _ (table.insert do-body form)))
    (table.insert do-body `(let [exports# ,setups]
                             (each [_# test# (ipairs ,tests)]
                               (each [tname# tfn# (pairs test#)]
                                 (tset exports# tname# tfn#)))
                             exports#))
    `(do
       ,(unpack do-body))))

(fn test [name arglist & body]
  (let [tname (case (type name)
                :string (.. :test- name)
                _ (error (.. "invalid test name: " (view name))))]
    `{,tname (fn ,arglist ,(unpack body))}))

(fn it [desc arglist ...]
  (let [name (case (type desc)
               :string (.. :it- (desc:gsub "[ %.:&]+" "-"))
               _ (error (.. "invalid test description: " (view desc))))]
    (test name arglist ...)))

{: testing : test : it}
