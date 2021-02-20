# Fenneldoc

Tool for automatic documentation generation and validation for the [Fennel](https://fennel-lang.org/) language.


## Usage

Fenneldoc looks for `.fenneldoc` configuration file in current directory, and accepts files for which documentation will be generated.

    fenneldoc [flags] [files]


## Design

Fenneldoc loads files at runtime, and goes through exported definitions looking for specific Fennel metadata.
It then forms a `doc` directory, in which documentation files are placed following hierarchy of the project.
If module specifies `version` or `_VERSION` keyword, documentation is placed under the directory which corresponds to the version.

**Note!**
Fenneldoc doesn't parse files, instead it **runs your code** by using `fennel.dofile`, and collects runtime information, such as metadata and exported functions.
It does so in a restricted environment, so if your program has any side effects reachable during file loading, you will get an error.
Use `--no-sandbox` or `:sandbox` option in config to override this behavior.


## Features

- [x] Load runtime information of the module.
- [x] Configurable item order and sorting.
- [x] Validate documentation:
  - [x] Analyze documentation to contain descriptions arguments of the described function;
  - [x] Run documentation tests, by looking for code inside backticks.
- [x] Parse macro modules.
- [x] Automatically generate file local links from inline references.


# Documentation format

Documentation is generated by analyzing function metadata at run time, and inserting it mostly as is into markdown formatted file.
This means that all markdown features are supported in the docstring, such as text attributes, cross-linking, commenting, e.t.c.

For example, here's how you might define information about your `my-module.fnl` file:

``` clojure
(local my-module-info {:_VERSION "0.1.0"
                       :_DESCRIPTION "Tag line or short description"
                       :_COPYRIGHT "Copyright info that appears at the end of the document"
                       :_LICENSE "[license](Link to your license)"})

(local my-module {})

(fn my-module.foo [args]
  "foo's docstring"
  (print args))
(fn my-module.bar [args]
  "bar's docstring, also see `foo'"
  (my-module.foo args))

(setmetatable my-module {:__index my-module-info})
```

Running `fenneldoc my-module.fnl` with default config will procure `doc/my-module.md` with the following contents:

`````` markdown
# My-module.fnl (0.1.0)
Tag line or short description

**Table of contents**

- [`bar`](#bar)
- [`foo`](#foo)

## `bar`
Function signature:

```
(bar args)
```

bar's docstring, also see [`foo`](#foo)

## `foo`
Function signature:

```
(foo args)
```

foo's docstring


---

Copyright info that appears at the end of the document

License: [license](Link to your license)


<!-- Generated with Fenneldoc fenneldoc-version
     https://gitlab.com/andreyorst/fenneldoc -->
``````

Note that `bar`'s documentation features a link to `foo`'s documentation.
For more info see [inline references](#inline-references).

You will also see warnings in the log, indicating that both `foo` and `bar` have undocumented `args` argument.


### Specifying order of documentation items

Since items in Lua tables have arbitrary order, it is impossible to reason about documentation order by inspecting tables returned from modules at runtime.
As an escape hatch, Fenneldoc supports specifying order of items in a sequential table in special key `:_DOC_ORDER` stored in the module table.
For example we have a module with two functions:

``` clojure
(fn first-function [...]
  "Do something with args."
  ...)

(fn another-function [...]
  "Do something else with args."
  ...)

{:first-function first-function
 :another-function another-function}
```

Because order of the items in exported table is arbitrary, Fenneldoc sorts the table alphabetically by default.
Thus the order of the documentation will be `another-function` followed by `first-function`.
You can override this behavior by adding `_DOC_ORDER` key into the table set to the `__index` metamethod:

``` clojure
(setmetatable
 {:first-function first-function
  :another-function another-function}
 {:__index
  {:_DOC_ORDER [:first-function :another-function]}})
```

Now the order will be preserved, and `first-function` will come first in generated documentation.
Note, that you don't need to specify all the keys of your module if you don't care about some specific functions of you module - any missing keys will be sorted alphabetically.

``` clojure
(setmetatable
 {:first-function first-function
  :another-function another-function
  :some some
  :extra extra
  :stuff stuff}
 {:__index
  {:_DOC_ORDER [:first-function :another-function]}})
