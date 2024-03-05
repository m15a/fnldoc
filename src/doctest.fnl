(import-macros
 {: when-let : defn : defn- : ns}
 (doto :lib.cljlib require))

(ns doctest
  "Documentation testing facilities."
  (:require
   [lib.cljlib :refer [hash-set conj]]
   [parser :refer [create-sandbox]]
   [fennel]))

(defn- extract-tests [name fn-doc]
  (icollect [test (fn-doc:gmatch "\n?```%s*fennel.-\n```")]
    (if (not (string.match test "\n?%s*```%s*fennel[ \t]+:skip%-test"))
        (-> test
            (string.gsub "\n?%s*```%s*fennel" "")
            (string.gsub "\n%s*```" "")
            (string.gsub "^\n" ""))
        (do (io.stderr:write "skipping test in '" (tostring name) "'\n")
            nil))))

(defn- copy-table [t]
  (collect [k v (pairs t)]
    (values k v)))

(table.insert (or package.loaders package.searchers) fennel.searcher)

(defn- run-test [test requirements module-info sandbox?]
  (let [env (if sandbox?
                (create-sandbox module-info.file
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
                (copy-table _G))
        requirements (or (-?> requirements (.. "\n")) "")]
    (each [fname fval (pairs module-info.f-table)]
      (tset env fname fval))
    (pcall fennel.eval (.. requirements test) {:env env})))

(defn- run-tests-for-fn [func docstring module-info sandbox?]
  (var error? false)
  (each [n test (ipairs (extract-tests func docstring))]
    (match (run-test test module-info.requirements module-info sandbox?)
      (false msg) (let [msg (string.gsub (tostring msg) "^%[.-%]:%d+:%s*" "")]
                    (io.stderr:write "In file: '" module-info.file "'\n"
                                     "Error in docstring for: '" func "'\n"
                                     "In test:\n``` fennel\n" test "\n```\n"
                                     "Error:\n"
                                     msg "\n\n")
                    (set error? true))))
  error?)

(defn- check-argument [func argument docstring file seen]
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
  (if (next (icollect [_ pattern (ipairs patterns)]
              (when (string.find (argument:gsub "^%s*(.-)%s*$" "%1")
                                 (.. "^%f[%w_]" pattern "%f[^%w_]$"))
                pattern)))
      true
      false))

(defn- remove-code-blocks [docstring]
  (pick-values 1 (string.gsub docstring "\n?```.-\n```\n?" "")))

(defn- normalize-name
  "Remove symbols that can't be used in names, and strip strings."
  [name]
  (-> name
      (: :gsub "[\n\r()&]+" "") ; strip symbols that can't be used in names
      (: :gsub "\"[^\"]-\"" "")))

(defn- extract-destructured-args [argument]
  (if (argument:find "[][{}]")
      (icollect [arg (argument:gmatch "[^][ \n\r{}}]+")]
        (when (not (string.match arg "^:")) arg))
      [argument]))

(defn- check-function-arglist [func arglist docstring {: file} seen patterns]
  (let [docstring (remove-code-blocks docstring)]
    (accumulate [seen seen _ argument (ipairs arglist)]
      (let [argument (normalize-name argument)
            filtered (icollect [_ arg (ipairs (extract-destructured-args argument))]
                       (when (not (skip-arg-check? arg patterns)) arg))]
        (accumulate [seen seen _ argument (ipairs filtered)]
          (do
            (check-argument func argument docstring file seen)
            (conj seen argument)))))))

(defn- check-function [func docstring arglist module-info config]
  (if (or (not docstring) (= docstring ""))
      (do (if (= module-info.type :function-module)
              (io.stderr:write "WARNING: file '" module-info.file "' exports undocumented value\n")
              (io.stderr:write "WARNING: in file '" module-info.file "' undocumented exported value '" func "'\n"))
          nil) ; io.stderr:write returns non-nil value, which is treated as mark that errors occured
      arglist
      (do (check-function-arglist func arglist docstring module-info (hash-set) config.ignored-args-patterns)
          (run-tests-for-fn func docstring module-info config.sandbox))))

(defn test
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
    (let [funcs (icollect [k _ (pairs module-info.items)] k)]
      (each [_ func (ipairs funcs)]
        (when-let [{: docstring : arglist} (. module-info.items func)]
          (let [res (check-function func docstring arglist module-info config)]
            (set error? (or error? res)))))))
  (when error?
    (io.stderr:write "Errors in module " module-info.module "\n")
    (os.exit 1)))

doctest

;; LocalWords:  docstring backtics
