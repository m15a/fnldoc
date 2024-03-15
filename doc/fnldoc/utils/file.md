# File.fnl (1.0.2-dev)

**Table of contents**

- [`basename`](#basename)
- [`dirname`](#dirname)
- [`file-exists?`](#file-exists)
- [`join-paths`](#join-paths)
- [`make-directory`](#make-directory)
- [`normalize`](#normalize)
- [`path->function-name`](#path-function-name)
- [`path->module-name`](#path-module-name)
- [`remove-prefix-path`](#remove-prefix-path)
- [`remove-suffix`](#remove-suffix)

## `basename`
Function signature:

```
(basename path ?suffix)
```

Remove leading directory components from the `path`.

Trailing `/`'s are also removed unless the `path` is just `/`.
Optionally, a trailing `?suffix` will be removed if specified. 
However, if the *basename* of `path` and `?suffix` is identical,
it does not remove suffix.
This is for convenience on manipulating hidden files.

Compatible with GNU coreutils' `basename`.

### Examples

```fennel
(assert (= :/ (basename :/)))
(assert (= :b (basename :/a/b)))
(assert (= :b (basename :a/b/)))
(assert (= ":" (basename ":")))
(assert (= :. (basename :.)))
(assert (= :.. (basename :..)))
(assert (= :b (basename :/a/b.ext :.ext)))
(assert (= :b (basename :/a/b.ext/ :.ext)))
(assert (= :.ext (basename :/a/b/.ext :.ext)))
```

## `dirname`
Function signature:

```
(dirname path)
```

Remove the last non-slash component from the `path`.

Trailing `/`'s are removed. If the path contains no `/`'s, it returns `.`.

Compatible with GNU coreutils' `dirname` except it doesn't handle many paths
at once.

### Examples

```fennel
(assert (= :/ (dirname :/)))
(assert (= :/a (dirname :/a/b)))
(assert (= :/a (dirname :/a/b/)))
(assert (= :a (dirname :a/b)))
(assert (= :a (dirname :a/b/)))
(assert (= :. (dirname :a)))
(assert (= :. (dirname :a/)))
(assert (= :. (dirname ":")))
(assert (= :. (dirname :.)))
(assert (= :. (dirname :..)))
```

## `file-exists?`
Function signature:

```
(file-exists? path)
```

Return `true` if a file at the `path` exists.

## `join-paths`
Function signature:

```
(join-paths & paths)
```

Join all `paths` segments, using separator into one path.

### Examples

```fennel
(assert (= :a/b/c/ (join-paths :a :b :c/)))
(assert (= :a/c (join-paths :a :. :c)))
(assert (= :a/b/ (join-paths :a :b :c :../)))
```

## `make-directory`
Function signature:

```
(make-directory path ?parents? ?mode)
```

Make a directory of the `path`. Just a thin wrapper for `mkdir` command.

If `?parents?` is truthy, add `--parents` option. If `?mode` is string or
number, add `--mode` option with the `?mode`.

It returns multiple values. The first value is `true` or `nil`, indicating
whether succeeded or failed to make the directory; the second string teaches
you the type of the third value, which is exit status or terminated signal.

## `normalize`
Function signature:

```
(normalize path)
```

Return normalized `path`.

The following things will be done.

1. Remove duplicated separators such like `a//b///c`;
3. resolve parent directory path element (i.e., `a/b/../d` => `a/d`);
2. remove current directory path element (i.e., `a/./b` => `a/b`); and
4. finally, if `path` gets empty string, replace it with `.`. However,
   if `path` is empty string at the beginning, it returns as is.

Trailing slash will be left as is.

### Examples

```fennel
(assert (= :a/b/c/ (normalize :a//b///c/)))
(assert (= :a/d (normalize :a/b/../d)))
(assert (= :a/ (normalize :a/b/../)))
(assert (= :../ (normalize :../)))
(assert (= :./ (normalize :./)))
(assert (= :./ (normalize :./a/../)))
(assert (= :. (normalize :./.)))
```

## `path->function-name`
Function signature:

```
(path->function-name path)
```

Translate the `path` to its basename without `.fnl` extension.

This is used for converting function module file to its function name.

### Examples

```fennel
(let [path "a/b/c.fnl"]
  (assert (= :c (path->function-name path))))
```

## `path->module-name`
Function signature:

```
(path->module-name path)
```

Translate the `path` to its module name.

### Examples

```fennel
(let [path "a/b/c.fnl"]
  (assert (= :a.b.c (path->module-name path))))

(let [path "../a/b/c.fnl"]
  (assert (= :...a.b.c (path->module-name path))))

(let [path "./a/b/c.fnl"]
  (assert (= :a.b.c (path->module-name path))))

(let [path "./a/b/.././c.fnl"]
  (assert (= :a.c (path->module-name path))))
```

## `remove-prefix-path`
Function signature:

```
(remove-prefix-path prefix path)
```

Strip the `prefix` component from `path`.

### Examples

```fennel
(assert (= :b/c/ (remove-prefix-path :./a :a/b/c/)))
(assert (= :c (remove-prefix-path :a/b/ :a/b/c)))
(assert (= :. (remove-prefix-path :a/b/c/ :a/b/c)))
(assert (= :./ (remove-prefix-path :a/b/c :a/b/c/)))
(assert (= :a/b (remove-prefix-path :a/b/c :a/b)))
```

## `remove-suffix`
Function signature:

```
(remove-suffix path suffix)
```

Remove `suffix` from the `path`.

If the basename of `path` and `suffix` is identical,
it does not remove suffix.
This is for convenience on manipulating hidden files.

### Examples

```fennel
(assert (= :/a/b (remove-suffix :/a/b.ext :.ext)))
(assert (= :/a/b/.ext (remove-suffix :/a/b/.ext :.ext)))
```


---

Copyright (C) 2020-2022 Andrey Listopadov, 2024 NACAMURA Mitsuhiro

License: [MIT](https://git.sr.ht/~m15a/fnldoc/tree/main/item/LICENSE)


<!-- Generated with Fnldoc 1.0.2-dev
     https://sr.ht/~m15a/fnldoc/ -->