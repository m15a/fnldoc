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

{: find-test-modules : log}
