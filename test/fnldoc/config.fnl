(local t (require :test.faith))
(local fennel (require :fennel))
(local config (require :fnldoc.config))

(fn test-config-change-does-not-mutate-default []
  (let [a (config.new)
        b (config.new)]
    (table.insert a.fennel-path :path)
    (tset a.test-requirements :a :b)
    (table.insert a.ignored-args-patterns "%%%%")
    (tset a.modules-info :a :b)
    (t.= [] b.fennel-path)
    (t.= {} b.test-requirements)
    (t.= ["%.%.%." "%_" "%_[^%s]+"] b.ignored-args-patterns)
    (t.= {} b.modules-info)))

(fn test-config-merge! []
  (let [c (config.new)]
    (c:merge! {:a :b})
    (t.= :b (. c :a))))

(fn test-config-set-fennel-path! []
  (let [backup fennel.path
        c (config.new)]
    (set c.fennel-path [:a/?.fnl :b/?/init.fnl])
    (c:set-fennel-path!)
    (t.match "^b/%?/init.fnl;a/%?.fnl;" (. (require :fennel) :path))
    (set fennel.path backup)))

(fn test-config-write! []
  (let [config-file :test/playground/test-config-file
        c (config.new)]
    (each [k _ (pairs c)] (tset c k nil))
    (tset c :fnldoc-version :test)
    (tset c :a :a)
    (c:write! config-file)
    (with-open [in (io.open config-file)]
      (let [out (fennel.dofile config-file)]
        (t.= {:a :a} out)))
    (os.remove config-file)))

(fn test-config-init! []
  (let [c (config.init! {:config-file :test/fixture/.fenneldoc :version :test})]
    (t.= :test c.fnldoc-version)
    (t.= [] c.fennel-path)
    (t.= :nowhere c.out-dir)
    (t.= false c.sandbox?)
    (t.= {:description :a/b} (?. c :modules-info :a/b.fnl))))

{: test-config-change-does-not-mutate-default
 : test-config-merge!
 : test-config-set-fennel-path!
 : test-config-write!
 : test-config-init!}
