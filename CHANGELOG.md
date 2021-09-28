## Fenneldoc 0.1.8 (20201-28-09)

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

<!--  LocalWords:  Fenneldoc backticks cljlib docstrings config
 -->
