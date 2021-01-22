(local fennel (require :fennel))
(local {: keys} (require :cljlib))
(local {: create-sandbox} (require :parser))
(import-macros {: when-let} :cljlib.macros)

(fn extract-tests [fn-doc]
  (icollect [test (fn-doc:gmatch "\n?```%s*fennel.-\n```")]
    (-> test
        (string.gsub "\n?```%s*fennel" "")
        (string.gsub "\n```" "")
        (string.gsub "^\n" ""))))

(table.insert (or package.loaders package.searchers) fennel.searcher)

(fn wrap-fn [orig-fn msg]
  (fn [...]
    (io.stderr:write msg)
    (orig-fn ...)))

(fn run-test [test requirements file]
  (let [sandbox (create-sandbox {:print (fn [...]
                                          (io.stderr:write "\nIn file " file
                                                           "\nWARNING: IO in test:\n``` fennel\n" test "\n```\n"))
                                 :io (setmetatable {} {:__index (fn [] (io.stderr:write "\nIn file " file
                                                                                        "\nWARNING: 'io' module used in test:\n``` fennel\n" test "\n```\n"))})})
        requirements (or (-?> requirements (.. "\n")) "")]
    (pcall fennel.eval (.. requirements test) {:env sandbox})))

(fn run-tests-for-fn [func docstring module-info]
  (var error? false)
  (if (not docstring)
      (if (= module-info.type :function-module)
          (io.stderr:write "WARNING: file " func " exports undocumented function\n")
          (io.stderr:write "WARNING: undocumented exported function " func "\n"))
      (each [n test (ipairs (extract-tests docstring))]
        (match (run-test test module-info.requirements module-info.file)
          (false msg) (do (io.stderr:write "\nIn file: " module-info.file "\n"
                                           "Error in docstring for " func "\n"
                                           "In test:\n``` fennel\n" test "\n```\n"
                                           "Error:\n")
                          (io.stderr:write (tostring msg) "\n")
                          (set error? true)))))
  error?)

(fn test-module [module-info]
  "Run tests contained in module documentations."
  (var error? false)
  (match module-info.type
    :function-module
    (set error? (run-tests-for-fn
                 module-info.module
                 (and module-info.documented? module-info.description)
                 module-info))
    _
    (let [funcs (keys module-info.items)]
      (each [_ func (ipairs funcs)]
        (when-let [{: docstring} (. module-info.items func)]
          (let [res (run-tests-for-fn func docstring module-info)]
            (set error? (or error? res)))))))
  (when error?
    (io.stderr:write "Errors in module " module-info.module "\n")
    (os.exit 1)))
