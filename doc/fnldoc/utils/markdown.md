# Markdown.fnl (1.1.0-dev)

Markdown-specific text processing facilities.

**Table of contents**

- Function: [`bold`](#function-bold)
- Function: [`bold-italic`](#function-bold-italic)
- Function: [`code`](#function-code)
- Function: [`code-block`](#function-code-block)
- Function: [`code-fence`](#function-code-fence)
- Function: [`heading`](#function-heading)
- Function: [`italic`](#function-italic)
- Function: [`link`](#function-link)
- Function: [`ordered-list`](#function-ordered-list)
- Function: [`promote-headings`](#function-promote-headings)
- Function: [`string->anchor`](#function-string-anchor)
- Function: [`unordered-list`](#function-unordered-list)

## Function: `bold`

```
(bold text)
```

Make a **bold** `text`.

## Function: `bold-italic`

```
(bold-italic text)
```

Make a ***bold italic*** `text`.

## Function: `code`

```
(code text)
```

Show `text` as an inline `code`.

## Function: `code-block`

```
(code-block text)
```

Indent `text` by four spaces.

## Function: `code-fence`

```
(code-fence text ?annotation)
```

Enclose `text` by at least three backticks; optionally attaching `?annotation`.

## Function: `heading`

```
(heading level title)
```

Make a heading of specified `level` by prepending `#` in front of the `title`.

## Function: `italic`

```
(italic text)
```

Make an *italic* `text`.

## Function: `link`

```
(link text url)
```

Make a hyperlink of `text` pointing to the `url`.

## Function: `ordered-list`

```
(ordered-list texts)
```

Make an ordered list from the sequential table of `texts`.

1. Apple
2. Banana
3. Orange

## Function: `promote-headings`

```
(promote-headings level text)
```

Promote headings included in the `text` by speficied `level`.

## Function: `string->anchor`

```
(string->anchor string)
```

Translate the `string` to Markdown valid anchor id.

Empty ids may occur if we pass only restricted chars. Such ids are ignored.

## Function: `unordered-list`

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

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
