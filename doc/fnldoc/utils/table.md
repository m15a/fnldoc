# Table.fnl (1.0.2-dev)

**Table of contents**

- Function: [`clone`](#function-clone)
- Function: [`clone/deeply`](#function-clonedeeply)
- Function: [`comparator/table`](#function-comparatortable)
- Function: [`merge!`](#function-merge)

## Function: `clone`

Signature:

```
(clone table)
```

Return a shallow copy of the `table`, assuming that keys are string or number.

## Function: `clone/deeply`

Signature:

```
(clone/deeply table)
```

Return a deep copy of the `table`, assuming that keys are string or number.

## Function: `comparator/table`

Signature:

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


## Function: `merge!`

Signature:

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
