# Modinfo.fnl (1.0.2-dev)

**Table of contents**

- [`extract-metadata`](#extract-metadata)
- [`find-metadata`](#find-metadata)
- [`module-info`](#module-info)
- [`require-file`](#require-file)

## `extract-metadata`

Function signature:

```
(extract-metadata value)
```

Extract metadata from the `value`; return `nil` if not found.

## `find-metadata`

Function signature:

```
(find-metadata module)
```

Find metadata contained in the `module` table recursively.

It returns a table that maps module (table or function) name to its metadata.

## `module-info`

Function signature:

```
(module-info file config)
```

Returns table containing all relevant information accordingly to
`config` about the module in the `file` for which documentation is
generated.

## `require-file`

Function signature:

```
(require-file file sandbox?)
```

Require `file` as module in protected call with/out `sandbox?`-ing.

Return multiple values with the first value corresponding to pcall result.
The second value is a table that contains

* `:type` - module's value type, i.e., `table`, `string`, etc.;
* `:module` - module contents;
* `:macros?` - indicates whether this is a macro module; and
* `:loaded-macros` - macros if any loaded found.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
