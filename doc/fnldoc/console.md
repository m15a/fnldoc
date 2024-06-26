# Console.fnl (1.1.0-dev)

Utilities to print messages to console STDERR.

**Table of contents**

- Function: [error](#function-error)
- Function: [info](#function-info)
- Function: [isatty?](#function-isatty)
- Function: [log](#function-log)
- Function: [log*](#function-log-1)
- Function: [warn](#function-warn)

## Function: error

```fennel
(error ...)
```

Print error message to STDERR.

Short hand for `(log* {:level :error} ...)`.

## Function: info

```fennel
(info ...)
```

Print info message to STDERR.

Short hand for `(log* {:level :info} ...)`.

## Function: isatty?

```fennel
(isatty? fd)
```

Check if the file descriptor `fd` is a TTY.

`fd` should be a number of file descriptor; `1` for STDOUT and `2` for
STDERR. Internally, it runs `test -t $fd`. Results of this query is
cached.

## Function: log

```fennel
(log ...)
```

Print message, without level specified, to STDERR.

Short hand for `(log* {} ...)`.

## Function: log*

```fennel
(log* {:color? color? :level level :out out} ...)
```

Print `...` to STDERR (default) in specified `level`.

`level` can be one of `:info`, `:warning` (or `:warn`), and `:error`;
other than those will be ignored. If file handle `out` is specified, print
it to the `out` instead. If `color?` is truthy, use color to print messages;
if `false`, use no color; and if `nil`, it infers whether to use color.

## Function: warn

```fennel
(warn ...)
```

Print warning message to STDERR.

Short hand for `(log* {:level :warning} ...)`.

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
