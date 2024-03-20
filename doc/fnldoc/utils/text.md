# Text.fnl (1.1.0-dev)

Utilities for text processing.

FIXME: Support Windows line ending.

**Table of contents**

- Function: [indent](#function-indent)
- Function: [lines->text](#function-lines-text)
- Function: [pad](#function-pad)
- Function: [pad/right](#function-padright)
- Function: [text->lines](#function-text-lines)
- Function: [wrap](#function-wrap)
- Function: [wrap/line](#function-wrapline)

## Function: indent

```fennel
(indent width text)
```

Indent `text` by `width`.

## Function: lines->text

```fennel
(lines->text lines ?eol)
```

Concatenate a sequential table of `lines` with `?eol` into a `text`.

`?eol` defaults to `"\n"`

## Function: pad

```fennel
(pad width text ?pad-char)
```

Pad `text` on the left side with `?pad-char` (default: " ") up to `width`.

## Function: pad/right

```fennel
(pad/right width text ?pad-char)
```

Pad `text` on the right side with `?pad-char` (default: " ") up to `width`.

## Function: text->lines

```fennel
(text->lines text ?eol)
```

Split `text` by `?eol` (default: `"\n"`) into a sequential table of lines.

The last empty after the last end of line (i.e., "") will be removed.

## Function: wrap

```fennel
(wrap width text ?eol)
```

Wrap each line in the `text` if the line length is longer than `width`.

`?eol` defaults to `"\n"`.

## Function: wrap/line

```fennel
(wrap/line line width ?eol)
```

Wrap a `line` into lines of the maximum `width` separated by `?eol`.

`?eol` defaults to `"\n"`.

FIXME: This is buggy if `width` is too short.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
