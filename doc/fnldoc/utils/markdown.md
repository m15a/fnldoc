# Markdown.fnl (1.0.2-dev)

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

Signature:

```
(bold text)
```

Make a **bold** `text`.

## Function: `bold-italic`

Signature:

```
(bold-italic text)
```

Make a ***bold italic*** `text`.

## Function: `code`

Signature:

```
(code text)
```

Show `text` as an inline `code`.

## Function: `code-block`

Signature:

```
(code-block text)
```

Indent `text` by four spaces.

## Function: `code-fence`

Signature:

```
(code-fence text ?annotation)
```

Enclose `text` by at least three backticks; optionally attaching `?annotation`.

## Function: `heading`

Signature:

```
(heading level title)
```

Make a heading of specified `level` by prepending `#` in front of the `title`.

## Function: `italic`

Signature:

```
(italic text)
```

Make an *italic* `text`.

## Function: `link`

Signature:

```
(link text url)
```

Make a hyperlink of `text` pointing to the `url`.

## Function: `ordered-list`

Signature:

```
(ordered-list texts)
```

Make an ordered list from the sequential table of `texts`.

1. Apple
2. Banana
3. Orange

## Function: `promote-headings`

Signature:

```
(promote-headings level text)
```

Promote headings included in the `text` by speficied `level`.

## Function: `string->anchor`

Signature:

```
(string->anchor string)
```

Translate the `string` to Markdown valid anchor id.

Empty ids may occur if we pass only restricted chars. Such ids are ignored.

## Function: `unordered-list`

Signature:

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
