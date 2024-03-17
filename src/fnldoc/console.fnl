;;;; Utilities to print messages to console STDERR.

(local color (require :fnldoc.utils.color))

(local isatty?-cache {})

(fn %isatty? [fd]
  (let [kinds {:exit true :signal true}]
    (case (os.execute (.. "test -t " (tonumber fd)))
      ;; Lua >= 5.2
      (where (?ok kind) (. kinds kind)) (if ?ok true false)
      ;; Lua 5.1 / LuaJIT
      status (= 0 status))))

(lambda isatty? [fd]
  "Check if the file descriptor `fd` is a TTY.

`fd` should be a number of file descriptor; `1` for STDOUT and `2` for
STDERR. Internally, it runs `test -t $fd`. Results of this query is
cached."
  (case (. isatty?-cache fd)
    cached cached
    _ (let [tty? (%isatty? fd)]
        (tset isatty?-cache fd tty?)
        tty?)))

(local levels {:info :INFO
               :warning :WARNING
               :warn :WARNING
               :error :ERROR})

(fn prefix [level]
  (if level
      (.. "fnldoc [" level "]: ")
      "fnldoc: "))

(fn log* [{: level : out : color?} ...]
  "Print `...` to STDERR (default) in specified `level`.

`level` can be one of `:info`, `:warning` (or `:warn`), and `:error`;
other than those will be ignored. If file handle `out` is specified, print
it to the `out` instead. If `color?` is truthy, use color to print messages;
if `false`, use no color; and if `nil`, it infers whether to use color.

# Examples

```fennel
(let [log+ (fn [{: level} msg]
             (with-open [out (io.tmpfile)]
               (log* {: level : out :color? false} msg)
               (out:seek :set)
               (out:read :*a)))] 
  (assert (= \"fnldoc: no level\n\"
             (log+ {} \"no level\")))
  (assert (= \"fnldoc [INFO]: info\n\"
             (log+ {:level :info} \"info\")))
  (assert (= \"fnldoc [WARNING]: warn\n\"
             (log+ {:level :warn} \"warn\")))
  (assert (= \"fnldoc [WARNING]: warning\n\"
             (log+ {:level :warning} \"warning\")))
  (assert (= \"fnldoc [ERROR]: error\n\"
             (log+ {:level :error} \"error\"))))
```"
  (let [out (or out io.stderr)
        color? (case color?
                 true true
                 false false
                 _ (if (= io.stdout out) (isatty? 1)
                       (= io.stderr out) (isatty? 2)
                       false))
        level (if color?
                  (case (. levels level)
                    :INFO (color.green :INFO) 
                    :WARNING (color.yellow :WARNING)
                    :ERROR (color.red :ERROR)
                    _ nil)
                  (. levels level))]
    (out:write (prefix level) ...)
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

{: isatty? : log* : log : info : warn :error error*}
