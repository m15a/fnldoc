(local unpack (or table.unpack _G.unpack))
(local {: merge!} (require :fnldoc.utils.table))
(local console (require :fnldoc.console))
(local config (require :fnldoc.config))
(local argparse (require :fnldoc.argparse))
(local {: process!} (require :fnldoc.processor))

(local version :1.0.2-dev)

(fn show-version []
  (io.stderr:write version "\n")
  (os.exit 0))

(fn show-help []
  (let [color? (console.isatty? 2)]
    (io.stderr:write (argparse.help color?) "\n"))
  (os.exit 0))

(fn main []
  "Run Fnldoc application."
  (let [config/file (config.init! {: version})
        {: show-version?
         : show-help?
         : write-config?
         :config config/arg
         : files} (argparse.parse [(unpack arg 1)])
        config (doto config/file (merge! config/arg))]
    (when show-help?
      (show-help))
    (when show-version?
      (show-version))
    (when write-config?
      (config:write!))
    (each [_ file (ipairs files)]
      (process! file config))))

{: version : main}
