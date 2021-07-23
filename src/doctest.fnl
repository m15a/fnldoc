(local fennel (require :fennel))
(local {: keys : hash-set : conj : empty?} (require :cljlib))
(local {: create-sandbox} (require :parser))
(import-macros {: when-let : defn} :cljlib)

(defn extract-tests [fn-doc]
  (icollect [test (fn-doc:gmatch "\n?```%s*fennel.-\n```")]
    (-> test
        (string.gsub "\n?%s*```%s*fennel" "")
        (string.gsub "\n%s*```" "")
        (string.gsub "^\n" ""))))

(table.insert (or package.loaders package.searchers) fennel.searcher)

  (let [sandbox (create-sandbox
                 {:print (fn [...]
                           (io.stderr:write
                            "WARNING: IO detected in the '"
                            (or module-info.file "unknown")
                            "' file in the following test:\n``` fennel\n" test "\n```\n"))
                  :io (setmetatable
                       {}
                       {:__index
                        (fn []
                          (io.stderr:write
                           "WARNING: 'io' module access detected in the '"
                           (or module-info.file "unknown")
                           "' file in the following test:\n``` fennel\n" test "\n```\n"))})})
(defn run-test [test requirements module-info sandbox?]
        requirements (or (-?> requirements (.. "\n")) "")]
    (each [fname fval (pairs module-info.f-table)]
      (tset sandbox fname fval))
    (pcall fennel.eval (.. requirements test) {:env (if sandbox? sandbox)})))

(defn run-tests-for-fn [func docstring module-info sandbox?]
  (var error? false)
  (each [n test (ipairs (extract-tests docstring))]
    (match (run-test test module-info.requirements module-info sandbox?)
      (false msg) (let [msg (string.gsub (tostring msg) "^%[.-%]:%d+:%s*" "")]
                    (io.stderr:write "In file: '" module-info.file "'\n"
                                     "Error in docstring for: " func "\n"
                                     "In test:\n``` fennel\n" test "\n```\n"
                                     "Error:\n"
                                     msg "\n\n")
                    (set error? true))))
  error?)

(defn check-argument [func argument docstring file seen]
  (when (not= argument "")
    (let [argument-pat (.. ":?" (argument:gsub "([][().%+-*?$^])" "%%%1"))]
      (when (not (or (string.find docstring (.. "`" argument-pat "`"))
                     (string.find docstring (.. "`" argument-pat "'"))))
        (when (not (seen argument))
          (if (and (string.find docstring (.. "%f[%w_]" argument-pat "%f[^%w_]"))) ;; %f[%w_] emulates \b
              (io.stderr:write "WARNING: in file '" file
                               "' argument '" argument "' should appear in backtics in docstring for '"
                               func "'\n")
              (if (not= argument "...")
                  (io.stderr:write "WARNING: in file '" file
                                   "' function '" func "' has undocumented argument '"
                                   argument "'\n"))))))))

(fn skip-arg-check? [argument patterns]
  (-> (icollect [_ pattern (ipairs patterns)]
        (string.find (argument:gsub "^%s*(.-)%s*$" "%1") (.. "^%f[%w_]" pattern "%f[^%w_]$")))
      empty?
      not))

(defn check-function-arglist [func arglist docstring {: file} seen patterns]
  (let [docstring (string.gsub docstring "\n?```.-\n```\n?" "")]
    (each [_ argument (ipairs arglist)]
      (let [argument (-> argument
                         (: :gsub "[\n\r()&]+" "") ;; strip symbols that can't be used in variable name
                         (: :gsub "\"[^\"]-\"" ""))] ;; strip strings
        (if (argument:find "[][{}]")
            (each [argument (argument:gmatch "[^][ \n\r{}}]+")]
              (when (not (string.find argument "^:"))
                (when (not (skip-arg-check? argument patterns))
                  (check-argument func argument docstring file seen))
                (conj seen argument)))
            (when (not (skip-arg-check? argument patterns))
              (check-argument func argument docstring file seen)))
        (conj seen argument)))))

(defn check-function [func docstring arglist module-info config]
  (if (or (not docstring) (= docstring ""))
      (do (if (= module-info.type :function-module)
              (io.stderr:write "WARNING: file '" module-info.file "' exports undocumented value\n")
              (io.stderr:write "WARNING: in file '" module-info.file "' undocumented exported value '" func "'\n"))
          nil) ; io.stderr:write returns non-nil value, which is treated as mark that errors occured
      arglist
      (do (check-function-arglist func arglist docstring module-info (hash-set) config.ignored-args-patterns)
          (run-tests-for-fn func docstring module-info config.sandbox))))

(defn doctest
  "Run tests contained in documentations.
Accepts `module-info` with items to check, and `config` argument."
  [module-info config]
  (var error? false)
  (match module-info.type
    :function-module
    (let [fname (pick-values 1 (next module-info.f-table))
          docstring (and module-info.documented? module-info.description)
          arglist module-info.arglist]
      (set error? (check-function fname docstring arglist module-info config)))
    _
    (let [funcs (keys module-info.items)]
      (each [_ func (ipairs funcs)]
        (when-let [{: docstring : arglist} (. module-info.items func)]
          (let [res (check-function func docstring arglist module-info config)]
            (set error? (or error? res)))))))
  (when error?
    (io.stderr:write "Errors in module " module-info.module "\n")
    (os.exit 1)))

doctest

; LocalWords:  docstring backtics