```

The order of items in the case above will be `first-function`, `another-function`, `extra`, `some`, `stuff`.
Note, that the doc order also can be specified in `.fenneldoc` config file:

``` clojure
{;; rest of config
 :project-doc-order {"path/to/file.fnl" [:first-function :another-function]}}
```

If you wish to sort items differently from alphabetic order, you can specify either `reverse-alphabetic`, or sorting function.
You can set this as a value for the `:order` key in configuration file, or by passing it via `--order VALUE` flag.
Note, that you can't pass sorting function via command-line argument.


### Documentation validation

Documentation is tested by default.
When `fenneldoc` sees three backticks, followed by `fennel`, it treats everything as test code until it sees three backticks again.
For example, suppose we made a change in function but forgot to update the docstring:

``` clojure
(fn sum [a b]
  "Sums three arguments.

# Examples

``` fennel
(assert (= (sum 1 2 3) 6))
```"
  (+ a b))
```

This function claims that it sums three arguments, however the actual body only sums two.

If we run `fenneldoc --mode check sum.fnl`, we'll get the following:

    $ fenneldoc --mode check sum.fnl
    In file: sum.fnl
    Error in docstring for: sum
    In test:
    ``` fennel
    (assert (= (sum 1 2 3) 6))
    ```
    Error:
    assertion failed!

    Errors in module sum.fnl

This prevents confusion when updated function behavior doesn't match documentation.

In most cases `fenneldoc` is smart enough, and can require your module's exported functions without namespace prefix.
Therefore you can use functions literally in documentation, e.g. if you return a table, no need to destructure it manually, or store it in some `local` within the docstring.

However, if this doesn't work you can specify how dependencies should be required in `.fenneldoc` config.
This also doesn't work for macros, so you'll have to add in config a proper require for your macro modules.
You do so by writing piece of code as a string under the key, which represents file being processed, and string contains instructing how to require additional dependencies and/or macros:

``` clojure
{;; rest of config
 :test-requirements {:macro-module.fnl "(import-macros {: some-macro} :macro-module)"}}
```


## Inline references

Fenneldoc supports automatic resolution of inline references in documentation strings.
For example, when docstring contains the following string ``Calls `foo' on its arguments.`` here ```foo'`` is an inline reference.
Inline references start with backtick (backquote) and end with single quote.
Fenneldoc looks up matching heading in currently processed file and replaces inline reference to link, if such heading exists.
If heading wasn't found such reference will be replaced to inline code, unless `inline-references` is set to `:keep`.


## Configuration

Fenneldoc can be configured by placing `.fenneldoc` file at the root of your project, where `fenneldoc` will be called.
Another way is to pass command lines to `fenneldoc` directly. Full set of command line arguments can be found by calling `fenneldoc --help`.

Configuration file is simply a fennel file without extension, which exports a table with keys.
Example of configuration file:

``` clojure
{:keys {:version :VERSION}
 :toc false
 :out-dir "./documentation"}
```

Here, we configure Fenneldoc to look for module version via `:VERSION` key, as opposed to default `:_VERSION`.
Next we say that we do not need table of contents, by specifying `:toc false`, change output directory to `./documentation`, and suppress all messages and error reports.

There are other options that can be set up on per project basis, see [config.md](./doc/src/config.md) file for more info.
Full set of available options can also be seen by calling `fenneldoc --help`.


### Config generation

Fenneldoc can generate configuration file for you with all default options, or update existing config by passing flags to `fenneldoc`.
If you want to generate fresh config, remove your old `.fenneldoc` file, and run `fenneldoc --config`.
This will create default `.fenneldoc` configuration file.
If you want to alter this file contents, you can pass flags to `fenneldoc` like this:

    fenneldoc --no-toc --no-function-signatures --config --mode doc

This will permanently disable table of contents, function signatures and documentation validation for current project.

## Contributing

Please do.
You can report issues or feature request at [project's Gitlab repository](https://gitlab.com/andreyorst/fenneldoc).
Consider reading [contribution guidelines](https://gitlab.com/andreyorst/fenneldoc/-/blob/master/CONTRIBUTING.md) beforehand.

<!--  LocalWords:  backticks docstring Fenneldoc TODO config runtime
      LocalWords:  metadata AST fnl foo's md Lua namespace Gitlab
      LocalWords:  destructure backtick backquote metamethod
      LocalWords:  LocalWords
  -->
