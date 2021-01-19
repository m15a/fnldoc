(local fennel (require :fennel))
(local {: keys} (require :cljlib))
(import-macros {: when-let} :cljlib.macros)

(fn has-tests? [fn-doc]
  (string.find fn-doc "```%s*fennel"))

(fn extract-tests [fn-doc]
  (icollect [test (fn-doc:gmatch "\n?```%s*fennel.-\n```")]
    (-> test
        (string.gsub "\n?```%s*fennel" "")
        (string.gsub "\n```" "")
        (string.gsub "^\n" ""))))

(fn run-test [test]
  (pcall #(fennel.eval test)))

(fn run-tests-for-fn [func docstring]
  (var error? false)
  (each [n test (ipairs (extract-tests docstring))]
    (match (run-test test)
      (false msg) (do (io.stderr:write (.. "error in doc for " func ":\n"))
                      (io.stderr:write (.. (fennel.view msg) "\n"))
                      (set error? true))))
  error?)

(fn test-module [module-info]
  (var error? false)
  (each [name func (pairs module-info.f-table)]
    (tset _G (fennel.mangle name) func))
  (match module-info.type
    :function-module
    (set error? (run-tests-for-fn
                 module-info.module
                 module-info.description))
    :module
    (let [funcs (keys module-info.items)]
      (each [_ func (ipairs funcs)]
        (when-let [{: docstring} (. module-info.items func)]
          (let [res (run-tests-for-fn func docstring)]
            (set error? (or error? res)))))))
  (when error?
    (io.stderr:write (.. "Errors in module " module-info.module "\n"))
    (os.exit 1)))
