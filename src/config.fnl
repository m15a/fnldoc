(local fennel (require :fennel))

(local config {:check-only false
               :fennel-path {}
               :function-signatures true
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
               :order "aplhabetic"
               :out-dir "./doc"
               :skip-check false
               :test-requirements {}
               :toc true})

(fn process-config [version]
  "Process configuration file and merge it with default configuration.
Configuration is stored in `.fenneldoc` which is looked up in the
working directory.

Default configuration:

``` fennel
{:check-only false
 :fennel-path []
 :function-signatures true
 :insert-comment true
 :insert-copyright true
 :insert-license true
 :insert-version true
 :keys {:copyright \"_COPYRIGHT\"
        :description \"_DESCRIPTION\"
        :doc-order \"_DOC_ORDER\"
        :license \"_LICENSE\"
        :module-name \"_MODULE_NAME\"
        :version \"_VERSION\"}
 :order \"aplhabetic\"
 :out-dir \"./doc\"
 :skip-check false
 :test-requirements {}
 :toc true}
```

# Key descriptions

- `check-only` - run documentation tests but do not generate documentation files.
- `skip-check` - do not preform documentation checks, just produce documentation files.
  **Note**: These two flags must not be used together.
- `fennel-path` - add PATH to fennel.path for finding Fennel modules.
- `test-requirements` - code, that will be injected into each test in respecting module.
  For example, `{:somefile.fnl \"(local {: foo1 :foo2} (require :somelib))\"}` will inject the
  following code into beginning of each test.
- `function-signatures` - whether to generate function signatures in documentation.
- `final-comment` - whether to insert final comment with fenneldoc version.
- `copyright` - whether to insert copyright information.
- `license` - whether to insert license information from the module.
- `toc` - whether to generate table of contents.
- `out-dir` - pathe where to put documentation files.
- `keys` - a table of keys to lookup in modules to obtain additional info:
  - `license-key` -  license information of the module.
  - `description-key` - the description of the module.
  - `copyright-key` - copyright information of the module.
  - `doc-order-key` - order of items of the module.
  - `version-key` - the version of the module.
- `order` - sorting of items that were not given particular order.
  Supported alghorithms: alphabetic, reverse-alphabetic.
  You also can specify a custom sorting function for this key."
  (match (pcall fennel.dofile :.fenneldoc)
    (true rc) (each [k v (pairs rc)]
                (tset config k v))
    (false msg) (when (not (msg:match ".fenneldoc: No such file or directory"))
                  (io.stderr:write msg "\n")))

  (each [_ path (pairs config.fennel-path)]
    (set fennel.path (.. path ";" fennel.path)))

  (set config.fenneldoc-version version)
  config)
