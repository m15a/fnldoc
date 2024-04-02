;; fennel-ls: macro-file

;;;; Miscellaneous macros.

(fn copy [tbl]
  (let [c (collect [k v (pairs tbl)] k v)]
    (setmetatable c (getmetatable tbl))))

(fn for-all? [iter-tbl pred-expr ...]
  "Test if a predicate expression is truthy for all yielded by an iterator.

It checks whether a `predicate-expression` is truthy for all yielded by the
iterator. If so, it returns `true`, otherwise returns `false`.

Note that the `bindings` cannot have `&until` clause as the clause will be
inserted implicitly in this macro.

# Examples

```fennel
(let [q (for-all? [_ n (ipairs [:a 1 {} 2])]
          (= (type n) :number)) ;=> false
      ]
  (assert (= false q)))
```"
  {:fnl/arglist [bindings predicate-expression]}
  (assert-compile (and (sequence? iter-tbl) (<= 2 (length iter-tbl)))
                  "expected iterator binding table" iter-tbl)
  (assert-compile (not= nil pred-expr)
                  "expected predicate expression" pred-expr)
  (assert-compile (= nil ...)
                  "expected only one expression" ...)
  (let [found `found#
        iter-tbl (doto (copy iter-tbl)
                   (table.insert 1 found)
                   (table.insert 2 `true)
                   (table.insert `&until)
                   (table.insert `(not ,found)))]
    `(accumulate ,iter-tbl (if ,pred-expr ,found false))))

(fn for-some? [iter-tbl pred-expr ...]
  "Test if a predicate expression is truthy for some yielded by an iterator.

It runs through an iterator and in each step evaluates a `predicate-expression`.
If the evaluated result is truthy, it immediately returns `true`; otherwise
returns `false`.

Note that the `bindings` cannot have `&until` clause as the clause will be
inserted implicitly in this macro.

# Examples

```fennel
(let [q (for-some? [_ n (ipairs [:a 1 {} 2])]
          (= (type n) :number)) ;=> true
      ]
  (assert (= true q)))
```"
  {:fnl/arglist [bindings predicate-expression]}
  (assert-compile (and (sequence? iter-tbl) (<= 2 (length iter-tbl)))
                  "expected iterator binding table"
                  iter-tbl)
  (assert-compile (not= nil pred-expr)
                  "expected predicate expression" pred-expr)
  (assert-compile (= nil ...) "expected only one expression" ...)
  (let [found `found#
        iter-tbl (doto (copy iter-tbl)
                   (table.insert 1 found)
                   (table.insert 2 `false)
                   (table.insert `&until)
                   (table.insert found))]
    `(accumulate ,iter-tbl (if ,pred-expr true ,found))))

{: for-all? : for-some?}
