# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog][1],
and this project adheres to [Semantic Versioning][2].

[1]: https://keepachangelog.com/en/1.0.0/
[2]: https://semver.org/spec/v2.0.0.html

## Unreleased

### Deprecated

- Executable name has been changed to `fnldoc`. Although, symbolic link
  `fenneldoc` that references `fnldoc` is provided.
- In `.fenneldoc`, the following keys have been renamed:
  - `sandbox` -> `sandbox?`
  - `toc` -> `toc?`
  - `function-signatures` -> `function-signatures?`
  - `insert-copyright` -> `copyright?`
  - `insert-license` -> `license?`
  - `insert-version` -> `version?`
  - `insert-comment` -> `final-comment?`
  - `modules-info.FILENAME.doc-order` ->`modules-info.FILENAME.order`

### Added

- Module-level description inside Fennel file [[#4]]:
  In Fennel files, top comments beginning with `;;;; ` are rendered as
  module-level description in Markdown documentation. You can still use
  `modules-info.FILENAME.description` in `.fenneldoc` alternatively.
- Module entries are now shown with their types (function or macro) [[#5]]:
  The type is inferred automatically; otherwise you can explicitly annotate
  it in metadata field `:fnldoc/type`.
- New option `--src-dir` (or `src-dir` entry in `.fenneldoc`) [[#10]]:
  If source files are placed in this directory, it will be stripped from
  destination path to generate documentation. For example, running
  `fnldoc --src-dir foo foo/file.fnl` generates documentation at
  `doc/file.md`.
- `modules-info.FILENAME.order` entry in `.fenneldoc` [[609a7f4]]:
  This was previously `modules-info.FILENAME.doc-order`, which accepted only
  a table of module item names. It has now the same functionality with `order`
  entry. Both accept `alphabetic`, `reverse-alphabetic`, a custom comparator
  function, or a table of ordered module items.
 
[#4]: https://todo.sr.ht/~m15a/fnldoc/4
[#5]: https://todo.sr.ht/~m15a/fnldoc/5
[#10]: https://todo.sr.ht/~m15a/fnldoc/10
[609a7f4]: https://git.sr.ht/~m15a/fnldoc/commit/609a7f4

### Fixed

- Generating empty documentation for function module [[#16]].
- Erroneous handling for file path beginning with `./` [[#9]].
- A bug that command line option `--order` not working [[609a7f4]].
- Unknown identifier error in sandbox environment [[d242b81]].
- ToC generation when there are no module exports [[6383334]].
- Gensym hash increment (e.g. `x#` -> `x###`) in markdown fences [[1a94362]].

[#9]: https://todo.sr.ht/~m15a/fnldoc/9
[#16]: https://todo.sr.ht/~m15a/fnldoc/16
[d242b81]: https://git.sr.ht/~m15a/fnldoc/commit/d242b81
[6383334]: https://git.sr.ht/~m15a/fnldoc/commit/6383334
[1a94362]: https://git.sr.ht/~m15a/fnldoc/commit/1a94362

### Internal changes

- Modules are reorganized according to the above executable name change.
- Version is now explicitly declared in the source code.
- Removed dependency to cljlib.

## Fenneldoc 1.0.1 (2023-05-16)

- Fix unconditional TOC generation
- fix iterations reuse results from conj
- Update cljlib

## Fenneldoc 1.0.0 (2022-31-10)

- Migrate to the latest cljlib, rewriting code to use namespaces, and immutable data structures.
- Remove `:keys`, and `:project-doc-order`.
- Allow test skipping via the `:skip-test` metadata for code blocks.

## Fenneldoc 0.1.9 (2022-13-06)

- Deprecate `:keys` config entry.
- Support for storing module info in the `.fenneldoc` config file.
- Support `__fenneldoc` metatable key for module info.
- Support nested modules.

## Fenneldoc 0.1.8 (2021-28-09)

- Create a shallow copy of `_G` when running tests with sandbox turned off.

## Fenneldoc 0.1.7 (2021-07-23)

- Ignore `_` argument by default.
- Fix doctests not working when sandbox is disabled.
- Remove luafilesystem dependency.
- Bump cljlib dependency to v0.5.4.
- Fix error handling when can't process a file.
- Disable compiler's strict global checking.

## Fenneldoc 0.1.6 (2021-05-09)

- Display `unknown` if filename somehow missing.
- Use `unknown` version name if Git can't figure out tag name.

## Fenneldoc 0.1.5 (2021-04-24)

- Warnings now use generic "value" term instead of calling everything a function.
- Exported variables are documented, but not tested, unless `fnl/arglist` metadata is found.

## Fenneldoc 0.1.4 (2021-02-25)

- Changed makefile to only compile the executable - no more Lua files.
- Heading link generation for table of contents adjusted to work for some edge cases.

## Fenneldoc 0.1.3 (2021-02-19)

- Allow shared project information such as license, copyright, and version to be stored in `.fenneldoc` configuration file.

## Fenneldoc 0.1.2 (2021-02-17)

- Add automatic resolution of inline references.
- Add new key `--config` to generate default config or update existing config by specifying keys to `fenneldoc`.

## Fenneldoc 0.1.1 (2021-02-16)

- Update cljlib to most recent version.
- Add ability to skip certain argument patterns when checking docstrings.

## Fenneldoc 0.1.0 (2021-01-24)

First stable release of Fenneldoc.

- Parse runtime information of a module.
- Configurable item order and sorting.
- Validate documentation:
  - Analyze documentation to contain descriptions arguments of the described function;
  - Run documentation tests, by looking for code inside backticks.
- Parse macro modules.
