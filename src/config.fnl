(local fennel (require :fennel))
(import-macros {: fn*} :cljlib)

(local config {:fennel-path []
               :function-signatures true
               :ignored-args-patterns ["%.%.%."]
               :inline-references :link
               :insert-comment true
               :insert-copyright true
               :insert-license true
               :insert-version true
               :keys {:copyright "_COPYRIGHT"
                      :description "_DESCRIPTION"
                      :doc-order "_DOC_ORDER"
                      :license "_LICENSE"
                      :module-name "_MODULE_NAME"
                      :version "_VERSION"}
               :project-copyright nil
               :project-version nil
               :project-license nil
               :project-doc-order []
               :mode "checkdoc"
               :order "alphabetic"
               :out-dir "./doc"
               :sandbox true
               :test-requirements {}
               :toc true})

(fn* process-config [version]
  (match (pcall fennel.dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
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
     (fennel.view config)
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
- `keys` - a table of [special keys](#special-keys).
- `order` - sorting of items that were not given particular order.
Supported algorithms: alphabetic, reverse-alphabetic.
You also can specify a custom sorting function for this key.
- `sandbox` - whether to sandbox loading code and running documentation tests.

## Special keys

Special keys, are considered special, because they alter how
information about you module is gathered.  The following keys are
supported by `fenneldoc`:

- `license-key` -  license information of the module.
- `description-key` - the description of the module.
- `copyright-key` - copyright information of the module.
- `doc-order-key` - order of items of the module.
- `version-key` - the version of the module.

When found in exported module, values stored under keys specified by
these fields will be used as additional information about module. For
example, if you want your module to specify license in exported table
under different key, you can set `license-key` to desired value, and
then specify license under this key in you module:

`.fenneldoc`:
``` fennel
{:keys {:license-key \"project-license\"}}
```

``` fennel
(fn identity [x] x)

{:project-license \"MIT\"
 : identity}
```

Now `fenneldoc` will know that information about license is stored
under `project-license` key.

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
- `project-doc-order` - an associative table where keys are filenames
  and values are sequential tables with headings in preferred order."))

process-config

; LocalWords:  checkdoc fenneldoc config
