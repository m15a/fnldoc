# Config.fnl (1.0.2-dev)

**Table of contents**

- [`init!`](#init)
- [`merge!`](#merge)
- [`new`](#new)
- [`set-fennel-path!`](#set-fennel-path)
- [`write!`](#write)

## `init!`
Function signature:

```
(init! {:config-file config-file :version version})
```


Read the `config-file` (default: `.fenneldoc`) and return a `config` object.

The `config` object is merged with the default configuration. In addition,

- append `config.fennel-path` to `fennel.path`, and
- set `config.fnldoc-version` according to the given `version`.

**Default configuration**:

``` fennel
{:copyright? true
 :fennel-path {}
 :final-comment? true
 :function-signatures? true
 :ignored-args-patterns ["%.%.%." "%_" "%_[^%s]+"]
 :inline-references "link"
 :license? true
 :mode "checkdoc"
 :modules-info {}
 :order "alphabetic"
 :out-dir "./doc"
 :sandbox? true
 :src-dir "./src"
 :test-requirements {}
 :toc? true
 :version? true}
```

### Key descriptions

#### `fennel-path`

Append extra paths to `fennel.path` for finding Fennel modules.

#### `out-dir`

Path where to put documentation files.

#### `src-dir`

Path where source files are placed in. This path prefix will be
stripped from destination path to generate documentation.

#### `mode`

Mode to operate in when running Fnldoc. It should be one of

- `:checkdoc` - run checks and generate documentation files if no
  errors occurred;
- `:check` - only run checks; or
- `:doc` - only generate documentation files.

#### `test-requirements`

A table that maps module file name to code, which will be injected into
each test in respecting module.

For example, when testing macro module,
`{:macro-module.fnl "(import-macros {: some-macro} :macro-module)"}`
will inject the following code into beginning of each test, hence
requiring needed macros. This should be not needed for ordinary modules,
as those are compiled before analyzing, which means macros and dependencies
should be already resolved.

#### `sandbox?`

Whether to sandbox loading code and running documentation tests.

#### `inline-references`

How to handle inline references. Inline references are denoted with
opening backtick and closed with single quote. Fnldoc supports several
modes to operate on inline references:

- `:link` - convert inline references into links to headings found in
  current file;
- `:code` - all inline references will be converted to inline code; or
- `:keep` - inline references are kept as is.

#### `toc?`

Whether to generate table of contents.

#### `function-signatures?`

Whether to generate function signatures in documentation.

#### `order`

Sorting of items that were not given particular order. Supported
algorithms: `:alphabetic` and `:reverse-alphabetic`. You also can
specify a custom sorting function for this key.

#### `ignored-args-patterns`

List of patterns to skip check of function argument docstring presence.

#### `copyright?`

Whether to insert copyright information.

#### `license?`

Whether to insert license information from the module.

#### `version?`

Whether to insert version information from the module.

#### `final-comment?`

Whether to insert a final HTML comment with Fnldoc version, i.e.,

```html
<!-- Generated with Fnldoc ... -->
```

#### Project information

You can store project information either in project files directly, as
described in the section above, or you can specify most (but not all)
of this information in the configuration file. Fnldoc provides the
following set of keys for that.

##### `project-copyright`

Copyright string of the project.

##### `project-license`

String that contains project license name or Markdown link.

##### `project-version`

Version information about your project that should appear in each file.
This version can be overridden for certain files by specifying version
in the module info.

##### `modules-info`

An associative table that holds file names and information about the
modules, contained in those. Supported keys: `:name`, `:description`,
`:order`, `:copyright`, `:license`, and `:version`. For example:

```fennel
{:modules-info
 {:some-module.fnl
  {:description "some module description"
   :license "GNU GPL"
   :name "Some Module"
   :order ["some-fn1" "some-fn2" "etc"]}}}
```

## `merge!`
Function signature:

```
(merge! self from)
```

Merge key-value pairs of the `from` table into `self` config object.
`self` will be mutated. Warn once if each `key` is deprecated.

## `new`
Function signature:

```
(new)
```

Create a new config object.

## `set-fennel-path!`
Function signature:

```
(set-fennel-path! self)
```

Append `self`'s `fennel-path` to `fennel.path`.

## `write!`
Function signature:

```
(write! self config-file ?debug)
```

Write contents of `self` to the `config-file` (default: `.fenneldoc`).

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit.


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
