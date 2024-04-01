(fn path->module [path]
  (pick-values 1 (-> path
                     (string.gsub "/" ".")
                     (string.gsub "%.fnl$" ""))))

(fn find-test-modules []
  (let [modules []]
    (with-open [in (assert (io.popen "find test -name '*.fnl'"))]
      (each [path (in:lines)]
        (when (and (not= :test/faith.fnl path)
                   (not (path:match :^test/init))
                   (not (path:match :^test/utils))
                   (not (path:match :^test/fixture))
                   (not (path:match :^test/playground)))
          (table.insert modules (path->module path)))))
    modules))

(fn log [...]
  (let [out io.stderr]
    (out:write ...)
    (out:write "\n")))

(fn text [text]
  "Ignore first (spaces and) newline in a long text string."
  (case (type text)
    :string (pick-values 1 (text:gsub "^[ \t]*\n" ""))
    typ (error "string expected, got " typ)))

(fn merge! [testing-exports ...]
  (each [_ tbl (ipairs [...])]
    (each [k v (pairs tbl)]
      (when (. testing-exports k)
        (error "tests or setup/teardown functions of identital name found"))
      (tset testing-exports k v)))
  testing-exports)

{: find-test-modules : log : text : merge!}
