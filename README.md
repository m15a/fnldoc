# Fenneldoc
Tool for automatic documentation generation and validation for Fennel language.

## Usage

    fenneldoc [flags] [files]

## Design
Fenneldoc loads files at runtime, and goes through exported definitions looking for specific Fennel metadata.
It then forms a `doc` directory, in which documentation files are placed following hierarchy of the project.
If module specifies `version` or `_VERSION` keyword, documentation is placed under the directory which corresponds to the version.

**Note!**
Fenneldoc **runs your code**, so if your program has side effects those will be executed.

## Features
- [x] Parse runtime information of the module.
- [ ] Validate documentation:
  - [ ] Analyze documentation to contain descriptions arguments of the described function,
  - [ ] Run documentation tests, by looking for code inside backticks.
- [ ] Parse macro modules.
  - Currently it is impossible to dynamically load macro module at runtime.

## Documentation format
Documentation is exported as a set of Markdown files, with file name corresponding to the module for which it was generated.
This doesn't mean that you have to use Markdown syntax in the documentation strings itself, but you'll benefit if you do.
One of the features planned for future release is documentation validation.

For example, we have a function `square` in a file `square.fnl`, and it has the following docstring:

```fennel
(fn square [x]
  "Return `x` squared.

# Examples

```fennel
(local x 5)
(assert (= (square x) 25))
```"
  (* x x))

{: square}
```

Running `fenneldoc` on this file will produce file `doc/square.md` with the following contents:

`````` markdown
# Square.fnl

**Table of contents**
- [`square`](#square)

## `square`
Function signature:

```
(square x)
```

Return `x` squared.

### Examples

```fennel
(local x 5)
(assert (= (square x) 25))
```


<!-- Generated with Fenneldoc x.y.z
     https://gitlab.com/andreyorst/fenneldoc -->
``````

## Contribute
Please do.
You can report issues or feature request at [project's Gitlab repository](https://gitlab.com/andreyorst/fenneldoc).
Consider reading [contribution guidelines](https://gitlab.com/andreyorst/fenneldoc/-/blob/master/CONTRIBUTING.md) beforehand.

<!--  LocalWords:  backticks docstring Fenneldoc TODO DDD
 -->
