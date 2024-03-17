;;;; Process configuration file.

(local fennel (require :fennel))
(local {: view : dofile : metadata} fennel)
(local console (require :fnldoc.console))
(local {: exit/error} (require :fnldoc.debug))
(local {: clone/deeply} (require :fnldoc.utils.table))

(local default (require :fnldoc.config.default))

(local deprecated
       {:project-doc-order {:use "the 'order' key in the 'modules-info' table"}
        :keys {:use "the 'modules-info' table to provide module information"}
        :sandbox {:new-key :sandbox?}
        :toc {:new-key :toc?}
        :function-signatures {:new-key :function-signatures?}
        :insert-license {:new-key :license?}
        :insert-version {:new-key :version?}
        :insert-comment {:new-key :final-comment?}})

(fn warn/deprecated [old-key {: new-key : use}]
  (let [use (or use (string.format "the '%s' key" new-key))
        msg (-> "the '%s' key was deprecated and no longer supported - use %s instead."
                (string.format old-key use))]
    (console.warn msg)))

(fn merge! [self from]
  "Merge key-value pairs of the `from` table into `self` config object.
`self` will be mutated. Warn once if each `key` is deprecated."
  (let [warned {}]
    (each [key value (pairs from)]
      (case (. deprecated key)
        info (do
               (when (not (. warned key))
                 (warn/deprecated key info)
                 (tset warned key true))
               (when info.new-key
                 (tset self info.new-key value)))
        _ (tset self key value)))))

(fn set-fennel-path! [self]
  "Append `self`'s `fennel-path` to `fennel.path`."
  (each [_ path (ipairs self.fennel-path)]
    (set fennel.path (.. path ";" fennel.path))))

(fn config->file-contents [config version]
  (table.concat [";; -*- mode: fennel; -*- vi:ft=fennel"
                 (.. ";; Configuration file for Fnldoc " version)
                 ";; https://sr.ht/~m15a/fnldoc/"
                 (-> (view config)
                     (string.gsub "\\\n" "\n")
                     (#(pick-values 1 $)))
                 ""] "\n"))

(fn write! [self config-file ?debug]
  "Write contents of `self` to the `config-file` (default: `.fenneldoc`).

For testing purpose, if `?debug` is truthy and failing, it raises an error
instead to exit."
  (let [config-file (or config-file :.fenneldoc)]
    (match (io.open config-file :w)
      f (with-open [file f]
          (let [version self.fnldoc-version]
            (set self.fnldoc-version nil)
            (file:write (config->file-contents self version))
            (set self.fnldoc-version version)))
      (nil msg code)
      (let [msg (string.format "failed to open file '%s': %s (%s)" config-file
                               msg code)]
        (exit/error msg ?debug)))))

(local mt {:__index {: merge! : set-fennel-path! : write!}})

(fn new []
  "Create a new config object."
  (let [self (clone/deeply default)]
    (setmetatable self mt)))

(fn init! [{: config-file : version}]
  (let [config-file (or config-file :.fenneldoc)
        config (new)]
    (case (pcall dofile config-file)
      (true from-file) (config:merge! from-file)
      (false msg)
      (when (not (msg:match (.. config-file ": No such file or directory")))
        (console.error msg)))
    (config:set-fennel-path!)
    (set config.fnldoc-version version)
    config))

(metadata:set init! :fnl/docstring (.. "
Read the `config-file` (default: `.fenneldoc`) and return a table of configuration.

The configuration table is generated by merging contents of the `config-file` with
default configuration.

While generating configuration, it does

- append `config.fennel-path` to `fennel.path`, and
- set `config.fnldoc-version` according to the given `version`.

**Default configuration**:

``` fennel
" (view default) "
```

# Key descriptions

## `mode`

Mode to operate in when running Fnldoc. It should be one of

- `:checkdoc` - run checks and generate documentation files if no errors
  occurred;
- `:check` - only run checks; or
- `:doc` - only generate documentation files.

## `out-dir`

Path where to put documentation files.

## `src-dir`

Path where source files are placed. This path prefix will be
stripped from destination path to generate documentation.

## `order`

Sorting of items in module documentation. Supported algorithms:

- `:alphabetic` - alphabetic order;
- `:reverse-alphabetic` - reverse alphabetic order;
- custom comparator function - it will be used as a second argument of
  Lua's `table.sort` function when sorting items; or
- sequential table of item name listing - items are sorted according to this
  listing.

## `inline-references`

How to handle inline references. Inline references are denoted with opening
backtick and closed with single quote (e.g., ```inline reference'``).
Fnldoc supports several modes to operate on inline references:

- `:link` - convert inline references into links to headings found in
  current file;
- `:code` - all inline references will be converted to inline code; or
- `:keep` - inline references are kept as is.

## `toc?`

Whether to generate table of contents.

## `function-signatures?`

Whether to generate function signatures in documentation.

## `ignored-args-patterns`

List of patterns to skip check of function argument docstring presence.

## `copyright?`

Whether to insert copyright information.

## `license?`

Whether to insert license information from the module.

## `version?`

Whether to insert version information from the module.

## `final-comment?`

Whether to insert a final HTML comment with Fnldoc version, i.e.,

```html
<!-- Generated with Fnldoc ... -->
```

## `sandbox?`

Whether to sandbox loading code and running documentation tests.

## `fennel-path`

Append extra paths to `fennel.path` for finding Fennel modules.

## `test-requirements`

A table that maps module file name to code, which will be injected into
each test in respecting module.

For example, when testing macro module, `{:macro-module.fnl \"(import-macros
{: some-macro} :macro-module)\"}` will inject the following code into
beginning of each test, hence requiring needed macros. This should be not
needed for ordinary modules, as those are compiled before analyzing,
which means macros and dependencies should be already resolved.

## Project information

You can store project information either in project files directly, as
described in the section above, or specify most (but not all) of this
information in the configuration file. Fnldoc provides the following set
of keys for that.

### `project-copyright`

Copyright string of the project.

### `project-license`

String that contains project license name or Markdown link.

### `project-version`

Version information about your project that should appear in each file.
This version can be overridden for certain files by specifying version
in the module info.

### `modules-info`

An associative table that holds file names and information about the
modules, contained in those. Supported keys: `:name`, `:description`,
`:order`, `:copyright`, `:license`, and `:version`. For example:

```fennel
{:modules-info
 {:some-module.fnl
  {:description \"some module description\"
   :license \"GNU GPL\"
   :name \"Some Module\"
   :order [\"some-fn1\" \"some-fn2\" \"etc\"]}}}
```

`:description` field overrides those written at the top of Fennel file
as comments beginning with `;;;; `.
`:order` can be `:alphabetic`, `:reverse-alphabetic`, a comparator function,
or a sequential table of item names, as the same as global `order` entry."))

{: default : new : merge! : set-fennel-path! : write! : init!}
