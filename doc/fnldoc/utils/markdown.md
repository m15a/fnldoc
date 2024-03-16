# Markdown.fnl (1.0.2-dev)

**Table of contents**

- [`bold`](#bold)
- [`bold-italic`](#bold-italic)
- [`code`](#code)
- [`code-block`](#code-block)
- [`code-fence`](#code-fence)
- [`heading`](#heading)
- [`italic`](#italic)
- [`link`](#link)
- [`ordered-list`](#ordered-list)
- [`promote-headings`](#promote-headings)
- [`string->anchor`](#string-anchor)
- [`unordered-list`](#unordered-list)

## `bold`

Function signature:

```
(bold text)
```

Make a **bold** `text`.

## `bold-italic`

Function signature:

```
(bold-italic text)
```

Make a ***bold italic*** `text`.

## `code`

Function signature:

```
(code text)
```

Show `text` as an inline `code`.

## `code-block`

Function signature:

```
(code-block text)
```

Indent `text` by four spaces.

## `code-fence`

Function signature:

```
(code-fence text ?annotation)
```

Enclose `text` by at least three backticks; optionally attaching `?annotation`.

## `heading`

Function signature:

```
(heading level title)
```

Make a heading of specified `level` by prepending `#` in front of the `title`.

## `italic`

Function signature:

```
(italic text)
```

Make an *italic* `text`.

## `link`

Function signature:

```
(link text url)
```

Make a hyperlink of `text` pointing to the `url`.

## `ordered-list`

Function signature:

```
(ordered-list texts)
```

Make an ordered list from the sequential table of `texts`.

1. Apple
2. Banana
3. Orange

## `promote-headings`

Function signature:

```
(promote-headings level text)
```

Promote headings included in the `text` by speficied `level`.

## `string->anchor`

Function signature:

```
(string->anchor string)
```

Translate the `string` to Markdown valid anchor id.

Empty ids may occur if we pass only restricted chars. Such ids are ignored.

## `unordered-list`

Function signature:

```
(unordered-list texts)
```

Make an unordered list from the sequential table of `texts`.

- Apple
- Banana
- Orange

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
