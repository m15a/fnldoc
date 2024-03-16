# Console.fnl (1.0.2-dev)

**Table of contents**

- [`error`](#error)
- [`info`](#info)
- [`isatty?`](#isatty)
- [`log`](#log)
- [`log*`](#log-1)
- [`warn`](#warn)

## `error`

Function signature:

```
(error ...)
```

Print error message to STDERR.

Short hand for `(log* {:level :error} ...)`.

## `info`

Function signature:

```
(info ...)
```

Print info message to STDERR.

Short hand for `(log* {:level :info} ...)`.

## `isatty?`

Function signature:

```
(isatty? fd)
```

Check if the file descriptor `fd` is a TTY.

## `log`

Function signature:

```
(log ...)
```

Print message, without level specified, to STDERR.

Short hand for `(log* {} ...)`.

## `log*`

Function signature:

```
(log* {:color? color? :level level :out out} ...)
```

Print `...` to STDERR (default) in specified `level`.

`level` can be one of `:info`, `:warning` (or `:warn`), and `:error`;
other than those will be ignored.

If file handle `out` is specified, print it to the `out` instead.

If `color?` is truthy, use color to print messages; if `false`,
use no color; and if `nil`, it infers whether to use color.

### Examples

```fennel
(let [log+ (fn [{: level} msg]
             (with-open [out (io.tmpfile)]
               (log* {: level : out :color? false} msg)
               (out:seek :set)
               (out:read :*a)))] 
  (assert (= "fnldoc: no level
"
             (log+ {} "no level")))
  (assert (= "fnldoc [INFO]: info
"
             (log+ {:level :info} "info")))
  (assert (= "fnldoc [WARNING]: warn
"
             (log+ {:level :warn} "warn")))
  (assert (= "fnldoc [WARNING]: warning
"
             (log+ {:level :warning} "warning")))
  (assert (= "fnldoc [ERROR]: error
"
             (log+ {:level :error} "error"))))
```

## `warn`

Function signature:

```
(warn ...)
```

Print warning message to STDERR.

Short hand for `(log* {:level :warning} ...)`.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
