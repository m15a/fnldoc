# Debug.fnl (1.1.0-dev)

Utilities convenient for testing/debugging purpose.

These macros switch behavior depending on global `_G._FNLDOC_DEBUG`.
If the global is truthy at compile time, they raise error.
Otherwise, they do some IO stuff.

**Table of contents**

- Macro: [exit/error](#macro-exiterror)

## Macro: exit/error

```fennel
(exit/error & msgs)
```

Exit with warning `msgs` unless `_G._FNLDOC_DEBUG` is truthy at compile time.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
