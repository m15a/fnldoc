# Config.fnl
Function signature:

```
(config version)
```

Process configuration file and merge it with default configuration.
Configuration is stored in `.fenneldoc` which is looked up in the
working directory.

Default configuration:

``` fennel
{:fennel-path []
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
 :mode "checkdoc"
 :order "aplhabetic"
 :out-dir "./doc"
 :test-requirements {}
 :toc true}
```

### Key descriptions

- `mode` - mode to operate in:
  - `checkdoc` - run checks and generate documentation files if no errors occurred.
  - `check` - only run checks
  - `doc` - only generate documentation files.
- `fennel-path` - add PATH to fennel.path for finding Fennel modules.
- `test-requirements` - code, that will be injected into each test in respecting module.
  For example, `{:somefile.fnl "(local {: foo1 :foo2} (require :somelib))"}` will inject the
  following code into beginning of each test.
- `function-signatures` - whether to generate function signatures in documentation.
- `final-comment` - whether to insert final comment with fenneldoc version.
- `copyright` - whether to insert copyright information.
- `license` - whether to insert license information from the module.
- `toc` - whether to generate table of contents.
- `out-dir` - path where to put documentation files.
- `keys` - a table of keys to lookup in modules to obtain additional info:
  - `license-key` -  license information of the module.
  - `description-key` - the description of the module.
  - `copyright-key` - copyright information of the module.
  - `doc-order-key` - order of items of the module.
  - `version-key` - the version of the module.
- `order` - sorting of items that were not given particular order.
  Supported algorithms: alphabetic, reverse-alphabetic.
  You also can specify a custom sorting function for this key.
- `sandbox` - whether to sandbox loading code and running documentation tests.



<!-- Generated with Fenneldoc 0.1.0
     https://gitlab.com/andreyorst/fenneldoc -->
