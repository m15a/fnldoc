# Assert.fnl (1.0.2-dev)

**Table of contents**

- Function: [`assert-type`](#function-assert-type)

## Function: `assert-type`

Signature:

```
(assert-type expected x)
```

Check if `x` is of the `expected` type.

Return evaluated `x` if passed the check; otherwise raise an error.

### Examples

```fennel
(let [x {:a 1}] (assert-type :table x)) ; => {:a 1}
```

```fennel
(let [b :string] (assert-type :number b))
; => runtime error: number expected, got "string"
```

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
