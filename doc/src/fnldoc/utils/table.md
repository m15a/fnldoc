# Table.fnl (1.0.2-dev)

**Table of contents**

- [`clone`](#clone)
- [`clone/deeply`](#clonedeeply)
- [`merge!`](#merge)

## `clone`
Function signature:

```
(clone table)
```

Return a shallow copy of the `table`, assuming that keys are string or number.

## `clone/deeply`
Function signature:

```
(clone/deeply table)
```

Return a deep copy of the `table`, assuming that keys are string or number.

## `merge!`
Function signature:

```
(merge! table & tables)
```

Merge all the non-sequential `tables` into the first `table`.

The operations will be executed from left to right.
It returns `nil`.

### Examples

```fennel
(doto {:a 1} (merge! {:a nil :b 1} {:b 2})) ;=> {:a 1 :b 2}
```


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
