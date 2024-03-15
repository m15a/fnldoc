(local t (require :test.faith))
(local uf (require :fnldoc.utils.file))

(fn test-basename []
  (t.= :test (uf.basename :test :.fnl)))

(fn test-remove-prefix-path []
  (t.= :b/c (uf.remove-prefix-path :a :a/b/c))
  (t.= :b/ (uf.remove-prefix-path :a :./a/b/))
  (t.= :b/ (uf.remove-prefix-path :./a :a/b/))
  (t.= :b/ (uf.remove-prefix-path :./a/b/../ :a/b/))
  (t.= :. (uf.remove-prefix-path :./a/b/ :a/b))
  (t.= :./ (uf.remove-prefix-path :./a/b :a/b/))
  (t.= :a/b/ (uf.remove-prefix-path :./a/b/c :a/b/))
  (t.= :a/b (uf.remove-prefix-path :./a/b/c :a/b)))

{: test-basename
 : test-remove-prefix-path}
