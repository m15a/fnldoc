;;;;File and file path utilities.

(lambda path->function-name [file]
  "Translate the `file` name to its basename in case this file contains a function.

# Examples

```fennel
(assert (= :c (file->function-name \"a/b/c.fnl\")))
```"
  (let [sep (package.config:sub 1 1)]
    (pick-values 1 (-> file
                       (string.gsub (.. ".*" sep) "")
                       (string.gsub "%.fnl$" "")))))

(lambda path->module-name [file]
  "Translate the `file` name to its module name in case this file contains a table.

# Examples

```fennel
(assert (= :a.b.c (file->module-name \"a/b/c.fnl\")))
```"
  (let [sep (package.config:sub 1 1)]
    (pick-values 1 (-> file
                       (string.gsub sep ".")
                       (string.gsub "%.fnl$" "")))))

{: path->function-name 
 : path->module-name}
