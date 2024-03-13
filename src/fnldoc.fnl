(local unpack (or table.unpack _G.unpack))
(local console (require :fnldoc.console))
(local config (require :fnldoc.config))
(local argparse (require :fnldoc.argparse))
(local {: merge!} (require :fnldoc.utils.table))
(local {: test} (require :fnldoc.doctest))
(local {: module-info} (require :fnldoc.modinfo))
(local {: gen-markdown} (require :fnldoc.markdown))
(local {: write-docs} (require :fnldoc.writer))

(local version :1.0.2-dev)

(fn show-version []
  (io.stderr:write version "\n")
  (os.exit 0))

(fn show-help []
  (io.stderr:write argparse.help "\n")
  (os.exit 0))

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
    _ (console.info "skipping " file)))

(fn main []
  "Run Fnldoc application."
  (let [config/file (config.init! {: version})
        {: show-version?
         : show-help?
         : write-config?
         :config config/arg
         : files} (argparse.parse [(unpack arg 1 (length arg))])
        config (doto config/file (merge! config/arg))]
    (when show-help?
      (show-help))
    (when show-version?
      (show-version))
    (when write-config?
      (config:write!))
    (each [_ file (ipairs files)]
      (process-file file config))))

{: version : main}
