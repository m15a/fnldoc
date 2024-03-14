(local t (require :test.faith))
(local {: join-paths} (require :fnldoc.utils.file))
(local {: write!} (require :fnldoc.writer))

(local test-dir (join-paths :test :playground :test-writer))
(local invalid-dir (join-paths test-dir :invalid))
(local invalid-file (join-paths test-dir :invalid.md))

(fn setup-all []
  (os.execute (.. "mkdir -p " invalid-dir " && chmod -wx " invalid-dir))
  (os.execute (.. "touch " invalid-file " && chmod -w " invalid-file)))

(fn test-write! []
  (let [text "hello"
        path (join-paths test-dir :a :b.md)]
    (t.= true (write! text path :debug))
    (t.= "hello" (with-open [in (io.open path)]
                   (in:read :a*))))
  (let [text ""]
    (t.error "error opening file 'test"
             #(write! text (join-paths invalid-dir :a.md) :debug))
    (t.error "error opening file 'test"
             #(write! text invalid-file :debug))))

(fn teardown-all []
  (os.execute (.. "rm -rf " test-dir)))

{: setup-all : teardown-all : test-write!}
