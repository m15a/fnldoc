# Console.fnl (1.0.2-dev)

**Table of contents**

- [`error`](#error)
- [`info`](#info)
- [`log`](#log)
- [`warn`](#warn)

## `error`
Function signature:

```
(error & messages)
```

Print error `messages` to STDERR.

Short hand for `(log (table.concat messages " ") :error)`.

## `info`
Function signature:

```
(info & messages)
```

Print info `messages` to STDERR.

Short hand for `(log (table.concat messages " ") :info)`.

## `log`
Function signature:

```
(log message ?level ?out)
```

Print `message` to STDERR (default) in specified `?level`.

`?level` can be one of `:info`, `:warning` (or `:warn`), and `:error`;
other than those will be ignored.

If file handle `?out` is specified, print it to the `?out` instead.

### Examples

```fennel
(let [log* (fn [msg lvl]
             (with-open [out (io.tmpfile)]
               (log msg lvl out)
               (out:seek :set)
               (out:read :*a)))] 
  (assert (= "fnldoc: no level
"
             (log* "no level")))
  (assert (= "fnldoc: also no level
"
             (log* "also no level" false)))
  (assert (= "fnldoc [INFO]: info
"
             (log* "info" :info)))
  (assert (= "fnldoc [WARNING]: warn
"
             (log* "warn" :warn)))
  (assert (= "fnldoc [WARNING]: warning
"
             (log* "warning" :warning)))
  (assert (= "fnldoc [ERROR]: error
"
             (log* "error" :error))))
```

## `warn`
Function signature:

```
(warn & messages)
```

Print warning `messages` to STDERR.

Short hand for `(log (table.concat messages " ") :warning)`.


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->
