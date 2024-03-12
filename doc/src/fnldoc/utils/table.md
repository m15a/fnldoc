# Table.fnl (1.0.2-dev)

**Table of contents**

- [`clone`](#clone)
- [`clone/deeply`](#clonedeeply)
- [`comparator/table`](#comparatortable)
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

## `comparator/table`
Function signature:

```
(comparator/table table ?fallback)
```

Make a comparator for the elements of `table`.

The returned comparator compares its two arguments, namely *left* and *right*,
and returns `true` iff

- both the *left* and *right* appear in the table, and the *left*'s index in
  the `table` is smaller than the *right*'s;
- only the *left* appears in the `table`; or
- both do not appear in the table, and the `?fallback` comparator (default:
  `#(< $1 $2)`) against the *left* and *right* returns `true`.

**CAVEAT**: Make sure that the elements of `table` are each distinct.


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
