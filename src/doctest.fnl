(local fennel (require :fennel))

(fn has-tests? [fn-doc]
  (string.find fn-doc "```%s*fennel"))

(fn extract-tests [fn-doc]
  (icollect [test (fn-doc:gmatch "\n?```%s*fennel.-\n```")]
    (-> test
        (string.gsub "\n?```%s*fennel" "")
        (string.gsub "\n```" "")
        (string.gsub "^\n" ""))))

(fn run-test [test]
  (pcall (fennel.load-code (fennel.compile-string test))))

(fn run-tests-for-fn [function]
  (each [test (extract-tests function)]
    (match (run-test test)
      (false msg) (do (io.stderr:write (.. "error in doc for" "fn name" ":\n"))
                      (io.stderr:write (.. msg "\n"))))))
