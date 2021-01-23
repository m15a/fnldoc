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

(fn run-test [test requirements module-info sandbox?]
  (let [sandbox (create-sandbox
                 {:print (fn [...]
                           (io.stderr:write
                            "\nIn file " file
                            "\nWARNING: IO in test:\n``` fennel\n" test "\n```\n"))
                  :io (setmetatable
                       {}
                       {:__index
                        (fn []
                          (io.stderr:write
                           "\nIn file " file
                           "\nWARNING: 'io' module used in test:\n``` fennel\n" test "\n```\n"))})})
        requirements (or (-?> requirements (.. "\n")) "")]
    (each [fname fval (pairs module-info.f-table)]
      (tset sandbox fname fval))
    (pcall fennel.eval (.. requirements test) {:env (if sandbox? sandbox)})))

(fn run-tests-for-fn [func docstring module-info sandbox?]
  (var error? false)
  (if (not docstring)
      (if (= module-info.type :function-module)
          (io.stderr:write "WARNING: file " func " exports undocumented function\n")
          (io.stderr:write "WARNING: undocumented exported function " func "\n"))
      (each [n test (ipairs (extract-tests docstring))]
        (match (run-test test module-info.requirements module-info sandbox?)
          (false msg) (let [msg (string.gsub (tostring msg) "^%[.-%]:%d+:%s*" "")]
                        (io.stderr:write "In file: " module-info.file "\n"
                                         "Error in docstring for: " func "\n"
                                         "In test:\n``` fennel\n" test "\n```\n"
                                         "Error:\n"
                                         msg "\n\n")
                        (set error? true)))))
  error?)

(fn check-function-arglist [func arglist docstring module-info]
  (let [arglist (table.concat arglist " ")
        docstring (string.gsub docstring "\n?```.-\n```\n?" "")]
    (each [argument (arglist:gmatch "[^][ \n\r()&{}}]+")]
      (let [argument-pat (argument:gsub "([][().%+-*?$^])" "%%%1")]
        (when (not (or (string.find docstring (.. "`" argument-pat "`"))
                       (string.find docstring (.. "`" argument-pat "'"))))
          (if (string.find docstring argument-pat)
              (io.stderr:write "WARNING: in file " module-info.file
                               " argument '" argument "' should appear in backtics in docstring for '"
                               func "'\n")
              (io.stderr:write "WARNING: in file " module-info.file
                               " function '" func "' has undocumented argument '"
                               argument "'\n")))))))

(fn check-function [func docstring arglist module-info sandbox?]
  (check-function-arglist func arglist docstring module-info)
  (run-tests-for-fn func docstring module-info sandbox?))

(fn doctest [module-info sandbox?]
  "Run tests contained in documentations.
Accepts `module-info` with items to check, and `sandbox?` argument."
  (var error? false)
  (match module-info.type
    :function-module
    (let [fname (pick-values 1 (next module-info.f-table))
          docstring (and module-info.documented? module-info.description)
          arglist module-info.arglist]
      (set error? (check-function fname docstring arglist module-info sandbox?)))
    _
    (let [funcs (keys module-info.items)]
      (each [_ func (ipairs funcs)]
        (when-let [{: docstring : arglist} (. module-info.items func)]
          (let [res (check-function func docstring arglist module-info sandbox?)]
            (set error? (or error? res)))))))
  (when error?
    (io.stderr:write "Errors in module " module-info.module "\n")
    (os.exit 1)))
