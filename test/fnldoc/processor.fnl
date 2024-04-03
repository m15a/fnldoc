(import-macros {: testing} :test.utils)
(local t (require :test.faith))
(local {: destination-path} (require :fnldoc.processor))

(testing :destination-path
  (it "strips src dir from destination path" []
    (let [modinfo {:file "lib/path/to/mod.fnl"}
          config {:out-dir "_out"
                  :src-dir "lib"}]
      (t.= "_out/path/to/mod.md"
           (destination-path modinfo config))))

  (it "can be renamed" []
    (let [modinfo {:name "some module"
                   :file "path/to/mod.fnl"}
          config {:out-dir "_out"
                  :src-dir "src"}]
      (t.= "_out/path/to/some module.md"
           (destination-path modinfo config)))))

;; vim: lw+=testing,test,it spell
