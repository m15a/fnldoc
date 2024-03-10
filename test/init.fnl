(local faith (require :test.faith))

(fn path->module [path]
  (pick-values 1 (-> path
                     (string.gsub "/" ".")
                     (string.gsub "%.fnl$" ""))))

(fn find-test-modules []
  (let [modules []]
    (with-open [in (assert (io.popen "find test -name '*.fnl'"))]
      (each [path (in:lines)]
        (when (and (not= :test/init.fnl path) (not= :test/faith.fnl path)
                   (not (string.match path :^test/playground)))
          (table.insert modules (path->module path)))))
    modules))

(io.stderr:write "Faith " faith.version)
(faith.run (find-test-modules))
