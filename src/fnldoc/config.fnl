(local fennel (require :fennel))
(local {: view : dofile : metadata} fennel)
(local console (require :fnldoc.console))

(fn deprecated-key-and-message [old new]
  (values old (string.format (.. "the '%s' key was deprecated and no longer supported"
                                 " - use %s instead.")
                             old new)))

(local deprecated*
       {:project-doc-order "the 'doc-order' key in the 'modules-info' table"
        :keys "the 'modules-info' table to provide module information"
        :sandbox "the 'sandbox?' key"
        :toc "the 'toc?' key"
        :function-signatures "the 'function-signatures?' key"
        :insert-license "the 'license?' key"
        :insert-version "the 'version?' key"
        :insert-comment "the 'final-comment?' key"})

(local deprecated (collect [k v (pairs deprecated*)]
                    (deprecated-key-and-message k v)))

(local default {:fennel-path []
                :out-dir :./doc
                :mode :checkdoc
                :test-requirements {}
                :sandbox? true
                :inline-references :link
                :toc? true
                :function-signatures? true
                :order :alphabetic
                :ignored-args-patterns ["%.%.%." "%_" "%_[^%s]+"]
                :copyright? true
                :license? true
                :version? true
                :final-comment? true
                :modules-info {}})

(fn merge! [self from]
  "Merge key-value pairs of the `from` table into `self` config object.
`self` will be mutated. Warn once if each `key` is deprecated."
  (let [warned {}]
    (each [key value (pairs from)]
      (case (. deprecated key)
        msg (when (not (. warned key))
              (console.warn msg)
              (tset warned key true)))
      (tset self key value))))

(fn set-fennel-path! [self]
  "Append `self`'s `fennel-path` to `fennel.path`."
  (each [_ path (ipairs self.fennel-path)]
    (set fennel.path (.. path ";" fennel.path))))

(fn write! [self config-file]
  "Write contents of `self` to the `config-file` (default: `.fenneldoc`)."
  (let [config-file (or config-file :.fenneldoc)]
    (match (io.open config-file :w)
      f (with-open [file f]
          (let [version self.fnldoc-version]
            (set self.fnldoc-version nil)
            (file:write ";; -*- mode: fennel; -*- vi:ft=fennel\n"
                        ";; Configuration file for Fnldoc " version "\n"
                        ";; https://sr.ht/~m15a/fnldoc/\n"
                        (pick-values 1
                                     (-> (view self)
                                         (string.gsub "\\\n" "\n")))
                        "\n")
            (set self.fnldoc-version version)))
      (nil msg code) (do
                       (console.error "failed to open file"
                                      (.. "'" config-file "':") msg
                                      (.. "(" code ")"))
                       (os.exit code)))))

(local mt {: merge! : set-fennel-path! : write!})

(fn new []
  "Create a new config object."
  (let [clone (collect [k v (pairs default)] k v)]
    ;; TODO: deep copy the default.
    (set clone.fennel-path [])
    (set clone.test-requirements {})
    (set clone.ignored-args-patterns ["%.%.%." "%_" "%_[^%s]+"])
    (set clone.modules-info {})
    (setmetatable clone {:__index mt})))

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
Read the `config-file` (default: `.fenneldoc`) and return a `config` object.

The `config` object is merged with the default configuration. In addition,

- append `config.fennel-path` to `fennel.path`, and
- set `config.fnldoc-version` according to the given `version`.

**Default configuration**:

``` fennel
" (view default) "
```

# Key descriptions

## `fennel-path`

Append extra paths to `fennel.path` for finding Fennel modules.

## `out-dir`

Path where to put documentation files.

## `mode`

Mode to operate in when running Fnldoc. It should be one of

- `:checkdoc` - run checks and generate documentation files if no
  errors occurred;
- `:check` - only run checks; or
- `:doc` - only generate documentation files.

## `test-requirements`

A table that maps module file name to code, which will be injected into
each test in respecting module.

For example, when testing macro module,
`{:macro-module.fnl \"(import-macros {: some-macro} :macro-module)\"}`
will inject the following code into beginning of each test, hence
requiring needed macros. This should be not needed for ordinary modules,
as those are compiled before analyzing, which means macros and dependencies
should be already resolved.

## `sandbox?`

Whether to sandbox loading code and running documentation tests.

## `inline-references`

How to handle inline references. Inline references are denoted with
opening backtick and closed with single quote. Fnldoc supports several
modes to operate on inline references:

- `:link` - convert inline references into links to headings found in
  current file;
- `:code` - all inline references will be converted to inline code; or
- `:keep` - inline references are kept as is.

## `toc?`

Whether to generate table of contents.

## `function-signatures?`

Whether to generate function signatures in documentation.

## `order`

Sorting of items that were not given particular order. Supported
algorithms: `:alphabetic` and `:reverse-alphabetic`. You also can
specify a custom sorting function for this key.

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

## Project information

You can store project information either in project files directly, as
described in the section above, or you can specify most (but not all)
of this information in the configuration file. Fnldoc provides the
following set of keys for that.

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
`:doc-order`, `:copyright`, `:license`, and `:version`. For example:

```fennel
{:modules-info
 {:some-module.fnl
  {:description \"some module description\"
   :license \"GNU GPL\"
   :name \"Some Module\"
   :doc-order [\"some-fn1\" \"some-fn2\" \"etc\"]}}}
```"))

{: new : merge! : set-fennel-path! : write! : init!}
