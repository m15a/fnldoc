# Argparse.fnl (1.1.0-dev)

Process command line arguments.

**Table of contents**

- Function: [`help`](#function-help)
- Function: [`parse`](#function-parse)

## Function: `help`

```
(help color?)
```

Generate help message, decorated with ANSI escape code if `color?` is truthy.

## Function: `parse`

```
(parse args ?debug)
```

Parse command line `args` and return its result.

The result contains attributes:

- `write-config?`: Whether to write configuration, after merged with that
  coming from `.fenneldoc`, to `.fenneldoc`.
- `show-help?`: Whether to show Fnldoc help and exit.
- `show-version?`: Whether to show Fnldoc version and exit.
- `config`: Parsed configuration that will be merged into that coming from
  `.fenneldoc`.
- `files`: Target Fennel file names, which will be processed by Fnldoc.

For testing purpose, if `?debug` is truthy and `parse` fails, it raises an
error instead to exit.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
