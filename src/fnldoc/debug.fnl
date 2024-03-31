;; fennel-ls: macro-file

;;;; Utilities convenient for testing/debugging purpose.

;;;; These macros switch behavior depending on global `_G._FNLDOC_DEBUG`.
;;;; If the global is truthy at compile time, they raise error.
;;;; Otherwise, they do some IO stuff.

(fn exit/error [msg]
  "Exit with warning `msg` unless `_G._FNLDOC_DEBUG` is truthy at compile time."
  (if _G._FNLDOC_DEBUG
      `(error ,msg)
      `(let [console# (require :fnldoc.console)]
         (console#.error ,msg)
         (os.exit -1))))

{: exit/error}
