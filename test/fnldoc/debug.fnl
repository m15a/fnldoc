(local t (require :test.faith))
(import-macros {: exit/error } :fnldoc.debug)

(fn test-exit/error []
  (t.error "it should raise an error"
           #(exit/error "it should raise an error when testing.")))

{: test-exit/error}
