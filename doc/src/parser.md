# Parser.fnl

**Table of contents**

- [`create-sandbox`](#create-sandbox)
- [`module-info`](#module-info)

## `create-sandbox`
Function signature:

```
(create-sandbox overrides)
```

Create sandboxed environment to run files containing documentation,
and tests from that documentation.

Does not allow any IO, loading files or Lua code via `load`,
`loadfile`, and `loadstring`, using `rawset`, `rawset`, and `module`,
and accessing such modules as `os`, `debug`, `package`, `io`.

This means that your files must not use these modules on the top
level, or run any code when file is loaded that uses those modules.

## `module-info`
Function signature:

```
(module-info file config)
```

Returns table containing all relevant information about the module
for which documentation is generated.


<!-- Generated with Fenneldoc 0.1.0
     https://gitlab.com/andreyorst/fenneldoc -->
