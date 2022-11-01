# Parser.fnl (v1.0.0)

**Table of contents**

- [`create-sandbox`](#create-sandbox)
- [`module-info`](#module-info)

## `create-sandbox`
Function signature:

```
(create-sandbox ([file]) ([file overrides]))
```

Create sandboxed environment to run `file` containing documentation,
and tests from that documentation.

Does not allow any IO, loading files or Lua code via `load`,
`loadfile`, and `loadstring`, using `rawset`, `rawset`, and `module`,
and accessing such modules as `os`, `debug`, `package`, `io`.

This means that your files must not use these modules on the top
level, or run any code when file is loaded that uses those modules.

You can provide an `overrides` table, which contains function name as
a key, and function as a value.  This function will be used instead of
specified function name in the sandbox.  For example, you can wrap IO
functions to only throw warning, and not error.

## `module-info`
Function signature:

```
(module-info [file config])
```

Returns table containing all relevant information accordingly to
`config` about the module in `file` for which documentation is
generated.


---

Copyright (C) 2020-2022 Andrey Listopadov

License: [MIT](https://gitlab.com/andreyorst/fenneldoc/-/raw/master/LICENSE)


<!-- Generated with Fenneldoc v1.0.0
     https://gitlab.com/andreyorst/fenneldoc -->
