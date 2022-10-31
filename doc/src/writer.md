# Writer.fnl (v0.1.9)

**Table of contents**

- [`write-docs`](#write-docs)

## `write-docs`
Function signature:

```
(write-docs [docs file module-info config])
```

Accepts `docs` as a vector of lines, and a path to a `file`.
Concatenates lines in `docs` with newline, and writes result to
`file`.  `module-info` must contain `module` key with file, and
`config` must contain `out-dir` key.


---

Copyright (C) 2020-2022 Andrey Listopadov

License: [MIT](https://gitlab.com/andreyorst/fenneldoc/-/raw/master/LICENSE)


<!-- Generated with Fenneldoc v0.1.9
     https://gitlab.com/andreyorst/fenneldoc -->
