# Fnldoc

Generate documentation for your [Fennel] project.

[![ci]][builds]

## Synopsis

Let's say you have `your.fnl`:

```fennel
;;;; Your module description.

(fn hello []
  "Say hello."
  (print :hello))

(fn good-bye []
  "Say good bye. See also `hello'."
  (print :good-bye))

{: hello : good-bye}
```

Run `fnldoc your.fnl`, and you'll get `doc/your.md`:

````markdown
# Your.fnl

Your module description.

**Table of contents**

- Function: [good-bye](#function-good-bye)
- Function: [hello](#function-hello)

## Function: good-bye

```fennel
(good-bye)
```

Say good bye. See also [`hello`](#function-hello).

## Function: hello

```fennel
(hello)
```

Say hello.

<!-- Generated with Fnldoc 1.1.0-dev-68bbdc1
     https://sr.ht/~m15a/fnldoc/ -->
````

## Description

This is a fork of [Fenneldoc], with a number of bug fixes and some
new features.

### Features

- Generate Markdown documentation for Fennel code by analyzing
  metadata **and in-file comments**.
- Easy internal linking: just enclose any `` `item'`` in your module.
- **Show function type (function or macro) in documentation.**
- Run tests embedded in function docstring (a.k.a. doctest).
- Granular customizability for documentation contents.

Bold texts are major enhancements contributed by this fork.
Take a look at [`CHANGELOG.md`](./CHANGELOG.md) to find fixed bugs
and minor enhancements.

### Installation

Fnldoc runs with these dependencies:

- Lua: [PUC Lua] 5.3+ or [LuaJIT]
- Fennel: 1.4.2+ (only required when compiling to Lua script)

[GNU make] is also required as a build tool.

    $ git clone https://git.sr.ht/~m15a/fnldoc
    $ cd fnldoc
    $ make install PREFIX=$YOUR_FAVORITE_PATH

Alternative ways for installation:

- [Nix]: see its [usage](./nix/USAGE.md).

### Usage

#### Run Fnldoc

```console
fnldoc [OPTIONS] [FILE]...
```

Markdown documentation will be generated in `./doc` directory (default).

#### Write documentation

Fnldoc generates documentation from three sources:

1. Runtime information (e.g., metadata): each function/macro's
   description and module structure
2. Module top-level comments: documentation for each module file
3. Configuration file: project information such as copyright
 
For source 1, Fnldoc **runs your code** by executing `fennel.dofile`,
and collects runtime information, such as metadata and exported
functions. It does so in a restricted environment called **sandbox**,
so if your program has any side effects reachable during file loading,
you will get an error.
 
Use `--no-sandbox` flag in command line or `:sandbox` option in
configuration file to override this behavior
(see [Configuration](#configuration)).

##### Function docstring

Write docstring as usual, then Fnldoc generates description for
the function (or macro) accordingly. For example,

```fennel
(fn your-function [...]
  "`your-function`'s docstring."
  (print ...))

{: your-function}
```

The above function will get its documentation:

````markdown
## Function: your-function

```fennel
(your-function ...)
```

`your-function`'s docstring.
````

##### Macro docstring

Macros defined in a macro module, which may be imported by
`import-macros`, are automatically shown as macros in documentation:

````markdown
## Macro: your-macro

```fennel
(your-macro ...)
```

`your-macro`'s docstring.
````

If this does not suffice, you can explicitly annotate macros
using Fnldoc's metadata field `:fnldoc/type`:

```fennel
(fn your-macro [...]
  "`your-macro`'s docstring."
  {:fnldoc/type :macro}
  `(print ...))

{: your-macro}
```

##### Keep a function or macro private

Fnldoc searches for metadata recursively, meaning that functions or
macros contained in any table exposed in a module will be documented.
Sometimes you may not want a function or macro to be documented.
To prevent them from being documented by Fnldoc, you can specify
metadata field `:fnldoc/type` as `:private`. For example,

```fennel
(local exposed-table {})

(fn exposed-table.private-function [...]
  {:fnldoc/type :private}
  (do :something))

{: exposed-table}
```

##### Module top-level comments

Fnldoc scans Fennel code and search for module top-level comment lines
beginning with four semicolons `;;;; `, which will be inserted to
documentation as module description. For example, the following module

```fennel
;;;; Your module.

;;;; A line.
;;;;
;; This is usual comment.
;;;; Another line.

(fn fun []
  (do :something))

;;;; Here will be ignored as it's apart from the above top-level lines.

{: fun}
```

will get its Markdown documentation:

````markdown
# Your-module.fnl

Your module.

A line.

Another line.

**Table of contents**

- Function: [fun](#function-fun)

## Function: fun

```fennel
(fun)
```

**Undocumented**
````

##### Copyright, license, and version

You can add a footer section containing author name, copyright, and
license information via configuration
(see [Configuration](#configuration)). In the same manner, you can
specify project version or module version in configuration. The
specified version will be inserted into Markdown level-1 heading.

Configuration may be project-wide,

```fennel
{:project-copyright "Copyright (C) 20XX Your Name"
 :project-version "1.x.x"
 :project-license "[YOUR_LICENSE](link to your license file/URL)"}}}
