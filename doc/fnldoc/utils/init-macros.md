# Init-macros.fnl (1.1.0-dev)

Miscellaneous macros.

**Table of contents**

- Macro: [for-all?](#macro-for-all)
- Macro: [for-some?](#macro-for-some)

## Macro: for-all?

```fennel
(for-all? bindings predicate-expression)
```

Test if a predicate expression is truthy for all yielded by an iterator.

It checks whether a `predicate-expression` is truthy for all yielded by the
iterator. If so, it returns `true`, otherwise returns `false`.

Note that the `bindings` cannot have `&until` clause as the clause will be
inserted implicitly in this macro.

### Examples

```fennel
(let [q (for-all? [_ n (ipairs [:a 1 {} 2])]
          (= (type n) :number)) ;=> false
      ]
  (assert (= false q)))
```

## Macro: for-some?

```fennel
(for-some? bindings predicate-expression)
```

Test if a predicate expression is truthy for some yielded by an iterator.

It runs through an iterator and in each step evaluates a `predicate-expression`.
If the evaluated result is truthy, it immediately returns `true`; otherwise
returns `false`.

Note that the `bindings` cannot have `&until` clause as the clause will be
inserted implicitly in this macro.

### Examples

```fennel
(let [q (for-some? [_ n (ipairs [:a 1 {} 2])]
          (= (type n) :number)) ;=> true
      ]
  (assert (= true q)))
```

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
