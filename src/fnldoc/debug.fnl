;;;; Utilities convenient for testing/debugging purpose.

(local console (require :fnldoc.console))

(fn exit/error [msg ?debug]
  "If `?debug` is truthy, raise an error with `msg`; otherwise exit with warning."
  (if ?debug
      (error msg)
      (do
        (console.error msg)
        (os.exit -1))))

{: exit/error}
