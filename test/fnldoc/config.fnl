(import-macros {: testing : test : it} :test.utils)
(local t (require :test.faith))
(local fennel (require :fennel))
(local config (require :fnldoc.config))

(testing
  (it "does not mutate default" []
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

  (test :config-merge! []
    (let [c (config.new)]
      (c:merge! {:a :b})
      (t.= :b (. c :a))))

  (test :config-set-fennel-path! []
    (let [backup fennel.path
          c (config.new)]
      (set c.fennel-path [:a/?.fnl :b/?/init.fnl])
      (c:set-fennel-path!)
      (t.match "^b/%?/init.fnl;a/%?.fnl;" fennel.path)
      (set fennel.path backup)))

  (test :config-write! []
    (let [config-file "test/playground/test-config-file"
          c (config.new)]
      (each [k _ (pairs c)]
        (tset c k nil))
      (tset c :fnldoc-version :test)
      (tset c :a :a)
      (c:write! config-file)
      (t.= {:a :a}
           (fennel.dofile config-file))
      (os.remove config-file)))

  (test :config-init! []
    (let [c (config.init!
              {:config-file "test/fixture/.fenneldoc" :version :test})]
      (t.= :test c.fnldoc-version)
      (t.= [] c.fennel-path)
      (t.= :nowhere c.out-dir)
      (t.= false c.sandbox?)
      (t.= {:description :a/b} (?. c :modules-info :a/b.fnl)))))

;; vim: lw+=testing,test,it spell
