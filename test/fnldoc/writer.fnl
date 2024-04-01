(import-macros {: testing} :test.utils)
(local t (require :test.faith))
(local {: join-paths} (require :fnldoc.utils.file))
(local {: write!} (require :fnldoc.writer))

(local test-dir (join-paths :test :playground :test-writer))
(local invalid-dir (join-paths test-dir :invalid))
(local invalid-file (join-paths test-dir :invalid.md))

(testing :writer
  (fn setup-all []
    (os.execute (.. "mkdir -p " invalid-dir " && chmod -wx " invalid-dir))
    (os.execute (.. "touch " invalid-file " && chmod -w " invalid-file)))

  (it "writes text to a file" []
    (let [text "hello"
          path (join-paths test-dir :a :b.md)]
      (t.= true (write! text path))
      (t.= "hello" (with-open [in (io.open path)]
                     (in:read :a*)))))

  (it "raises error when to write to invalid path" []
    (t.error "error opening file 'test"
             #(write! "" (join-paths invalid-dir :a.md)))
    (t.error "error opening file 'test"
             #(write! "" invalid-file)))

  (fn teardown-all []
    (os.execute (.. "rm -rf " test-dir))))
