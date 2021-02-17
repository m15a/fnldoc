# Markdown.fnl
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


<!-- Generated with Fenneldoc 0.1.2
     https://gitlab.com/andreyorst/fenneldoc -->
