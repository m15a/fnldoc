# Sandbox.fnl (1.1.0-dev)

**Table of contents**

- Function: [sandbox](#function-sandbox)
- Function: [sandbox/overrides](#function-sandboxoverrides)

## Function: sandbox

```fennel
(sandbox file ?debug)
```

Create a sandboxed environment to run `file` for doctests.

Does not allow any IO, loading files or Lua code via `load`,
`loadfile`, and `loadstring`, using `rawset`, `rawset`, and `module`,
and accessing such modules as `os`, `debug`, `package`, and `io`.

This means that your files must not use these modules on the top
level, or run any code when file is loaded that uses those modules.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit.

## Function: sandbox/overrides

```fennel
(sandbox/overrides file overrides ?debug)
```

A variant of [`sandbox`](#function-sandbox) that will be overridden before running `file`.

You can provide an `overrides` table, which contains function name as
a key, and function as a value. This function will be used instead of
specified function name in the sandbox. For example, you can wrap IO
functions to only throw warning, and not error.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
