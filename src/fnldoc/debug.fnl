;; fennel-ls: macro-file

;;;; Utilities convenient for testing/debugging purpose.

;;;; These macros switch behavior depending on global `_G._FNLDOC_DEBUG`.
;;;; If the global is truthy at compile time, they raise error.
;;;; Otherwise, they do some IO stuff.

(local unpack (or table.unpack _G.unpack))

(fn exit/error [& msgs]
  "Exit with warning `msgs` unless `_G._FNLDOC_DEBUG` is truthy at compile time."
  (if _G._FNLDOC_DEBUG
      `(error (table.concat ,msgs ""))
      `(let [console# (require :fnldoc.console)]
         (console#.error ,(unpack msgs))
         (os.exit -1))))

{: exit/error}
