(import-macros {: testing : test} :test.utils)
(local t (require :test.faith))
(local fennel (require :fennel))
(local config (require :fnldoc.config))

(testing :config
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

  (it "validates shallow option values before setting" []
    (let [c (config.new)]
      (t.error "invalid option 'sandbox%?': 1"
               #(c:set! :sandbox? 1))
      (t.error "invalid option 'order': \"alphalpha\""
               #(c:set! :order :alphalpha))
      (t.error "invalid option 'order': %[1%]"
               #(c:set! :order [1]))
      (t.error "invalid option 'out%-dir': %[1 2%]"
               #(c:set! :out-dir [1 2]))
      (t.error "invalid option 'project%-copyright': true"
               #(c:set! :project-copyright true))))

  (it "validates 'fennel-path' before setting" []
    (let [c (config.new)]
      (t.error "invalid option 'fennel%-path': 1"
               #(c:set! :fennel-path 1))
      (t.error "invalid option 'fennel%-path': %[2%]"
               #(c:set! :fennel-path [2]))))

  (it "validates 'test-requirements' before setting" []
    (let [c (config.new)]
      (t.error "invalid option 'test%-requirements': 1"
               #(c:set! :test-requirements 1))
      (t.error "invalid option 'test%-requirements': {:path {}}"
               #(c:set! :test-requirements {:path []}))))

  (it "validates 'ignored-args-patterns' before setting" []
    (let [c (config.new)]
      (t.error "invalid option 'ignored%-args%-patterns': 1"
               #(c:set! :ignored-args-patterns 1))
      (t.error "invalid option 'ignored%-args%-patterns': %[2%]"
               #(c:set! :ignored-args-patterns [2]))))

  (it "validates 'modules-info' before setting" []
    (let [c (config.new)]
      (t.error "invalid option 'modules%-info': 1"
               #(c:set! :modules-info 1))
      (t.error "invalid option 'modules%-info': %[2%]"
               #(c:set! :modules-info [2]))
      (t.error "invalid option 'modules%-info': {:path \"a\"}"
               #(c:set! :modules-info {:path :a}))
      (t.error "invalid option 'modules%-info': {:path {:order %[1 2%]}"
               #(c:set! :modules-info {:path {:order [1 2]}}))))

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
              {:config-file "test/fixture/fenneldoc" :version :test})]
      (t.= :test c.fnldoc-version)
      (t.= [] c.fennel-path)
      (t.= :nowhere c.out-dir)
      (t.= false c.sandbox?)
      (t.= {:description :a/b} (?. c :modules-info :a/b.fnl))))

  (it "is loaded in sandboxed environment" []
    (t.error "access to denied IO detected"
             #(config.init! {:config-file "test/fixture/unsafe-fenneldoc"
                             :version :test}))))

;; vim: lw+=testing,test,it spell