```

or module-wide

```fennel
{:modules-info
 {"my-module.fnl"
  {:copyright "Copyright (C) 20XX Your Name"
   :version "1.x.x"
   :license "[YOUR_LICENSE](link to your license file/URL)"}}}
```

##### Inline reference

Fnldoc supports inline references (i.e., internal links) in
documentation by using Fnldoc's special notation: any text surrounded
by a backtick (``"`"``) and a single quote (`"'"`) will be converted
to an internal link.

For example, function `bar` in the following module has an inline
reference to function `foo`.

```fennel
(fn foo [...]
  (print ...))

(fn bar [...]
  "See `foo'."
  (foo ...))

{: foo : bar}
```

Fnldoc embeds internal links for `bar` to `foo`:

````markdown
**Table of contents**

- Function: [bar](#function-bar)
- Function: [foo](#function-foo)

## Function: bar

```
(bar ...)
```

See [`foo`](#function-foo).

## Function: foo

```
(foo ...)
```

**Undocumented**
````

If appropriate headings to be referenced are not found, it falls back
to plain ``"`code`"``.

Whether to replace inline references with link can be customized in
configuration entry `mode`
(see [Configuration](#configuration)).

##### Specifying order of contents

Fnldoc supports specifying order of items by passing a sequential
table of item names to `:order` configuration key. For example, say
we have a module with two functions:

```fennel
(fn first-function [...]
  (do :first-thing))

(fn another-function [...]
  (do :another-thing))

{: first-function : another-function}
```

Fnldoc sorts the table alphabetically by default, thus the order of
the documentation will be `another-function` followed by
`first-function`. You can override this behavior by specifying the
`:order` key for the file under `:modules-info` key in `.fenneldoc`:

```fennel
{:modules-info {
 "path/to/the/file.fnl" {:order [:first-function
                                 :another-function]}}}
```

If you wish to sort items differently from alphabetic order, you can
specify either `reverse-alphabetic`, or a custom comparator function,
which will be passed to Lua's `table.sort` function as its third
argument.

You can set this as a value for the `:order` key in configuration file,
or by passing it via `--order` flag in command line
(see [Configuration](#configuration)).
Note, that you can't pass sorting function via command-line argument.

#### Test documentation

Fnldoc understands Markdown code fences with `fennel` annotation as
test code to be validated, and run these tests embedded in
documentation unless the code fence also has `:skip-test` annotation.
For example, say we made a change in function but forgot to update
the docstring:

````fennel
(fn sum [a b]
  "Sums three arguments.

# Examples

``` fennel
(assert (= (sum 1 2 3) 6))
```"
  (+ a b))

{: sum}
````

This function claims that it sums three arguments, however the actual
body only sums two. If we run `fnldoc --mode check sum.fnl`, we'll get
the following:

````console
$ fnldoc --mode check sum.fnl
fnldoc [WARNING]: in file 'sum.fnl' function 'sum' has undocumented argument 'a'
fnldoc [WARNING]: in file 'sum.fnl' function 'sum' has undocumented argument 'b'
fnldoc [ERROR]: In file: 'sum.fnl'
Error in docstring for: 'sum'
In test:
``` fennel
(assert (= (sum 1 2 3) 6))
```
Error:
assertion failed!

fnldoc [ERROR]: errors in file 'sum.fnl'
````

On the other hand with `:skip-test` annotation,

````fennel
(fn sum [a b]
  "Sums three arguments.

# Examples

``` fennel :skip-test
(assert (= (sum 1 2 3) 6))
```"
  (+ a b))

{: sum}
````

the failing test will be skipped:

```console
$ fnldoc --mode check sum.fnl
fnldoc [WARNING]: in file 'sum.fnl' function 'sum' has undocumented argument 'a'
fnldoc [WARNING]: in file 'sum.fnl' function 'sum' has undocumented argument 'b'
fnldoc [INFO]: skipping test in 'sum'
```

By the way, did you notice that Fnldoc warned when finding
undocumented arguments?

```
fnldoc [WARNING]: in file 'sum.fnl' function 'sum' has undocumented argument 'a'
```

##### Test requirements

In most cases Fnldoc is smart enough, and can require your module's
exported functions automatically. However, if this doesn't work, you
can specify how dependencies should be required in `.fenneldoc`
configuration. Macro modules are such cases, and you'll have to teach
Fnldoc a proper require for your macro modules. For example,

```fennel
{:test-requirements
 {:path/to/macros.fnl "(import-macros {: a-macro} :path.to.macros)"}}
