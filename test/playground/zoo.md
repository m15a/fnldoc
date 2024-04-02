# Testing Markdown Rendering 

This file is meant to check how different code hosting services
(e.g., GitHub) render Markdown differently.

## Headings

According to [The Markdown Guide][1], many Markdown processors support
customizing heading ids. Let's test this feature on sourcehut and
GitHub! 

### Level 3

#### Level 4

##### Level 5

###### Level 6

### A heading {#custom-id}

[A heading](#custom-id).

Another heading
---------------

## Styles

- **Bold** and __another bold__
- *Italic* and _another italic_
- ***Bold italic*** and ___another bold italic___
- **Nested bold and *italic***, ***once** again*, *and __more__*
  _and __more___
- ~~Strike through~~
- `Code` and ``nested `code` ``
- Emoji :joy:
- ==Highlight== (most services may not support it)

## Lists

- Unordered
- List
  - Nest

* Another unordered
  * Nest
* List

1. Ordered
  1. Nest
    1. Nest 
2. List

+ Once
+ more

1. Lazy
2. Ordered
  1. Nest
    1. Nest 
3. List

- [ ] Todo
- [x] List

## Blocks

> Quote
> continues.

> Nested
>> quote.

> ### Quote
> 
> - with
> - structure

    Code
    block.

```
Code fence.
```

```fennel
(fn code-fence/annotation []
  (do :check-markdown-rendering))
```

````markdown
```
Nested code fence.
```
````

## Links

- [Normal](https://link-example.org)
- [Anchor link](#links)
- [Reference link][link]
- [Lazy reference link]
- <https://example.autolink.com>

[link]: https://reference-link-example.com "title"
[Lazy reference link]: https://lazy-lazy-lazy.io

## Links

This heading duplicates the above heading. How different hosting
services generate anchors for the twins?

## Footer

Hello[^1].

[^1]: Good bye.

## Tables

| AAAA | BBBB | CCCC |
| - | - | - |
| 1 | 2 | 3 |
| 4 | 5 | 6 |

| AAAA  | BBBB | CCCC |
| :- | :-: | -: |
| 1  |  2  |  3 |
| 4  |  5  |  6 |

## Callouts

These guys may work only on GitHub.

> [!NOTE]
> Note.

> [!TIP]
> Tip.

> [!IMPORTANT]
> Important.

> [!WARNING]
> Warning.

> [!CAUTION]
> Caution.

## References

1. [The Markdown Guide][1]
2. [GitHub Docs - Basic writing and formatting syntax][2]
3. [GitHub Flavored Markdown Spec][3]
4. [GitLab Flavored Markdown (GLFM)][4]
5. [ComomonMark Spec][5]

---

Horizontal rule.

[1]: https://www.markdownguide.org/
[2]: https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax
[3]: https://github.github.com/gfm/
[4]: https://docs.gitlab.com/ee/user/markdown.html
[5]: https://spec.commonmark.org/

<!-- vim:set tw=72 spell: -->
