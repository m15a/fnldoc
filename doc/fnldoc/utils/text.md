# Text.fnl (1.0.2-dev)

**Table of contents**

- [`indent`](#indent)
- [`lines->text`](#lines-text)
- [`pad`](#pad)
- [`pad/right`](#padright)
- [`text->lines`](#text-lines)
- [`wrap`](#wrap)
- [`wrap/line`](#wrapline)

## `indent`

Function signature:

```
(indent width text)
```

Indent `text` by `width`.

## `lines->text`

Function signature:

```
(lines->text lines ?eol)
```

Concatenate a sequential table of `lines` with `?eol` into a `text`.

`?eol` defaults to `"\n"`

## `pad`

Function signature:

```
(pad width text ?pad-char)
```

Pad `text` on the left side with `?pad-char` (default: " ") up to `width`.

## `pad/right`

Function signature:

```
(pad/right width text ?pad-char)
```

Pad `text` on the right side with `?pad-char` (default: " ") up to `width`.

## `text->lines`

Function signature:

```
(text->lines text ?eol)
```

Split `text` by `?eol` (default: `"\n"`) into a sequential table of lines.

The last empty after the last end of line (i.e., "") will be removed.

## `wrap`

Function signature:

```
(wrap width text ?eol)
```

Wrap each line in the `text` if the line length is longer than `width`.

`?eol` defaults to `"\n"`.

## `wrap/line`

Function signature:

```
(wrap/line line width ?eol)
```

Wrap a `line` into lines of the maximum `width` separated by `?eol`.

`?eol` defaults to `"\n"`.

FIXME: This is buggy if `width` is too short.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
