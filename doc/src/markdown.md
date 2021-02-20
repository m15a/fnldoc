# Markdown.fnl (v0.1.3)
Functions for generating Markdown

**Table of contents**

- [`gen-markdown`](#gen-markdown)
- [`gen-function-signature`](#gen-function-signature)
- [`gen-item-documentation`](#gen-item-documentation)

## `gen-markdown`
Function signature:

```
(gen-markdown ([module-info config]))
```

Generate markdown feom `module-info` accordingly to `config`.

## `gen-function-signature`
Function signature:

```
(gen-function-signature ([function arglist config]))
```

Generate function signature for `function` from `arglist` accordingly to `config`.

## `gen-item-documentation`
Function signature:

```
(gen-item-documentation ([docstring mode]))
```

Generate documentation from `docstring`, and handle inline references
based on `mode`.


---

Copyright (C) 2020 Andrey Listopadov

License: [MIT](https://gitlab.com/andreyorst/fenneldoc/-/raw/master/LICENSE)


<!-- Generated with Fenneldoc v0.1.3
     https://gitlab.com/andreyorst/fenneldoc -->
