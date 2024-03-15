# Argparse.fnl (1.0.2-dev)

**Table of contents**

- [`parse`](#parse)

## `parse`
Function signature:

```
(parse args ?debug)
```

Parse command line `args` and return the result.

The result contains attributes:

- `write-config?`: Whether to write the final config, after merged with that comming
  from `.fenneldoc`, to `.fenneldoc`.
- `show-help?`: Whether to show Fnldoc help and exit.
- `show-version?`: Whether to show Fnldoc version and exit.
- `config`: Parsed config that will be merged into that comming from `.fenneldoc`.
- `files`: Target Fennel file names to be proccessed.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit.


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
