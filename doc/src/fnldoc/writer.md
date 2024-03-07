# Writer.fnl (1.0.2-dev)

**Table of contents**

- [`write-docs`](#write-docs)

## `write-docs`
Function signature:

```
(write-docs docs file module-info config)
```

Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`.  `module-info` must contain `module` key with file, and
`config` must contain `out-dir` key.


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
