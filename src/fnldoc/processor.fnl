(local {: basename : dirname : join-paths} (require :fnldoc.utils.file))
(local {: gen-markdown} (require :fnldoc.markdown))
(local {: test} (require :fnldoc.doctest))
(local {: write!} (require :fnldoc.writer))

(fn target-path [modinfo config]
  (let [base (-> (or modinfo.name modinfo.file)
                 (basename :.fnl)
                 (.. :.md))]
    (join-paths config.out-dir (dirname modinfo.file) base)))

(fn process! [modinfo config]
  "Run doctests and generate markdown documentation for `module-info`.

Whether to run doctests and/or generate markdown depend on preferences specified
in `config`. Generated documentation will go to a path corresponding to
`module-info.file` but with `.md` extension under `config.out-dir`."
  {:fnl/arglist [module-info config]}
  (when (not= config.mode :doc)
    (test modinfo config))
  (let [markdown (gen-markdown modinfo config)]
    (when (not= config.mode :check)
      (let [path (target-path modinfo config)]
        (write! markdown path)))))

{: process!}
