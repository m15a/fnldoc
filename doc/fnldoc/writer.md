# Writer.fnl (1.1.0-dev)

Functions related to writing generated documentation into respecting files.

**Table of contents**

- Function: [write!](#function-write)

## Function: write!

```fennel
(write! text path ?debug)
```

Write out the contents of `text` string to the `path`.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
