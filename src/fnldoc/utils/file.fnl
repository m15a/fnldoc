;;;;File and file path utilities.

(local {: assert-type} (require :fnldoc.utils))
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
3. resolve parent directory path element (i.e., `a/b/../d` => `a/d`);
2. remove current directory path element (i.e., `a/./b` => `a/b`); and
4. finally, if `path` gets empty string, replace it with `.`. However,
   if `path` is empty string at the beginning, it returns as is.

Trailing slash will be left as is.

# Examples

```fennel
(assert (= :a/b/c/ (normalize :a//b///c/)))
(assert (= :a/d (normalize :a/b/../d)))
(assert (= :a/ (normalize :a/b/../)))
(assert (= :../ (normalize :../)))
(assert (= :./ (normalize :./)))
(assert (= :./ (normalize :./a/../)))
(assert (= :. (normalize :./.)))
```"
  (assert-type :string path)
  (if (= "" path)
      ""
      (%normalize path)))

(fn %remove-suffix [path suffix]
  (let [stripped (path:match (.. "^(.*)" (escape-regex suffix) "$"))]
    (if (or (= "" stripped) (trailing-sep? stripped))
        path
        stripped)))

(lambda remove-suffix [path suffix]
  "Remove `suffix` from the `path`.

If the basename of `path` and `suffix` is identical,
it does not remove suffix.
This is for convenience on manipulating hidden files.

# Examples

```fennel
(assert (= :/a/b (remove-suffix :/a/b.ext :.ext)))
(assert (= :/a/b/.ext (remove-suffix :/a/b/.ext :.ext)))
```"
  (assert-type :string path)
  (assert-type :string suffix)
  (%remove-suffix path suffix))

(lambda basename [path ?suffix]
  "Remove leading directory components from the `path`.

Trailing `/`'s are also removed unless the `path` is just `/`.
Optionally, a trailing `?suffix` will be removed if specified. 
However, if the *basename* of `path` and `?suffix` is identical,
it does not remove suffix.
This is for convenience on manipulating hidden files.

Compatible with GNU coreutils' `basename`.

# Examples

```fennel
(assert (= :/ (basename :/)))
(assert (= :b (basename :/a/b)))
(assert (= :b (basename :a/b/)))
(assert (= \":\" (basename \":\")))
(assert (= :. (basename :.)))
(assert (= :.. (basename :..)))
(assert (= :b (basename :/a/b.ext :.ext)))
(assert (= :b (basename :/a/b.ext/ :.ext)))
(assert (= :.ext (basename :/a/b/.ext :.ext)))
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
  "Remove the last non-slash component from each of the `paths`.

Trailing `/`'s are removed. If the path contains no `/`'s, it returns `.`.

Compatible with GNU coreutils' `dirname` except it doesn't handle many paths
at once.

# Examples

```fennel
(assert (= :/ (dirname :/)))
(assert (= :/a (dirname :/a/b)))
(assert (= :/a (dirname :/a/b/)))
(assert (= :a (dirname :a/b)))
(assert (= :a (dirname :a/b/)))
(assert (= :. (dirname :a)))
(assert (= :. (dirname :a/)))
(assert (= :. (dirname \":\")))
(assert (= :. (dirname :.)))
(assert (= :. (dirname :..)))
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
  "Translate the `path` to its basename without `.fnl` extension.

This is used for converting function module file to its function name.

# Examples

```fennel
(let [path \"a/b/c.fnl\"]
  (assert (= :c (path->function-name path))))
```"
  (basename path :.fnl))

(lambda path->module-name [path]
  "Translate the `path` to its module name.

# Examples

```fennel
(let [path \"a/b/c.fnl\"]
  (assert (= :a.b.c (path->module-name path))))

(let [path \"../a/b/c.fnl\"]
  (assert (= :...a.b.c (path->module-name path))))

(let [path \"./a/b/c.fnl\"]
  (assert (= :a.b.c (path->module-name path))))

(let [path \"./a/b/.././c.fnl\"]
  (assert (= :a.c (path->module-name path))))
```"
  (pick-values 1 (-> (normalize path)
                     (%remove-suffix :.fnl)
                     (string.gsub path-separator "."))))

(lambda file-exists? [path]
  "Return `true` if a file at the `path` exists."
  (assert-type :string path)
  (case (io.open path)
    any (do
          (any:close) true)
    _ false))

{: normalize
 : remove-suffix
 : basename
 : dirname
 : path->function-name
 : path->module-name
 : file-exists?}
