# Processor.fnl (1.0.2-dev)

**Table of contents**

- [`destination-path`](#destination-path)
- [`process!`](#process)

## `destination-path`

Function signature:

```
(destination-path module-info config)
```

Determine path to put generated Markdown according to `module-info` and `config`.

## `process!`

Function signature:

```
(process! file config)
```

Extract module information from the `file`, run doctests, and generate Markdown.

Whether to run doctests and/or to generate markdown depends on preferences specified
in the `config`. Generated documentation will be placed under `config.out-dir`.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
