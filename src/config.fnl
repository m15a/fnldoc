(import-macros
 {: defn : ns : defn- : def}
 (doto :lib.cljlib require))

(ns config-utils
  (:require [fennel :refer [view dofile] :as fennel]))

(def :private
  deprecated-keys
  {:project-doc-order "'project-doc-order' was deprecated and no longer supported - use the 'doc-order' key in the 'modules-info' table."
   :keys "'keys' was deprecated and no longer supported - use the 'modules-info' table to provide module information instead."})

(def :private
  config
  {:fennel-path []
   :function-signatures true
   :ignored-args-patterns ["%.%.%." "%_" "%_[^%s]+"]
   :inline-references :link
   :insert-comment true
   :insert-copyright true
   :insert-license true
   :insert-version true
   :modules-info {}
   :project-copyright nil
   :project-version nil
   :project-license nil
   :mode "checkdoc"
   :order "alphabetic"
   :out-dir "./doc"
   :sandbox true
   :test-requirements {}
   :toc true})

(def :private
  warned {})

(defn process-config [version]
  (match (pcall dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
                (match (. deprecated-keys k)
                  msg (when (not (. warned k))
                        (io.stderr:write "WARNING: '.fenneldoc': " msg "\n")
                        (tset warned k true)))
                (tset config k v))
    (false msg) (when (not (msg:match ".fenneldoc: No such file or directory"))
                  (io.stderr:write msg "\n")))

  (each [_ path (pairs config.fennel-path)]
    (set fennel.path (.. path ";" fennel.path)))

  (set config.fenneldoc-version version)
  config)

(fennel.metadata:set
 process-config
 :fnl/docstring
 (.. "Process configuration file and merge it with default configuration.
Configuration is stored in `.fenneldoc` which is looked up in the
working directory.  Injects private `version` field in config.

Default configuration:

``` fennel
"
     (view config)
     "
```

# Key descriptions

- `mode` - mode to operate in:
  - `checkdoc` - run checks and generate documentation files if no
    errors occurred;
  - `check` - only run checks;
  - `doc` - only generate documentation files.
- `ignored-args-patterns` - list of patterns to check when checking
  function argument docstring presence check should be skipped.

- `inline-references` - how to handle inline references.  Inline
  references are denoted with opening backtick and closed with single
  quote.  Fenneldoc supports several modes to operate on inline
  references:
  - `:link` - convert inline references into links to headings found
    in current file.
  - `:code` - all inline references will be converted to inline code.
  - `:keep` - inline references are kept as is.
- `fennel-path` - add PATH to fennel.path for finding Fennel modules.
- `test-requirements` - code, that will be injected into each test in
  respecting module.
  For example, when testing macro module `{:macro-module.fnl
  \"(import-macros {: some-macro} :macro-module)\"}` will inject the
  following code into beginning of each test, hence requiring needed
  macros.  This should be not needed for ordinary modules, as those
  are compiled before analyzing, which means macros and dependencies
  should be already resolved.
- `function-signatures` - whether to generate function signatures in documentation.
- `final-comment` - whether to insert final comment with fenneldoc version.
- `copyright` - whether to insert copyright information.
- `license` - whether to insert license information from the module.
- `toc` - whether to generate table of contents.
- `out-dir` - path where to put documentation files.
- `order` - sorting of items that were not given particular order.
Supported algorithms: alphabetic, reverse-alphabetic.
You also can specify a custom sorting function for this key.
- `sandbox` - whether to sandbox loading code and running documentation tests.

## Project information

You can store project information either in project files directly, as
described in the section above, or you can specify most (but not all)
of this information in `.fenneldoc` configuration file. Fenneldoc
provides the following set of keys for that:

- `project-license` - string that contains project license name or
  Markdown link.
- `project-copyright` - copyright string.
- `project-version` - version information about your project that
  should appear in each file. This version can be overridden for
  certain files by specifying version in the module info.
- `modules-info` - an associative table that holds file names and
  information about the modules, contained in those.  Supported keys
  `:description`, `:copyright`, `:doc-order`, `:license`, `:name`,
  `:version`.  For example:

  ```fennel
  {:modules-info {:some-module.fnl {:description \"some module description\"
                                    :license \"GNU GPL\"
                                    :name \"Some Module\"
                                    :doc-order [\"some-fn1\" \"some-fn2\" \"etc\"]}}}
  ```"))

config-utils

;; LocalWords:  checkdoc fenneldoc config
