(local {: process-config} (require :config))
(local {: process-args} (require :argparse))
(local {: test} (require :doctest))
(local {: module-info} (require :parser))
(local {: gen-markdown} (require :markdown))
(local {: write-docs} (require :writer))

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

(let [(files config) (-> FENNELDOC_VERSION
                         process-config
                         process-args)]
  (each [_ file (ipairs files)]
    (process-file file config)))
