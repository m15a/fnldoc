;;;; Utilities to print messages to console.

(local levels {:info :INFO :warning :WARNING :warn :WARNING :error :ERROR})

(fn prefix [level]
  (if level
      (.. "fnldoc [" level "]: ") "fnldoc: "))

(fn log* [{: level : out} ...]
  "Print `...` to STDERR (default) in specified `level`.

`level` can be one of `:info`, `:warning` (or `:warn`), and `:error`;
other than those will be ignored.

If file handle `out` is specified, print it to the `out` instead.

# Examples

```fennel
(let [log+ (fn [{: level} msg]
             (with-open [out (io.tmpfile)]
               (log* {: level : out} msg)
               (out:seek :set)
               (out:read :*a)))] 
  (assert (= \"fnldoc: no level
\"
             (log+ {} \"no level\")))
  (assert (= \"fnldoc [INFO]: info
\"
             (log+ {:level :info} \"info\")))
  (assert (= \"fnldoc [WARNING]: warn
\"
             (log+ {:level :warn} \"warn\")))
  (assert (= \"fnldoc [WARNING]: warning
\"
             (log+ {:level :warning} \"warning\")))
  (assert (= \"fnldoc [ERROR]: error
\"
             (log+ {:level :error} \"error\"))))
```"
  (let [out (or out io.stderr)]
    (out:write (prefix (. levels level)) ...)
    (out:write "\n")))

(fn log [...]
  "Print message, without level specified, to STDERR.

Short hand for `(log* {} ...)`."
  (log* {} ...))

(fn info [...]
  "Print info message to STDERR.

Short hand for `(log* {:level :info} ...)`."
  (log* {:level :info} ...))

(fn warn [...]
  "Print warning message to STDERR.

Short hand for `(log* {:level :warning} ...)`."
  (log* {:level :warning} ...))

(fn error* [...]
  "Print error message to STDERR.

Short hand for `(log* {:level :error} ...)`."
  (log* {:level :error} ...))

{: log* : log : info : warn :error error*}
