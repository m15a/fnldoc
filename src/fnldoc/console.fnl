;;;; Utilities to print messages to console.

(local levels {:info :INFO :warning :WARNING :warn :WARNING :error :ERROR})

(fn wrap [message level]
  (if level
      (.. "fnldoc [" level "]: " message)
      (.. "fnldoc: " message)))

(lambda log [message ?level ?out]
  "Print `message` to STDERR (default) in specified `?level`.

`?level` can be one of `:info`, `:warning` (or `:warn`), and `:error`;
other than those will be ignored.

If file handle `?out` is specified, print it to the `?out` instead.

# Examples

```fennel
(let [log* (fn [msg lvl]
             (with-open [out (io.tmpfile)]
               (log msg lvl out)
               (out:seek :set)
               (out:read :*a)))] 
  (assert (= \"fnldoc: no level
\"
             (log* \"no level\")))
  (assert (= \"fnldoc: also no level
\"
             (log* \"also no level\" false)))
  (assert (= \"fnldoc [INFO]: info
\"
             (log* \"info\" :info)))
  (assert (= \"fnldoc [WARNING]: warn
\"
             (log* \"warn\" :warn)))
  (assert (= \"fnldoc [WARNING]: warning
\"
             (log* \"warning\" :warning)))
  (assert (= \"fnldoc [ERROR]: error
\"
             (log* \"error\" :error))))
```"
  (let [out (or ?out io.stderr)]
    (out:write (wrap message (. levels ?level)) "\n")))

(lambda info [message]
  "Print info `message` to STDERR.

Short hand for `(log message :info)`."
  (log message :info))

(lambda warn [message]
  "Print warning `message` to STDERR.

Short hand for `(log message :warning)`."
  (log message :warning))

(lambda error* [message]
  "Print error `message` to STDERR.

Short hand for `(log message :error)`."
  (log message :error))

{: log : info : warn :error error*}
