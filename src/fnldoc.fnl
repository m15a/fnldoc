(local {: process-config} (require :fnldoc.config))
(local {: process-args} (require :fnldoc.argparse))
(local {: test} (require :fnldoc.doctest))
(local {: module-info} (require :fnldoc.parser))
(local {: gen-markdown} (require :fnldoc.markdown))
(local {: write-docs} (require :fnldoc.writer))

(fn process-file [file config]
  "Accepts `file` as path to some Fennel module, and `config` table.
Generates module documentation and writes it to `file` with `.md`
extension, creating it if not exists."
  (match (module-info file config)
    module (do
             (when (not= config.mode :doc)
               (test module config))
             (let [markdown (gen-markdown module config)]
               (when (not= config.mode :check)
                 (write-docs markdown file module config))))
    _ (io.stderr:write "skipping " file "\n")))

(local version :1.0.2-dev)

(when _G.FNLDOC_EXECUTABLE
  (let [(files config) (-> version
                           process-config
                           process-args)]
    (each [_ file (ipairs files)]
      (process-file file config))))

{: version}
