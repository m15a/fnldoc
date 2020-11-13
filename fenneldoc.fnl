(local file (. arg 1))
(local module (-> file
                  (string.gsub "/" ".")
                  (string.gsub ".fnl$" "")))
(local heading (-> file
                   (string.gsub ".*/" "")
                   (string.upper )))
(print (.. "# " (string.gsub )))

(each [k v (pairs clj)]
  (print (.. "##" k))
  (print (fennel.metadata:get v :fnl/docstring))
  (print))
