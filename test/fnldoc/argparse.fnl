(import-macros {: testing} :test.utils)
(local t (require :test.faith))
(local {: parse} (require :fnldoc.argparse))

(testing :argparse
  (it "parses arguments without mutating them" []
    (let [args [:arg1 :--no-toc :--out-dir :here "--" :arg2 :--help]
          result (parse args)]
      (t.= [:arg1 :--no-toc :--out-dir :here "--" :arg2 :--help]
           args)
      (t.= {:config {:out-dir :here :toc? false} :files [:arg1 :arg2 :--help]}
           result)))

  (it "parses boolean flag" []
    (t.= {:config {:function-signatures? true :sandbox? true} :files []}
         (parse [:--function-signatures :--sandbox])))

  (it "parses negative boolean flag" []
    (t.= {:config {:license? false :copyright? false} :files []}
         (parse [:--no-license :--no-copyright])))

  (it "parses category input" []
    (t.= {:config {:mode :check :order :reverse-alphabetic} :files []}
         (parse [:--mode :check :--order :reverse-alphabetic])))

  (it "detects invalid category input" []
    (t.error "invalid argument for option %-%-inline%-references: \"cod\""
             #(parse [:--inline-references :cod])))

  (it "parses string input" []
    (t.= {:config {:project-copyright :COPYRIGHT :project-license :MIT}
          :files []}
         (parse [:--project-copyright :COPYRIGHT :--project-license :MIT])))

  (it "skips parsing right after finding help flag" []
    (t.= {:config {} :files [] :show-help? true}
         (parse [:--help :--config :--fnldoc-version])))

  (it "skips parsing right after finding version flag" []
    (t.= {:config {} :files [:arg] :write-config? true :show-version? true}
         (parse [:--config :arg :--fnldoc-version :--help]))))

;; vim: lw+=testing,test,it spell
