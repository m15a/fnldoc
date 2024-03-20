# Modinfo.fnl (1.1.0-dev)

Analyze Fennel code and extract module information.

## Overview

### Module types

There are three module types for generating documentation:

- a table of *functions*,
- a table of *macros*, and
- just a *function*.

These types are detected by trying to [`require-file`](#function-require-file) and see its
result.

### Extracting metadata

In general, a module may contain any type of object, but we only
need to care about table and function, since Fennel attaches
metadata only to functions. Tables are recursively searched for
metadata by [`find-metadata`](#function-find-metadata).

Each function may have metadata, which contains `:fnl/arglist`
and/or `:fnl/docstring`. These two entries are extracted by
[`extract-metadata`](#function-extract-metadata) and used for rendering function/macro signature
and description.

In addition, Fnldoc has its own metadata entry `:fnldoc/type`,
which will also be extracted and used to show which type the
function is. An example usage:

```fennel
(fn a-macro []
  {:fnldoc/type :macro}
  `(print :a-macro))
```

However, `:fnldoc/type` annotation is not mandatory for *macros*
module, since it is clear that functions in a *macros* module are
macros, and it will properly detected.

### Module description

In addition to [`require-file`](#function-require-file), Fnldoc does
[`extract-module-description`](#function-extract-module-description) by scanning the file and searching
for top-level module description. The module description should
begin with four semicolons `;;;; `.

### Module information

Analyzed information in the above sections will be combined into
module information, which is a table that summarizes the module
and contains all relevant metadata. This task is done by
[`module-info`](#function-module-info) function.

**Table of contents**

- Function: [`extract-metadata`](#function-extract-metadata)
- Function: [`extract-module-description`](#function-extract-module-description)
- Function: [`find-metadata`](#function-find-metadata)
- Function: [`module-info`](#function-module-info)
- Function: [`require-file`](#function-require-file)

## Function: `extract-metadata`

```
(extract-metadata value)
```

Extract metadata from the `value`; return `nil` if not found.

## Function: `extract-module-description`

```
(extract-module-description file)
```

Extract module description from the top of the `file`.

It collects top comments beginning with `^%s*;;;; ` and returns a
string in which `;;;; ` is stripped from each line. Lines that match
`^%s*;;;;$` or `^%s*$` are counted as empty lines in the string.

### Example

In the following Fennel module file,

```fennel
#!/usr/bin/env fennel
;;;; A paragraph.

;;;; Another paragraph.
;;;;
;; This is usual comment.
;;;; More paragraph.

(fn f [] (print :hello))

;;;; This line will be ignored. Only top comments are scanned.

{: f}
```

Module description is collected as:

```
A paragraph.

Another paragraph.

More paragraph.
```

## Function: `find-metadata`

```
(find-metadata module)
```

Find metadata contained in the `module` table recursively.

It returns a table that maps module (table or function) name to
its metadata.

## Function: `module-info`

```
(module-info file config ?debug)
```

Return a table containing all relevant information accordingly
to `config` about the module in the `file` for which documentation is
generated. The result contains the following entries.

- `name`: Module name if specified in `.fenneldoc`.
- `description`: Module description, specified in `.fenneldoc` or
  extracted from the top comments of the file.
- `type`: Module type, either `:functions`, `:macros`, or `:function`.
- `items`: Module contents, which will be used for doctest-ing.
- `test-requirements`: Doctest requirements if specified in `.fenneldoc`.
- `metadata`: Recursively extracted metadata of module items.
- `order`: Item sorting order if specified in `.fenneldoc`.
- `copyright`: Copyright information if specified in `.fenneldoc`.
- `license`: License information if specified in `.fenneldoc`.
- `version`: Version information if specified in `.fenneldoc`.

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit.

## Function: `require-file`

```
(require-file file sandbox?)
```

Require `file` as module in protected call with/out `sandbox?`-ing.

Return multiple values with the first value corresponding to `pcall`
result. The second value is a table that contains the following
entries.

- `type`: Module's value type, i.e., `:table`, `:string`, etc.
- `module`: Module contents.
- `macros?`: Indicates whether this is a *macros* module.
- `loaded-macros`: Macros if any loaded found.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
