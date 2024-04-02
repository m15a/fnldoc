;;;; Process configuration file.

(local fennel (require :fennel))
(local {: view : dofile : metadata} fennel)
(local console (require :fnldoc.console))
(import-macros {: exit/error} :fnldoc.debug)
(import-macros {: for-all?} :fnldoc.utils)
(local {: clone/deeply} (require :fnldoc.utils.table))
(local {: sandbox} (require :fnldoc.sandbox))
(local {: recipes} (require :fnldoc.argparse))

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

(local validators/basic
       (collect [_ recipe (pairs recipes)]
         (values recipe.key
                 (if (recipe.key:match "%?$")
                     #(= :boolean (type $))
                     (= :order recipe.key)
                     (fn [x] (case (type x)
                               :string (recipe.validator x)
                               :table (for-all? [_ item (ipairs x)]
                                        (= :string (type item)))
                               :function true
                               _ false))
                     recipe.validator
                     recipe.validator
                     #(= :string (type $))))))

(local validators/module-info
       {:name #(= :string (type $))
        :description #(= :string (type $))
        :order validators/basic.order
        :copyright #(= :string (type $))
        :license #(= :string (type $))
        :version #(= :string (type $))})

(fn validate/module-info [key value]
  (case (. validators/module-info key)
    validate (validate value)
    _ (do
        (console.warn "unknown option '" key "' found")
        true)))

(local validators/more
       {:ignored-args-patterns
        (fn [x] (and (= :table (type x))
                     (for-all? [_ pattern (ipairs x)]
                        (= :string (type pattern)))))
        :test-requirements
        (fn [x] (and (= :table (type x))
                     (for-all? [path code (pairs x)]
                        (and (= :string (type path))
                             (= :string (type code))))))
        :fennel-path
        (fn [x] (and (= :table (type x))
                     (for-all? [_ path (ipairs x)]
                        (= :string (type path)))))
        :modules-info
        (fn [x] (and (= :table (type x))
                     (for-all? [path conf (pairs x)]
                       (and (= :string (type path))
                            (= :table (type conf))
                            (for-all? [k v (pairs conf)]
                              (validate/module-info k v))))))})

(fn validate [key value]
  (case (. validators/more key)
    validate (validate value)
    _ (case (. validators/basic key)
        validate (validate value)
        _ (do
            (console.warn "unknown option '" key "' found")
            true))))

(fn set! [self key value]
  "Set the `key`-`value` pair to `self` config object with validation.

Validation depends on the `key` type:

- boolean (e.g., `sandbox?`): check if the `value` type is `:boolean`;
- category: check using its validator
  (see [`fnldoc.argparse.cooker`](./fnldoc/argparse/cooker.md));
- number: check using its validator (ditto.); and
- string: check if the `value` type is `:string`."
  (if (validate key value)
      (tset self key value)
      (exit/error (.. "invalid option '" key "': " (view value)))))

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
               (case info.new-key
                 key (self:set! key value)))
        _ (self:set! key value)))))

(fn set-fennel-path! [self]
  "Append `self`'s `fennel-path` to `fennel.path`."
  (each [_ path (ipairs self.fennel-path)]
    (set fennel.path (.. path ";" fennel.path))))

(fn config->file-contents [config]
  (let [config* (clone/deeply config)
        version config.fnldoc-version]
    (set config*.fnldoc-version nil)
    (table.concat [";; -*- mode: fennel; -*- vi:ft=fennel"
                   (.. ";; Configuration file for Fnldoc " version)
                   ";; https://sr.ht/~m15a/fnldoc/"
                   (-> (view config*)
                       (string.gsub "\\\n" "\n")
                       (#(pick-values 1 $)))
                   ""] "\n")))

(fn write! [self config-file]
  "Write contents of `self` to the `config-file` (default: `.fenneldoc`)."
  (let [config-file (or config-file :.fenneldoc)]
    (match (io.open config-file :w)
      f (with-open [file f]
          (file:write (config->file-contents self)))
      (nil msg code)
      (let [msg (string.format "failed to open file '%s': %s (%s)" config-file
                               msg code)]
        (exit/error msg)))))

(local mt {:__index {: set! : merge! : set-fennel-path! : write!}})

(fn new []
  "Create a new config object."
  (let [self (clone/deeply default)]
    (setmetatable self mt)))

(fn init! [{: config-file : version}]
  (let [config-file (or config-file :.fenneldoc)
        config (new)]
    (case (pcall dofile config-file {:env (sandbox config-file)} config-file)
      (true from-file) (config:merge! from-file)
      (false msg)
      (when (not (msg:match (.. config-file ": No such file or directory")))
        (exit/error msg)))
    (config:set-fennel-path!)
    (set config.fnldoc-version version)
    config))

(metadata:set init! :fnl/docstring (.. "
Read the `config-file` and return a table of configuration.

The `config-file` defaults to `.fenneldoc` if missing. The configuration
table is generated by merging contents of the `config-file` with default
configuration.

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

* `:checkdoc` - run checks and generate documentation files if no errors
  occurred;
* `:check` - only run checks; or
* `:doc` - only generate documentation files.

## `out-dir`

Path where to put documentation files.

## `src-dir`

Path where source files are placed. This path prefix will be
stripped from destination path to generate documentation.

## `order`

Sorting of items in module documentation. Supported algorithms:

* `:alphabetic` - alphabetic order;
* `:reverse-alphabetic` - reverse alphabetic order;
* custom comparator function - it will be used as a second argument of
  Lua's `table.sort` function when sorting items; or
* sequential table of item name listing - items are sorted according to this
  listing.

## `inline-references`

How to handle inline references. Inline references are denoted with opening
backtick and closed with single quote (e.g., ```inline reference'``).
Fnldoc supports several modes to operate on inline references:

* `:link` - convert inline references into links to headings found in
  current file;
* `:code` - all inline references will be converted to inline code; or
* `:keep` - inline references are kept as is.

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

{: default : new : set! : merge! : set-fennel-path! : write! : init!}

;; vim: lw+=for-all?
