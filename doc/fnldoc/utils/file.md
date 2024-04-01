# File.fnl (1.1.0-dev)

File and file path utilities.

**Table of contents**

- Function: [basename](#function-basename)
- Function: [dirname](#function-dirname)
- Function: [file-exists?](#function-file-exists)
- Function: [join-paths](#function-join-paths)
- Function: [make-directory](#function-make-directory)
- Function: [normalize](#function-normalize)
- Function: [path->function-name](#function-path-function-name)
- Function: [path->module-name](#function-path-module-name)
- Function: [remove-prefix-path](#function-remove-prefix-path)
- Function: [remove-suffix](#function-remove-suffix)

## Function: basename

```fennel
(basename path ?suffix)
```

Remove leading directory components from the `path`.

Trailing `/`'s are also removed unless the `path` is just `/`. Optionally,
a trailing `?suffix` will be removed if specified. However, if the
*basename* of `path` and `?suffix` is identical, it does not remove suffix.
This is for convenience on manipulating hidden files.

Compatible with GNU coreutils' `basename`.

### Examples

```fennel
(basename "/a/b") ;=> "b"
(basename "/a/b.ext/" ".ext") ;=> "b"
(basename "/a/b/.ext" ".ext") ;=> ".ext"
```

## Function: dirname

```fennel
(dirname path)
```

Remove the last non-slash component from the `path`.

Trailing `/`'s are removed. If the path contains no `/`'s, it returns `.`.

Compatible with GNU coreutils' `dirname` except it doesn't handle many paths
at once.

### Examples

```fennel
(dirname "/a/b") ;=> "a"
(dirname "a/b/") ;=> "a"
(dirname "a") ;=> "."
(dirname ".") ;=> "."
(dirname "..") ;=> "."
```

## Function: file-exists?

```fennel
(file-exists? path)
```

Return `true` if a file at the `path` exists.

## Function: join-paths

```fennel
(join-paths & paths)
```

Join all `paths` segments into one path.

### Examples

```fennel
(join-paths :a :b :c/) ;=> "a/b/c/"
(join-paths :a :b :c :..) ;=> "a/b"
```

## Function: make-directory

```fennel
(make-directory path ?parents? ?mode)
```

Make a directory of the `path`.

Just a thin wrapper for `mkdir` command.
If `?parents?` is truthy, add `--parents` option. If `?mode` is string or
number, add `--mode` option with the `?mode`.

It returns multiple values. The first value is `true` or `nil`, indicating
whether succeeded or failed to make the directory; the second string teaches
you the type of the third value, which is exit status or terminated signal.

## Function: normalize

```fennel
(normalize path)
```

Return normalized `path`.

The following things will be done.

1. Remove duplicated separators such like `a//b///c`;
2. resolve parent directory path element (i.e., `a/b/../d` => `a/d`);
3. remove current directory path element (i.e., `a/./b` => `a/b`); and
4. finally, if `path` gets empty string, replace it with `.`. However,
   if `path` is empty string at the beginning, it returns as is.

Trailing slash will be left as is.

### Examples

```fennel
(normalize "a//b///c/") ;=> "a/b/c/"
(normalize :a/b/../d) ;=> "a/d"
(normalize "./.") ;=> "."
```

## Function: path->function-name

```fennel
(path->function-name path)
```

Translate the `path` to its *basename* without `.fnl` extension.

This is used for converting function module file to its function name.

### Examples

```fennel
(path->function-name "a/b/c.fnl") ;=> :c
```

## Function: path->module-name

```fennel
(path->module-name path)
```

Translate the `path` to its module name.

### Examples

```fennel
(path->module-name "a/b/c.fnl") ;=> :a.b.c
```

## Function: remove-prefix-path

```fennel
(remove-prefix-path prefix path)
```

Strip the `prefix` component from `path`.

### Examples

```fennel
(remove-prefix-path "./a" "a/b/c/") ;=> "b/c/"
(remove-prefix-path "a/b/c/" "a/b/c") ;=> "."
```

## Function: remove-suffix

```fennel
(remove-suffix path suffix)
```

Remove `suffix` from the `path`.

If the basename of `path` and `suffix` is identical,
it does not remove suffix.
This is for convenience on manipulating hidden files.

### Examples

```fennel
(remove-suffix "/a/b.ext" ".ext") ;=> "/a/b"
(remove-suffix "/a/b/.ext" ".ext") ;=> "/a/b/.ext"
```

---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)

<!-- Generated with Fnldoc 1.1.0-dev
     https://sr.ht/~m15a/fnldoc/ -->
