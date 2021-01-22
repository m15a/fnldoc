(local fennel (require :fennel))
(local {: keys} (require :cljlib))
(import-macros {: when-let} :cljlib.macros)

(fn extract-tests [fn-doc]
  (icollect [test (fn-doc:gmatch "\n?```%s*fennel.-\n```")]
    (-> test
        (string.gsub "\n?```%s*fennel" "")
        (string.gsub "\n```" "")
        (string.gsub "^\n" ""))))

(fn run-test [test requirements]
  (let [env {: require
             : assert
             : string
             : table
             : print
             : type
             : getmetatable
             : setmetatable
             : pairs
             : ipairs
             : utf8
             : io
             : error
             : next
             : pcall
             : xpcall
             : select
             : tostring}
        requirements (or (-?> requirements (.. "\n")) "")]
    (set env._G env)
    (table.insert (or package.loaders
                      package.searchers)
                  fennel.searcher)
    (pcall fennel.eval (.. requirements test) {:env env})))

(fn run-tests-for-fn [func docstring module-info]
  (var error? false)
  (each [n test (ipairs (extract-tests docstring))]
    (match (run-test test module-info.requirements)
      (false msg) (do (io.stderr:write (.. "In file: " module-info.file "\n"
                                           "Error in docstring for " func "\n"
                                           "In test:\n``` fennel\n" test "\n```\n"
                                           "Error:\n"))
                      (io.stderr:write (.. (tostring msg) "\n"))
                      (set error? true))))
  error?)

(fn test-module [module-info]
  (var error? false)
  (match module-info.type
    :function-module
    (set error? (run-tests-for-fn
                 module-info.module
                 module-info.description
                 module-info))
    _
    (let [funcs (keys module-info.items)]
      (each [_ func (ipairs funcs)]
        (when-let [{: docstring} (. module-info.items func)]
          (let [res (run-tests-for-fn func docstring module-info)]
            (set error? (or error? res)))))))
  (when error?
    (io.stderr:write (.. "Errors in module " module-info.module "\n"))
    (os.exit 1)))
