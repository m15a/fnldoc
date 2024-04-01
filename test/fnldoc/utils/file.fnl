(import-macros {: testing} :test.utils)
(local {: merge!} (require :test.utils))
(local t (require :test.faith))
(local uf (require :fnldoc.utils.file))

(merge!
  (testing :normalize
    (it "removes duplicated /'s" []
      (t.= :a/b/c/ (uf.normalize :a//b///c/)))
    (it "resolves `..`" []
      (t.= :a/d (uf.normalize :a/b/../d))
      (t.= :./ (uf.normalize :./a/../)))
    (it "keeps trailing /'s" []
      (t.= :.. (uf.normalize :..))
      (t.= :./ (uf.normalize :./)))
    (it "resolves `./.`" []
      (t.= :. (uf.normalize :./.))))

  (testing :remove-suffix
    (it "removes suffix" []
      (t.= :/a/b (uf.remove-suffix :/a/b.ext :.ext)))
    (it "keeps suffix if it is just the file name" []
      (t.= :.hidden (uf.remove-suffix :.hidden :.hidden))))

  (testing :basename
    (it "extracts basename" []
      (t.= :b (uf.basename :/a/b))
      (t.= :b (uf.basename :a/b/))
      (t.= :. (uf.basename :.))
      (t.= :.. (uf.basename :..)))
    (it "strips suffix if specified" []
      (t.= :b (uf.basename :/a/b.ext :.ext))
      (t.= :b (uf.basename :/a/b.ext/ :.ext)))
    (it "keeps suffix if it is just the file name" []
      (t.= :.ext (uf.basename :/a/b/.ext :.ext)))
    (it "leaves slash as is" []
      (t.= :/ (uf.basename :/))))

  (testing :dirname
    (it "extracts dirname from absolute path" []
      (t.= :/a (uf.dirname :/a/b))
      (t.= :/a (uf.dirname :/a/b/)))
    (it "extracts dirname from relative path" []
      (t.= :a (uf.dirname :a/b))
      (t.= :a (uf.dirname :a/b/))
      (t.= :. (uf.dirname :a))
      (t.= :. (uf.dirname :a/)))
    (it "returns `.` for `.` and `..`" []
      (t.= :. (uf.dirname :.))   ; NOTE: . = ./.
      (t.= :. (uf.dirname :..))) ; NOTE: .. = ./..
    (it "leaves slash as is" []
      (t.= :/ (uf.dirname :/))))

  (testing :path->function-name
    (it "translates to function name" []
      (t.= :c (uf.path->function-name :a/b/c.fnl))))

  (testing :path->module-name
    (it "translates to module name" []
      (t.= :a.b.c (uf.path->module-name :a/b/c.fnl))
      (t.= :a.b.c (uf.path->module-name :./a/b/c.fnl)))
    (it "resolves path beforehand" []
      (t.= :a.c (uf.path->module-name :./a/b/.././c.fnl)))
    (it "resolves parent directory" []
      (t.= :...a.b.c (uf.path->module-name :../a/b/c.fnl))))

  (testing :join-paths
    (it "keeps trailing `/`" []
      (t.= :a/b/ (uf.join-paths :a :b/)))
    (it "resolves path beforehand" []
      (t.= :a/b/ (uf.join-paths :a :. :b/))
      (t.= :a/b (uf.join-paths :a :b/ :c :.. :.))))

  (testing :remove-prefix-path
    (it "removes prefix path" []
      (t.= :b/c (uf.remove-prefix-path :a :a/b/c))
      (t.= :b (uf.remove-prefix-path :a :./a/b)))
    (it "keeps trailing `/`" []
      (t.= :./ (uf.remove-prefix-path :b :b/)))
    (it "resolves path beforehand" []
      (t.= :a/b (uf.remove-prefix-path :./a/../b/ :a/b))
      (t.= :b/ (uf.remove-prefix-path :a/b/../c :a/c/b/)))
    (it "does not remove deeper prefix" []
      (t.= :a/b (uf.remove-prefix-path :a/b/c :a/b))))

  (testing :file-exists?
    (it "finds existing file" []
      (t.= true (uf.file-exists? :test/init.fnl)))
    (it "finds non-existing file" []
      (t.= false (uf.file-exists? :test/ghost.fnl))))

  (testing :make-directory
    (local test-dir :test/playground/test-mkdir)
    (local deep-dir (.. test-dir :/d/e/e/p))
    (it "creates directory" []
      (let [(ok? typ status) (uf.make-directory test-dir)]
        (t.= true ok?)
        (t.= :exit typ)
        (t.= 0 status)))
    (it "creates deep directory" []
      (let [(ok? typ status)
            (uf.make-directory deep-dir :parent)]
        (t.= true ok?)
        (t.= :exit typ)
        (t.= 0 status)))
    (fn teardown []
      (os.execute (.. "rm -rf " test-dir)))))

;; vim: lw+=testing,test,it spell
