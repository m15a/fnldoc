(local t (require :test.faith))
(local {: parse } (require :fnldoc.argparse))

(fn test-parse []
  (let [args [:arg1 :--no-toc :--out-dir :here :-- :arg2 :--flag]
        result (parse args :debug)]
    (t.= [:arg1 :--no-toc :--out-dir :here :-- :arg2 :--flag] args)
    (t.= {:config {:out-dir :here :toc? false}
          :files [:arg1 :arg2 :--flag]}
         result))
  (let [args [:--mode :check :--function-signatures :--order :reverse-alphabetic]
        result (parse args :debug)]
    (t.= {:config {:mode :check :function-signatures? true :order :reverse-alphabetic}
          :files []}
         result))
  (let [args [:--mode :chec]]
    (t.error "invalid argument: \"chec\"" #(parse args :debug)))
  (let [args [:--inline-references :code :--copyright :--no-license :--no-version]
        result (parse args :debug)]
    (t.= {:config {:inline-references :code
                   :copyright? true
                   :license? false
                   :version? false}
          :files []}
         result))
  (let [args [:--inline-references :cod]]
    (t.error "invalid argument: \"cod\"" #(parse args :debug)))
  (let [args [:--final-comment :true :--project-copyright :YES :--project-license :MIT]
        result (parse args :debug)]
    (t.= {:config {:final-comment? true
                   :project-copyright :YES
                   :project-license :MIT}
          :files [:true]}
         result))
  (let [args [:--project-version :0.1.0 :--no-sandbox :YES]
        result (parse args :debug)]
    (t.= {:config {:sandbox? false
                   :project-version :0.1.0}
          :files [:YES]}
         result))
  (let [args [:--config :arg :--fnldoc-version :--help]
        result (parse args :debug)]
    (t.= {:config {}
          :files [:arg]
          :write-config? true
          :show-version? true}
         result))
  (let [args [:--help :--config :--fnldoc-version]
        result (parse args :debug)]
    (t.= {:config {}
          :files []
          :show-help? true}
         result)))

{: test-parse}
