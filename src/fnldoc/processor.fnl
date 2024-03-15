(local {: basename
        : dirname
        : join-paths
        : remove-prefix-path} (require :fnldoc.utils.file))
(local {: gen-markdown} (require :fnldoc.markdown))
(local {: test} (require :fnldoc.doctest))
(local {: write!} (require :fnldoc.writer))

(fn target-path [modinfo config]
  (let [base (-> (or modinfo.name modinfo.file)
                 (basename :.fnl)
                 (.. :.md))
        dir (remove-prefix-path config.src-dir (dirname modinfo.file))]
    (join-paths config.out-dir dir base)))

(fn process! [modinfo config]
  "Run doctests and generate markdown documentation for `module-info`.

Whether to run doctests and/or generate markdown depend on preferences specified
in `config`. Generated Markdown documentation will be placed under `config.out-dir`."
  {:fnl/arglist [module-info config]}
  (when (not= config.mode :doc)
    (test modinfo config))
  (let [markdown (gen-markdown modinfo config)]
    (when (not= config.mode :check)
      (let [path (target-path modinfo config)]
        (write! markdown path)))))

{: process!}