```

### Configuration

Run `fnldoc --help` and you'll find configuration options that can
be customized by command line flags.

If you like to configure options permanently, write out your
configuration in `.fenneldoc` file. Fnldoc looks for `.fenneldoc`
in your current directory and set options accordingly.

`.fenneldoc` should return a table of option settings. It looks
like this:

```fennel
{:out-dir "./doc"
 :src-dir "./lib"
 :mode :doc
 :toc? false
 :function-signatures? true
 :inline-references :code
 :order "alphabetic"
 :modules-info
 {"lib/module.fnl" {:order :reverse-alphabetic}}
 :test-requirements
 {"lib/module.fnl" "(import-macros {: great-macro} :your-macros)"}
 :project-copyright "YOUR NAME"
 :project-license "LICENSE"
 :project-version "VERSION"
 :sandbox? false}
```

You can generate `.fenneldoc` filled with defaults by invoking
`fnldoc --config`. If you want to generate a fresh `.fenneldoc`,
remove old `.fenneldoc` and run `fnldoc --config` again.
If you want to override configuration entries in `.fenneldoc`, pass
flags to `fnldoc` like this:

    $ fnldoc --no-toc --no-function-signatures --config

This will disable table of contents and function signatures in
generated `.fenneldoc`.

A full description of configuration options can be found in
[`doc/fnldoc/config.md`](./doc/fnldoc/config.md).

## Contributing

Report issues or feature requests on the project's [issue tracker]
or alternatively on [GitHub issues].
Send a patch to the project's [mailing list] or create a
[pull request on GitHub].
All contributions are welcome and highly appreciated.

## Licenses

Copyright (c) 2020 Andrey Orst, 2024 NACAMURA Mitsuhiro.
Unless otherwise stated, this software is distributed under
the [MIT license](./LICENSE).

[`test/faith.fnl`](./test/faith.fnl) is copyright (c) 2009-2024
Scott Vokes, Phil Hagelberg, and contributors, distributed under
the MIT license. See the license paragraphs at the beginning of
the file.

[Fennel]: https://fennel-lang.org/
[Fenneldoc]: https://gitlab.com/andreyorst/fenneldoc
[GNU make]: https://www.gnu.org/software/make/
[GitHub issues]: https://github.com/m15a/fnldoc/issues/
[LuaJIT]: https://luajit.org/
[Nix]: https://nixos.org/
[PUC Lua]: https://www.lua.org/
[builds]: https://builds.sr.ht/~m15a/fnldoc/commits/main/ci.yml
[ci]: https://builds.sr.ht/~m15a/fnldoc/commits/main/ci.yml.svg
[issue tracker]: https://todo.sr.ht/~m15a/fnldoc/
[mailing list]: https://lists.sr.ht/~m15a/public-inbox
[pull request on GitHub]: https://github.com/m15a/fnldoc/pulls/

<!-- vim: set tw=73 spell: -->
