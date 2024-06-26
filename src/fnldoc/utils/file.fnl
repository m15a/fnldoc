;;;; File and file path utilities.

(local unpack (or table.unpack _G.unpack))
(local {: assert-type} (require :fnldoc.utils.assert))
(local {: escape-regex} (require :fnldoc.utils.string))

(local path-separator (package.config:sub 1 1))

(fn trailing-sep? [path]
  (if (path:match (.. path-separator "$")) true false))

(fn %normalize [path]
  (let [s path-separator
        had-trailing-sep? (trailing-sep? path)
        sds (.. s "%." s) ; /./
        ss->s #($:gsub (.. s "+") s)
        sds->s! #(do
                   (while ($:match sds) (set $ ($:gsub sds s)))
                   $)
        asdd->d #($:gsub (.. "[^" s "]+" s "%.%.") ".")
        ^ds-> #($:gsub (.. "^%." s) "")
        sd$-> #($:gsub (.. s "%.$") "")
        ->d #(if (= "" $) "." $)
        path (-> path
                 (ss->s)   ; //  -> /
                 (sds->s!) ; /./ -> /
                 (asdd->d) ; any-dir/.. -> .
                 (sds->s!) ; again!
                 (^ds->)   ; ^./ -> ''
                 (sd$->)   ; /.$ -> ''
                 (->d))]   ; '' -> .
    (if (trailing-sep? path)
        path
        (if had-trailing-sep?
            (.. path s)
            path))))

(lambda normalize [path]
  "Return normalized `path`.

The following things will be done.

1. Remove duplicated separators such like `a//b///c`;
2. resolve parent directory path element (i.e., `a/b/../d` => `a/d`);
3. remove current directory path element (i.e., `a/./b` => `a/b`); and
4. finally, if `path` gets empty string, replace it with `.`. However,
   if `path` is empty string at the beginning, it returns as is.

Trailing slash will be left as is.

# Examples

```fennel
(normalize \"a//b///c/\") ;=> \"a/b/c/\"
(normalize :a/b/../d) ;=> \"a/d\"
(normalize \"./.\") ;=> \".\"
```"
  (assert-type :string path)
  (if (= "" path)
      ""
      (%normalize path)))

(fn %remove-suffix [path suffix]
  (case (path:match (.. "^(.*)" (escape-regex suffix) "$"))
    stripped (if (or (= "" stripped) (trailing-sep? stripped))
                 path
                 stripped)
    _ path))

(lambda remove-suffix [path suffix]
  "Remove `suffix` from the `path`.

If the basename of `path` and `suffix` is identical,
it does not remove suffix.
This is for convenience on manipulating hidden files.

# Examples

```fennel
(remove-suffix \"/a/b.ext\" \".ext\") ;=> \"/a/b\"
(remove-suffix \"/a/b/.ext\" \".ext\") ;=> \"/a/b/.ext\"
```"
  (assert-type :string path)
  (assert-type :string suffix)
  (%remove-suffix path suffix))

(lambda basename [path ?suffix]
  "Remove leading directory components from the `path`.

Trailing `/`'s are also removed unless the `path` is just `/`. Optionally,
a trailing `?suffix` will be removed if specified. However, if the
*basename* of `path` and `?suffix` is identical, it does not remove suffix.
This is for convenience on manipulating hidden files.

Compatible with GNU coreutils' `basename`.

# Examples

```fennel
(basename \"/a/b\") ;=> \"b\"
(basename \"/a/b.ext/\" \".ext\") ;=> \"b\"
(basename \"/a/b/.ext\" \".ext\") ;=> \".ext\"
```"
  (let [sep path-separator
        path (normalize path)]
    (if (= sep path)
        path
        (case-try (path:match (.. "([^" sep "]*)" sep "?$"))
          path (if ?suffix
                   (%remove-suffix path (assert-type :string ?suffix))
                   path)
          path path
          (catch _ (error "unknown path matching error"))))))

