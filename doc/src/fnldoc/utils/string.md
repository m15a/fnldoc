# String.fnl (1.0.2-dev)

**Table of contents**

- [`escape-regex`](#escape-regex)

## `escape-regex`
Function signature:

```
(escape-regex string)
```

Escape magic characters of Lua regex pattern in the `string`.

Return the escaped string.
The magic characters are namely `^$()%.[]*+-?`.
See the [Lua manual][1] for more detail.

[1]: https://www.lua.org/manual/5.4/manual.html#6.4.1

### Examples

```fennel
(assert (= "%.fnl%$" (escape-regex ".fnl$")))
```


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
