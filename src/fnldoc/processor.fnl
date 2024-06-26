;;;; Orchestrate tasks.

(local console (require :fnldoc.console))
(local {: basename
        : dirname
        : join-paths
        : remove-prefix-path}
       (require :fnldoc.utils.file))
(local {: module-info} (require :fnldoc.modinfo))
(local {: module-info->markdown} (require :fnldoc.markdown))
(local {: test} (require :fnldoc.doctest))
(local {: write!} (require :fnldoc.writer))

(lambda destination-path [modinfo config]
  "Determine path to put generated Markdown from `module-info` and `config`."
  {:fnl/arglist [module-info config]}
  (let [base (.. (or modinfo.name (basename modinfo.file :.fnl)) :.md)
        dir (remove-prefix-path config.src-dir (dirname modinfo.file))]
    (join-paths config.out-dir dir base)))

(lambda process! [file config]
  "Extract module information from the `file`, run tests, and generate Markdown.

Whether to run tests and/or to generate markdown depends on preferences
specified in the `config`. Generated documentation will be placed under
`config.out-dir`."
  (match (module-info file config)
    modinfo (do
              (when (not= config.mode :doc)
                (test modinfo config))
              (let [markdown (module-info->markdown modinfo config)]
                (when (not= config.mode :check)
                  (let [path (destination-path modinfo config)]
                    (write! markdown path)))))
    _ (console.info "skipping file: " file)))

{: destination-path : process!}