(lambda dirname [path]
  "Remove the last non-slash component from the `path`.

Trailing `/`'s are removed. If the path contains no `/`'s, it returns `.`.

Compatible with GNU coreutils' `dirname` except it doesn't handle many paths
at once.

# Examples

```fennel
(dirname \"/a/b\") ;=> \"a\"
(dirname \"a/b/\") ;=> \"a\"
(dirname \"a\") ;=> \".\"
(dirname \".\") ;=> \".\"
(dirname \"..\") ;=> \".\"
```"
  (let [sep path-separator
        path (normalize path)]
    (if (= sep path)
        path
        (case-try (path:match (.. "(.-)" sep "?$"))
          path (path:match (.. "^(.*)" sep))
          path path
          (catch _ ".")))))

(lambda path->function-name [path]
  "Translate the `path` to its *basename* without `.fnl` extension.

This is used for converting function module file to its function name.

# Examples

```fennel
(path->function-name \"a/b/c.fnl\") ;=> :c
```"
  (basename path :.fnl))

(lambda path->module-name [path]
  "Translate the `path` to its module name.

# Examples

```fennel
(path->module-name \"a/b/c.fnl\") ;=> :a.b.c
```"
  (pick-values 1 (-> (normalize path)
                     (%remove-suffix :.fnl)
                     (string.gsub path-separator "."))))

(lambda join-paths [& paths]
  "Join all `paths` segments into one path.

# Examples

```fennel
(join-paths :a :b :c/) ;=> \"a/b/c/\"
(join-paths :a :b :c :..) ;=> \"a/b\"
```"
  (normalize (accumulate [path (. paths 1)
                          _ segment (ipairs [(unpack paths 2)])]
               (.. path path-separator segment))))

(lambda remove-prefix-path [prefix path]
  "Strip the `prefix` component from `path`.

# Examples

```fennel
(remove-prefix-path \"./a\" \"a/b/c/\") ;=> \"b/c/\"
(remove-prefix-path \"a/b/c/\" \"a/b/c\") ;=> \".\"
```"
  (let [s path-separator
        prefix (-> (normalize prefix)
                   (string.gsub (.. s "$") ""))
        path (normalize path)
        had-trailing-sep? (trailing-sep? path)]
    (let [removed (path:gsub (.. "^" prefix s "?") "")
          removed (if (= "" removed) "." removed)]
      (if (trailing-sep? removed)
          removed
          (if had-trailing-sep?
              (.. removed s)
              removed)))))

(lambda file-exists? [path]
  "Return `true` if a file at the `path` exists."
  (assert-type :string path)
  (case (io.open path)
    any (do
          (any:close) true)
    _ false))

(lambda make-directory [path ?parents? ?mode]
  "Make a directory of the `path`.

Just a thin wrapper for `mkdir` command.
If `?parents?` is truthy, add `--parents` option. If `?mode` is string or
number, add `--mode` option with the `?mode`.

It returns multiple values. The first value is `true` or `nil`, indicating
whether succeeded or failed to make the directory; the second string teaches
you the type of the third value, which is exit status or terminated signal."
  (let [path (normalize path)
        cmd (.. "mkdir " (if ?parents? "--parents " "")
                (if ?mode
                    (.. :--mode= (assert-type :string (tostring ?mode)) " ")
                    "")
                path)]
    (case (os.execute cmd)
      ;; Lua >= 5.2
      (?ok :exit status)
      (values ?ok :exit status)
      (?ok :signal signal)
      (values ?ok :signal signal)
      ;; Lua 5.1 / LuaJIT
      (where status (= 0 status))
      (values true :exit 0)
      (status)
      (values nil :exit status)
      _
      (error "unknown os.execute returns"))))

{: normalize
 : remove-suffix
 : basename
 : dirname
 : path->function-name
 : path->module-name
 : join-paths
 : remove-prefix-path
 : file-exists?
 : make-directory}
